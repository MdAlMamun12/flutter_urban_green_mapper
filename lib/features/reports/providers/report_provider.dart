import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _isLoading = false;
  String? _error;
  List<ReportModel> _userReports = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ReportModel> get userReports => _userReports;

  // Submit a new report
  Future<bool> submitReport({
    required String title,
    required String description,
    required String reportType,
    required String spaceId,
    required String spaceName,
    required List<String> imagePaths,
    required String userId,
    required String userName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload images to Firebase Storage and get URLs
      final List<String> photoUrls = await _uploadImages(imagePaths);

      final reportId = _firestore.collection(FirestoreConstants.reportsCollection).doc().id;
      
      // Convert report type to the format expected by your ReportModel
      final String type = _convertReportTypeToModelFormat(reportType);
      
      final report = ReportModel(
        reportId: reportId,
        userId: userId,
        spaceId: spaceId,
        type: type,
        description: description,
        photos: photoUrls,
        status: 'pending',
        rejectionReason: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userName: userName,
        spaceName: spaceName,
        title: title,
      );

      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .set(report.toMap());

      // Add to local list
      _userReports.insert(0, report);
      
      // Update user's impact score
      await _updateUserImpactScore(userId, 10);

      print('✅ Report submitted successfully: $reportId');
      return true;

    } catch (e) {
      _error = 'Failed to submit report: $e';
      print('❌ Error submitting report: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convert UI report type to model format
  String _convertReportTypeToModelFormat(String reportType) {
    switch (reportType) {
      case 'Maintenance Needed':
        return 'maintenance';
      case 'Vandalism Report':
        return 'vandalism';
      case 'Safety Concern':
        return 'safety';
      case 'Improvement Suggestion':
        return 'suggestion';
      case 'Other Issue':
        return 'other';
      default:
        return 'other';
    }
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return [];

    final List<String> downloadUrls = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final String imagePath = imagePaths[i];
        final File imageFile = File(imagePath);
        
        // Check if file exists
        if (!await imageFile.exists()) {
          print('⚠️ Image file does not exist: $imagePath');
          continue;
        }
        
        // Create a unique filename
        final String fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        // Upload to Firebase Storage
        final TaskSnapshot snapshot = await _storage
            .ref()
            .child(fileName)
            .putFile(imageFile);
        
        // Get download URL
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        
        print('✅ Image uploaded: $downloadUrl');
      } catch (e) {
        print('❌ Error uploading image: $e');
        // Continue with other images even if one fails
      }
    }

    return downloadUrls;
  }

  // Update user impact score
  Future<void> _updateUserImpactScore(String userId, int points) async {
    try {
      final userRef = _firestore.collection(FirestoreConstants.usersCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (userDoc.exists) {
          final currentScore = userDoc.data()!['impactScore'] ?? 0;
          final newScore = currentScore + points;
          transaction.update(userRef, {
            'impactScore': newScore,
            'updated_at': FieldValue.serverTimestamp(),
          });
          print('✅ Updated impact score for user $userId: $currentScore → $newScore');
        }
      });
    } catch (e) {
      print('⚠️ Failed to update impact score: $e');
      // Don't throw error here - report submission should still succeed
    }
  }

  // Get user's reports
  Future<void> getUserReports(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      _userReports = querySnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();

      print('✅ Loaded ${_userReports.length} reports for user $userId');

    } catch (e) {
      _error = 'Failed to load reports: $e';
      print('❌ Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get report by ID
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .get();

      if (doc.exists) {
        return ReportModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting report: $e');
      return null;
    }
  }

  // Update report status (for admin)
  Future<bool> updateReportStatus({
    required String reportId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .update({
            'status': status,
            'rejection_reason': rejectionReason,
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local list if report exists
      final index = _userReports.indexWhere((report) => report.reportId == reportId);
      if (index != -1) {
        _userReports[index] = _userReports[index].copyWith(
          status: status,
          rejectionReason: rejectionReason,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      print('✅ Updated report $reportId status to $status');
      return true;
    } catch (e) {
      _error = 'Failed to update report: $e';
      print('❌ Error updating report: $e');
      return false;
    }
  }

  // Delete report
  Future<bool> deleteReport(String reportId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .delete();

      // Remove from local list
      _userReports.removeWhere((report) => report.reportId == reportId);
      notifyListeners();

      print('✅ Deleted report: $reportId');
      return true;
    } catch (e) {
      _error = 'Failed to delete report: $e';
      print('❌ Error deleting report: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user reports
  Future<void> refreshUserReports(String userId) async {
    await getUserReports(userId);
  }

  // Clear all data (on logout)
  void clearData() {
    _userReports.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}