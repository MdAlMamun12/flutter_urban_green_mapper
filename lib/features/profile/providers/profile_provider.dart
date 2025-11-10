import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/participation_model.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';
import 'package:urban_green_mapper/core/services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  UserModel? _user;
  List<ReportModel> _userReports = [];
  List<ParticipationModel> _userParticipations = [];
  List<PlantModel> _adoptedPlants = [];
  Map<String, dynamic> _userStatistics = {};
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;

  // OTP Verification state
  bool _isOtpSent = false;
  bool _isVerifying = false;
  String? _otpError;
  String? _verificationId;
  int? _resendToken;

  // Getters
  UserModel? get user => _user;
  List<ReportModel> get userReports => _userReports;
  List<ParticipationModel> get userParticipations => _userParticipations;
  List<PlantModel> get adoptedPlants => _adoptedPlants;
  Map<String, dynamic> get userStatistics => _userStatistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEditing => _isEditing;
  bool get isOtpSent => _isOtpSent;
  bool get isVerifying => _isVerifying;
  String? get otpError => _otpError;

  // Statistics getters
  int get totalReports => _userReports.length;
  int get approvedReports => _userReports.where((report) => report.status == 'approved').length;
  int get pendingReports => _userReports.where((report) => report.status == 'pending').length;
  int get totalEventsJoined => _userParticipations.length;
  int get attendedEvents => _userParticipations.where((participation) => participation.status == 'attended').length;
  int get totalVolunteerHours => _userParticipations.fold(0, (sum, participation) => sum + (participation.hoursContributed));
  int get adoptedPlantsCount => _adoptedPlants.length;

  /// Load user profile data
  Future<void> loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load user data
      _user = await _databaseService.getUser(userId);

      // Load user reports
      await _loadUserReports(userId);

      // Load user participations
      await _loadUserParticipations(userId);

      // Load adopted plants
      await _loadAdoptedPlants(userId);

      // Calculate statistics
      await _calculateUserStatistics();

      print('✅ Profile data loaded successfully for user: $userId');

    } catch (e) {
      _error = 'Failed to load profile: $e';
      print('❌ Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user reports
  Future<void> _loadUserReports(String userId) async {
    try {
      final reportsSnapshot = await _databaseService.getUserReports(userId).first;
      _userReports = reportsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReportModel.fromMap(data);
      }).toList();
      print('✅ Loaded ${_userReports.length} user reports');
    } catch (e) {
      print('❌ Error loading user reports: $e');
      throw Exception('Failed to load user reports: $e');
    }
  }

  /// Load user participations
  Future<void> _loadUserParticipations(String userId) async {
    try {
      final participationsSnapshot = await _databaseService.getUserParticipations(userId).first;
      _userParticipations = participationsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ParticipationModel.fromMap(data);
      }).toList();
      print('✅ Loaded ${_userParticipations.length} user participations');
    } catch (e) {
      print('❌ Error loading user participations: $e');
      throw Exception('Failed to load user participations: $e');
    }
  }

  /// Load adopted plants
  Future<void> _loadAdoptedPlants(String userId) async {
    try {
      // In a real app, this would fetch plants adopted by the user
      // For now, we'll use mock data with all required parameters
      await Future.delayed(const Duration(milliseconds: 500));
      
      final now = DateTime.now();
      _adoptedPlants = [
        PlantModel(
          plantId: '1',
          spaceId: 'space1',
          species: 'Oak Tree',
          commonName: 'Northern Red Oak',
          scientificName: 'Quercus rubra',
          description: 'A majestic native oak tree known for its beautiful fall foliage',
          plantingDate: now.subtract(const Duration(days: 90)),
          healthStatus: 'excellent',
          lastMaintenance: now.subtract(const Duration(days: 7)),
          nextMaintenance: now.add(const Duration(days: 7)),
          adoptedBy: userId,
          adoptionDate: now.subtract(const Duration(days: 90)),
          location: {'lat': 40.7128, 'lng': -74.0060},
          height: 2.5,
          diameter: 0.15,
          notes: 'Growing well, needs regular watering',
          images: ['https://example.com/oak-tree.jpg'],
          maintenanceHistory: [
            {
              'date': now.subtract(const Duration(days: 7)),
              'type': 'watering',
              'notes': 'Regular watering',
              'performed_by': userId
            }
          ],
        ),
        PlantModel(
          plantId: '2',
          spaceId: 'space1',
          species: 'Maple Tree',
          commonName: 'Sugar Maple',
          scientificName: 'Acer saccharum',
          description: 'Famous for its sweet sap and vibrant autumn colors',
          plantingDate: now.subtract(const Duration(days: 45)),
          healthStatus: 'good',
          lastMaintenance: now.subtract(const Duration(days: 3)),
          nextMaintenance: now.add(const Duration(days: 10)),
          adoptedBy: userId,
          adoptionDate: now.subtract(const Duration(days: 45)),
          location: {'lat': 40.7129, 'lng': -74.0061},
          height: 1.8,
          diameter: 0.12,
          notes: 'Very healthy, growing quickly',
          images: ['https://example.com/maple-tree.jpg'],
          maintenanceHistory: [
            {
              'date': now.subtract(const Duration(days: 3)),
              'type': 'fertilizing',
              'notes': 'Applied organic fertilizer',
              'performed_by': userId
            }
          ],
        ),
        PlantModel(
          plantId: '3',
          spaceId: 'space2',
          species: 'Rose Bush',
          commonName: 'Hybrid Tea Rose',
          scientificName: 'Rosa hybrida',
          description: 'Beautiful flowering rose bush with fragrant pink blooms',
          plantingDate: now.subtract(const Duration(days: 30)),
          healthStatus: 'poor',
          lastMaintenance: now.subtract(const Duration(days: 5)),
          nextMaintenance: now.add(const Duration(days: 5)),
          adoptedBy: userId,
          adoptionDate: now.subtract(const Duration(days: 30)),
          location: {'lat': 40.7228, 'lng': -74.0160},
          height: 0.8,
          diameter: 0.6,
          notes: 'Regular pruning needed for optimal flowering',
          images: ['https://example.com/rose-bush.jpg'],
          maintenanceHistory: [
            {
              'date': now.subtract(const Duration(days: 5)),
              'type': 'pruning',
              'notes': 'Light pruning to shape the bush',
              'performed_by': userId
            }
          ],
        ),
      ];
      print('✅ Loaded ${_adoptedPlants.length} adopted plants');
    } catch (e) {
      print('❌ Error loading adopted plants: $e');
      throw Exception('Failed to load adopted plants: $e');
    }
  }

  /// Calculate user statistics
  Future<void> _calculateUserStatistics() async {
    try {
      _userStatistics = {
        'total_reports': totalReports,
        'approved_reports': approvedReports,
        'pending_reports': pendingReports,
        'total_events_joined': totalEventsJoined,
        'attended_events': attendedEvents,
        'total_volunteer_hours': totalVolunteerHours,
        'adopted_plants_count': adoptedPlantsCount,
        'impact_score': _user?.impactScore ?? 0,
        'member_since': _user?.createdAt ?? DateTime.now(),
        'report_approval_rate': totalReports > 0 ? (approvedReports / totalReports * 100) : 0,
        'event_attendance_rate': totalEventsJoined > 0 ? (attendedEvents / totalEventsJoined * 100) : 0,
        'average_plant_health': _calculateAveragePlantHealth(),
        'total_contribution_hours': totalVolunteerHours + (_adoptedPlants.length * 5), // 5 hours per plant maintenance
      };
      print('✅ User statistics calculated successfully');
    } catch (e) {
      print('❌ Error calculating statistics: $e');
      throw Exception('Failed to calculate statistics: $e');
    }
  }

  /// Calculate average plant health
  double _calculateAveragePlantHealth() {
    if (_adoptedPlants.isEmpty) return 0.0;
    
    final healthScores = {
      'excellent': 100,
      'good': 80,
      'fair': 60,
      'poor': 40,
      'critical': 20,
    };
    
    final totalScore = _adoptedPlants.fold(0, (sum, plant) {
      return sum + (healthScores[plant.healthStatus] ?? 50);
    });
    
    return totalScore / _adoptedPlants.length;
  }

  /// ==================== ACCOUNT MANAGEMENT METHODS ====================

  /// Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? phoneNumber,
    Map<String, dynamic>? location,
    String? bio,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('No user data available');
      }

      final updates = <String, dynamic>{
        'name': name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (phoneNumber != null) {
        updates['phone_number'] = phoneNumber;
      }

      if (location != null) {
        updates['location'] = location;
      }

      if (bio != null) {
        updates['bio'] = bio;
      }

      // Update user in database
      await _databaseService.updateUser(_user!.userId, updates);
      
      // Update local user model
      final updatedUserData = _user!.toMap();
      updatedUserData.addAll(updates);
      _user = UserModel.fromMap(updatedUserData);

      // Notify listeners
      notifyListeners();

      print('✅ User profile updated successfully');

    } catch (e) {
      _error = 'Failed to update profile: $e';
      print('❌ Error updating profile: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile picture
  Future<void> updateProfilePicture(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('No user data available');
      }

      // Upload image to Firebase Storage
      final downloadUrl = await _storageService.uploadImage(
        imageFile,
        'profile_pictures/${_user!.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Update user profile with new image URL
      await _databaseService.updateUser(_user!.userId, {
        'profile_picture': downloadUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update local user model
      final updatedUserData = _user!.toMap();
      updatedUserData['profile_picture'] = downloadUrl;
      _user = UserModel.fromMap(updatedUserData);

      // Notify listeners
      notifyListeners();

      print('✅ Profile picture updated successfully');

    } catch (e) {
      _error = 'Failed to update profile picture: $e';
      print('❌ Error updating profile picture: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'Failed to pick image: $e';
      print('❌ Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      _error = 'Failed to capture image: $e';
      print('❌ Error capturing image from camera: $e');
      return null;
    }
  }

  /// ==================== PASSWORD RESET WITH OTP ====================

  /// Send OTP to phone number for password reset
  Future<void> sendPasswordResetOtp(String phoneNumber) async {
    try {
      _isVerifying = true;
      _otpError = null;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          await _resetPasswordWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _otpError = 'Verification failed: ${e.message}';
          _isVerifying = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isOtpSent = true;
          _isVerifying = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      print('✅ OTP sent successfully to $phoneNumber');

    } catch (e) {
      _otpError = 'Failed to send OTP: $e';
      _isVerifying = false;
      print('❌ Error sending OTP: $e');
      notifyListeners();
    }
  }

  /// Verify OTP and reset password
  Future<void> verifyOtpAndResetPassword(String otp, String newPassword) async {
    try {
      _isVerifying = true;
      _otpError = null;
      notifyListeners();

      if (_verificationId == null) {
        throw Exception('No verification in progress');
      }

      // Create credential with OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Reset password using the credential
      await _resetPasswordWithCredential(credential, newPassword);

      _isVerifying = false;
      _isOtpSent = false;
      notifyListeners();

      print('✅ Password reset successfully with OTP');

    } catch (e) {
      _otpError = 'Failed to verify OTP: $e';
      _isVerifying = false;
      print('❌ Error verifying OTP: $e');
      notifyListeners();
      throw e;
    }
  }

  /// Reset password using email
  Future<void> resetPasswordWithEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      print('✅ Password reset email sent to $email');

    } catch (e) {
      _error = 'Failed to send password reset email: $e';
      print('❌ Error sending password reset email: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password with current password verification
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Update user in database
      await _databaseService.updateUser(user.uid, {
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Password changed successfully');

    } catch (e) {
      _error = 'Failed to change password: $e';
      print('❌ Error changing password: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper method to reset password with credential
  Future<void> _resetPasswordWithCredential(
    PhoneAuthCredential credential, [
    String? newPassword,
  ]) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // User is signed in, update password
        if (newPassword != null) {
          await user.updatePassword(newPassword);
        }
      } else {
        // User is not signed in, sign in with credential
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Update password if provided
        if (newPassword != null && userCredential.user != null) {
          await userCredential.user!.updatePassword(newPassword);
        }
        
        // Sign out after password reset
        await _auth.signOut();
      }
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Resend OTP
  Future<void> resendOtp(String phoneNumber) async {
    try {
      _isVerifying = true;
      _otpError = null;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _resetPasswordWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _otpError = 'Verification failed: ${e.message}';
          _isVerifying = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isOtpSent = true;
          _isVerifying = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );

      print('✅ OTP resent successfully to $phoneNumber');

    } catch (e) {
      _otpError = 'Failed to resend OTP: $e';
      _isVerifying = false;
      print('❌ Error resending OTP: $e');
      notifyListeners();
    }
  }

  /// ==================== ACTIVITY HISTORY ====================

  /// Load user activity history
  Future<List<Map<String, dynamic>>> getUserActivityHistory() async {
    try {
      final activities = <Map<String, dynamic>>[];

      // Add report activities
      for (final report in _userReports) {
        activities.add({
          'type': 'report',
          'title': 'Report Submitted',
          'description': 'Submitted a report for green space',
          'timestamp': report.createdAt,
          'status': report.status,
          'data': report.toMap(),
          'icon': '📝',
        });
      }

      // Add participation activities
      for (final participation in _userParticipations) {
        activities.add({
          'type': 'participation',
          'title': 'Event ${participation.status}',
          'description': '${participation.status == 'attended' ? 'Attended' : 'Registered for'} event',
          'timestamp': participation.joinedAt,
          'status': participation.status,
          'data': participation.toMap(),
          'icon': '🎉',
        });
      }

      // Add plant adoption activities
      for (final plant in _adoptedPlants) {
        activities.add({
          'type': 'adoption',
          'title': 'Plant Adopted',
          'description': 'Adopted a ${plant.commonName}',
          'timestamp': plant.plantingDate,
          'status': 'adopted',
          'data': plant.toMap(),
          'icon': '🌱',
        });
      }

      // Sort activities by timestamp (newest first)
      activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      print('✅ Loaded ${activities.length} user activities');

      return activities;

    } catch (e) {
      print('❌ Error loading activity history: $e');
      throw Exception('Failed to load activity history: $e');
    }
  }

  /// ==================== DATA EXPORT ====================

  /// Export user data as JSON string
  Future<String> exportUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = <String, dynamic>{
        'export_info': {
          'exported_at': DateTime.now().toIso8601String(),
          'app_version': '1.0.0',
          'format': 'json',
        },
        'user_profile': _user?.toMap(),
        'reports': _userReports.map((report) => report.toMap()).toList(),
        'participations': _userParticipations.map((participation) => participation.toMap()).toList(),
        'adopted_plants': _adoptedPlants.map((plant) => plant.toMap()).toList(),
        'statistics': _userStatistics,
      };

      // Convert to pretty JSON string
      final jsonString = _convertToJson(userData);

      _isLoading = false;
      notifyListeners();

      print('✅ User data exported successfully');

      return jsonString;

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('❌ Error exporting user data: $e');
      throw Exception('Failed to export user data: $e');
    }
  }

  String _convertToJson(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    
    final entries = data.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('  "${entry.key}": ');
      
      final value = entry.value;
      if (value is String) {
        buffer.write('"${_escapeJsonString(value)}"');
      } else if (value is List) {
        buffer.write('[');
        for (var j = 0; j < value.length; j++) {
          final item = value[j];
          if (item is Map<String, dynamic>) {
            buffer.write(_convertMapToJson(item));
          } else if (item is String) {
            buffer.write('"${_escapeJsonString(item)}"');
          } else {
            buffer.write('$item');
          }
          if (j < value.length - 1) buffer.write(',');
        }
        buffer.write(']');
      } else if (value is Map<String, dynamic>) {
        buffer.write(_convertMapToJson(value));
      } else {
        buffer.write('$value');
      }
      
      if (i < entries.length - 1) buffer.write(',');
      buffer.writeln();
    }
    
    buffer.writeln('}');
    return buffer.toString();
  }

  String _convertMapToJson(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    buffer.write('{');
    
    final entries = map.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}": ');
      
      final value = entry.value;
      if (value is String) {
        buffer.write('"${_escapeJsonString(value)}"');
      } else if (value is DateTime) {
        buffer.write('"${value.toIso8601String()}"');
      } else if (value is Map<String, dynamic>) {
        buffer.write(_convertMapToJson(value));
      } else if (value is List) {
        buffer.write('[');
        for (var j = 0; j < value.length; j++) {
          final item = value[j];
          if (item is String) {
            buffer.write('"${_escapeJsonString(item)}"');
          } else {
            buffer.write('$item');
          }
          if (j < value.length - 1) buffer.write(',');
        }
        buffer.write(']');
      } else {
        buffer.write('$value');
      }
      
      if (i < entries.length - 1) buffer.write(',');
    }
    
    buffer.write('}');
    return buffer.toString();
  }

  String _escapeJsonString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\b', '\\b')
        .replaceAll('\f', '\\f')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// ==================== ACCOUNT DELETION ====================

  /// Delete user account
  Future<void> deleteAccount(String confirmationText) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('No user data available');
      }

      // Confirm deletion
      if (confirmationText != 'DELETE') {
        throw Exception('Please type DELETE to confirm account deletion');
      }

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // Delete user data from database
      await _databaseService.deleteUserData(_user!.userId);

      // Delete user from Firebase Auth
      await user.delete();

      // Clear local state
      _user = null;
      _userReports = [];
      _userParticipations = [];
      _adoptedPlants = [];
      _userStatistics = {};

      // Notify listeners
      notifyListeners();

      print('✅ User account deleted successfully');

    } catch (e) {
      _error = 'Failed to delete account: $e';
      print('❌ Error deleting account: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ==================== ACHIEVEMENTS ====================

  /// Get user achievements
  Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      final achievements = <Map<String, dynamic>>[];

      // Report achievements
      if (totalReports >= 1) {
        achievements.add({
          'id': 'first_report',
          'title': 'First Report',
          'description': 'Submitted your first green space report',
          'icon': '📝',
          'unlocked': true,
          'unlocked_at': _userReports.isNotEmpty ? _userReports.first.createdAt : DateTime.now(),
        });
      }

      if (approvedReports >= 5) {
        achievements.add({
          'id': 'reporter',
          'title': 'Dedicated Reporter',
          'description': 'Had 5 reports approved by moderators',
          'icon': '⭐',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      // Event achievements
      if (attendedEvents >= 1) {
        achievements.add({
          'id': 'first_event',
          'title': 'Event Participant',
          'description': 'Attended your first community event',
          'icon': '🎉',
          'unlocked': true,
          'unlocked_at': _userParticipations.isNotEmpty ? _userParticipations.first.joinedAt : DateTime.now(),
        });
      }

      if (attendedEvents >= 10) {
        achievements.add({
          'id': 'community_champion',
          'title': 'Community Champion',
          'description': 'Attended 10 community events',
          'icon': '🏆',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      // Plant adoption achievements
      if (adoptedPlantsCount >= 1) {
        achievements.add({
          'id': 'plant_parent',
          'title': 'Plant Parent',
          'description': 'Adopted your first plant',
          'icon': '🌱',
          'unlocked': true,
          'unlocked_at': _adoptedPlants.isNotEmpty ? _adoptedPlants.first.plantingDate : DateTime.now(),
        });
      }

      if (adoptedPlantsCount >= 5) {
        achievements.add({
          'id': 'green_guardian',
          'title': 'Green Guardian',
          'description': 'Adopted 5 plants',
          'icon': '🌳',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      // Impact score achievements
      final impactScore = _user?.impactScore ?? 0;
      if (impactScore >= 100) {
        achievements.add({
          'id': 'eco_warrior',
          'title': 'Eco Warrior',
          'description': 'Reached 100 impact points',
          'icon': '♻️',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      if (impactScore >= 500) {
        achievements.add({
          'id': 'sustainability_champion',
          'title': 'Sustainability Champion',
          'description': 'Reached 500 impact points',
          'icon': '🌍',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      // Volunteer hours achievements
      if (totalVolunteerHours >= 10) {
        achievements.add({
          'id': 'volunteer',
          'title': 'Dedicated Volunteer',
          'description': 'Completed 10 volunteer hours',
          'icon': '⏰',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      if (totalVolunteerHours >= 50) {
        achievements.add({
          'id': 'super_volunteer',
          'title': 'Super Volunteer',
          'description': 'Completed 50 volunteer hours',
          'icon': '💪',
          'unlocked': true,
          'unlocked_at': DateTime.now(),
        });
      }

      print('✅ Loaded ${achievements.length} user achievements');

      return achievements;

    } catch (e) {
      print('❌ Error loading achievements: $e');
      throw Exception('Failed to load achievements: $e');
    }
  }

  /// ==================== UTILITY METHODS ====================

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_user != null) {
      await loadUserProfile(_user!.userId);
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear OTP error
  void clearOtpError() {
    _otpError = null;
    notifyListeners();
  }

  /// Reset OTP state
  void resetOtpState() {
    _isOtpSent = false;
    _isVerifying = false;
    _otpError = null;
    _verificationId = null;
    _resendToken = null;
    notifyListeners();
  }

  /// Clear all data (on logout)
  void clearData() {
    _user = null;
    _userReports = [];
    _userParticipations = [];
    _adoptedPlants = [];
    _userStatistics = {};
    _error = null;
    _isEditing = false;
    resetOtpState();
    notifyListeners();
    print('✅ Profile provider data cleared');
  }
}