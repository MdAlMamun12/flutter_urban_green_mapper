import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/core/models/adoption_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

class AdoptionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PlantModel> _plants = [];
  List<AdoptionModel> _userAdoptions = [];
  bool _isLoading = false;
  String? _error;

  List<PlantModel> get plants => _plants;
  List<AdoptionModel> get userAdoptions => _userAdoptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all available plants for adoption
  Future<void> loadPlants() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final plantsSnapshot = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('is_available_for_adoption', isEqualTo: true)
          .get();

      _plants = plantsSnapshot.docs.map((doc) {
        return PlantModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      _error = 'Failed to load plants: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream plants for real-time updates
  Stream<QuerySnapshot> getPlantsStream() {
    return _firestore
        .collection(FirestoreConstants.plantsCollection)
        .where('is_available_for_adoption', isEqualTo: true)
        .snapshots();
  }

  /// Load user's adopted plants
  Future<void> loadUserAdoptions(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final adoptionsSnapshot = await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .where('user_id', isEqualTo: userId)
          .where('status', whereIn: ['active', 'pending'])
          .get();

      _userAdoptions = adoptionsSnapshot.docs.map((doc) {
        return AdoptionModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      _error = 'Failed to load user adoptions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream user adoptions for real-time updates
  Stream<QuerySnapshot> getUserAdoptionsStream(String userId) {
    return _firestore
        .collection(FirestoreConstants.adoptionsCollection)
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  /// Adopt a plant
  Future<bool> adoptPlant(String plantId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if plant is still available
      final plantDoc = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .get();

      if (!plantDoc.exists) {
        throw Exception('Plant not found');
      }

      final plantData = plantDoc.data();
      if (plantData?['is_available_for_adoption'] != true) {
        throw Exception('Plant is no longer available for adoption');
      }

      // Check if user already adopted this plant
      final existingAdoption = await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .where('user_id', isEqualTo: userId)
          .where('plant_id', isEqualTo: plantId)
          .where('status', whereIn: ['active', 'pending'])
          .get();

      if (existingAdoption.docs.isNotEmpty) {
        throw Exception('You have already adopted this plant');
      }

      // Create adoption record
      final adoptionId = 'adoption_${plantId}_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final adoption = AdoptionModel(
        adoptionId: adoptionId,
        userId: userId,
        plantId: plantId,
        status: 'active',
        adoptedAt: DateTime.now(),
        lastCareDate: DateTime.now(),
        careSchedule: {
          'watering_frequency': 7, // days
          'fertilizing_frequency': 30, // days
          'pruning_frequency': 90, // days
          'next_watering': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'next_fertilizing': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        },
      );

      // Run transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        // Create adoption record
        transaction.set(
          _firestore.collection(FirestoreConstants.adoptionsCollection).doc(adoptionId),
          adoption.toMap(),
        );

        // Update plant status
        transaction.update(
          _firestore.collection(FirestoreConstants.plantsCollection).doc(plantId),
          {
            'is_available_for_adoption': false,
            'adopted_by': userId,
            'adopted_at': DateTime.now().toIso8601String(),
            'updated_at': FieldValue.serverTimestamp(),
          },
        );
      });

      // Update user impact score
      await _databaseService.updateUserImpactScore(userId, 25);

      // Reload data
      await loadPlants();
      await loadUserAdoptions(userId);

      return true;
    } catch (e) {
      _error = 'Failed to adopt plant: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit plant care report
  Future<bool> submitCareReport({
    required String adoptionId,
    required String plantId,
    required String userId,
    required Map<String, dynamic> careActivities,
    required String notes,
    required List<String> photoUrls,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final careReportId = 'care_${DateTime.now().millisecondsSinceEpoch}';

      // Create care report
      await _firestore
          .collection(FirestoreConstants.careReportsCollection)
          .doc(careReportId)
          .set({
            'care_report_id': careReportId,
            'adoption_id': adoptionId,
            'plant_id': plantId,
            'user_id': userId,
            'care_activities': careActivities,
            'notes': notes,
            'photo_urls': photoUrls,
            'submitted_at': DateTime.now().toIso8601String(),
            'status': 'submitted',
          });

      // Update adoption last care date
      await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .doc(adoptionId)
          .update({
            'last_care_date': DateTime.now().toIso8601String(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update user impact score for care activity
      await _databaseService.updateUserImpactScore(userId, 5);

      return true;
    } catch (e) {
      _error = 'Failed to submit care report: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get plant care history
  Future<List<Map<String, dynamic>>> getPlantCareHistory(String adoptionId) async {
    try {
      final careHistorySnapshot = await _firestore
          .collection(FirestoreConstants.careReportsCollection)
          .where('adoption_id', isEqualTo: adoptionId)
          .orderBy('submitted_at', descending: true)
          .get();

      return careHistorySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

    } catch (e) {
      throw Exception('Failed to load care history: $e');
    }
  }

  /// Release adopted plant back to available pool
  Future<bool> releasePlant(String adoptionId, String plantId, String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.runTransaction((transaction) async {
        // Update adoption status to released
        transaction.update(
          _firestore.collection(FirestoreConstants.adoptionsCollection).doc(adoptionId),
          {
            'status': 'released',
            'released_at': DateTime.now().toIso8601String(),
            'updated_at': FieldValue.serverTimestamp(),
          },
        );

        // Make plant available for adoption again
        transaction.update(
          _firestore.collection(FirestoreConstants.plantsCollection).doc(plantId),
          {
            'is_available_for_adoption': true,
            'adopted_by': null,
            'adopted_at': null,
            'updated_at': FieldValue.serverTimestamp(),
          },
        );
      });

      // Reload data
      await loadPlants();
      await loadUserAdoptions(userId);

      return true;
    } catch (e) {
      _error = 'Failed to release plant: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get plants by green space
  Future<List<PlantModel>> getPlantsBySpace(String spaceId) async {
    try {
      final plantsSnapshot = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('space_id', isEqualTo: spaceId)
          .where('is_available_for_adoption', isEqualTo: true)
          .get();

      return plantsSnapshot.docs.map((doc) {
        return PlantModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      throw Exception('Failed to load plants by space: $e');
    }
  }

  /// Search plants by species
  Future<List<PlantModel>> searchPlants(String query) async {
    try {
      final plantsSnapshot = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('species', isGreaterThanOrEqualTo: query)
          .where('species', isLessThanOrEqualTo: '$query\uf8ff')
          .where('is_available_for_adoption', isEqualTo: true)
          .get();

      return plantsSnapshot.docs.map((doc) {
        return PlantModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      throw Exception('Failed to search plants: $e');
    }
  }

  /// Update plant health status
  Future<void> updatePlantHealth(String plantId, String healthStatus) async {
    try {
      await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .update({
            'health_status': healthStatus,
            'updated_at': FieldValue.serverTimestamp(),
          });

    } catch (e) {
      throw Exception('Failed to update plant health: $e');
    }
  }

  /// Get adoption statistics for user
  Future<Map<String, dynamic>> getUserAdoptionStats(String userId) async {
    try {
      final adoptionsSnapshot = await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final totalAdoptions = adoptionsSnapshot.docs.length;
      final activeAdoptions = adoptionsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'active')
          .length;
      final completedAdoptions = adoptionsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'completed')
          .length;

      // Get care reports count
      final careReportsSnapshot = await _firestore
          .collection(FirestoreConstants.careReportsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      return {
        'total_adoptions': totalAdoptions,
        'active_adoptions': activeAdoptions,
        'completed_adoptions': completedAdoptions,
        'care_activities_count': careReportsSnapshot.docs.length,
        'adoption_success_rate': totalAdoptions > 0 ? (completedAdoptions / totalAdoptions * 100) : 0,
      };

    } catch (e) {
      throw Exception('Failed to get adoption statistics: $e');
    }
  }

  /// Get plant by ID
  Future<PlantModel> getPlantById(String plantId) async {
    try {
      final plantDoc = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .get();

      if (plantDoc.exists) {
        return PlantModel.fromMap(plantDoc.data()!);
      } else {
        throw Exception('Plant not found');
      }
    } catch (e) {
      throw Exception('Failed to get plant: $e');
    }
  }

  /// Get adoption by ID
  Future<AdoptionModel> getAdoptionById(String adoptionId) async {
    try {
      final adoptionDoc = await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .doc(adoptionId)
          .get();

      if (adoptionDoc.exists) {
        return AdoptionModel.fromMap(adoptionDoc.data()!);
      } else {
        throw Exception('Adoption not found');
      }
    } catch (e) {
      throw Exception('Failed to get adoption: $e');
    }
  }

  /// Update care schedule
  Future<void> updateCareSchedule({
    required String adoptionId,
    required Map<String, dynamic> careSchedule,
  }) async {
    try {
      await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .doc(adoptionId)
          .update({
            'care_schedule': careSchedule,
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update care schedule: $e');
    }
  }

  /// Get plants needing care (for reminders)
  Future<List<AdoptionModel>> getPlantsNeedingCare(String userId) async {
    try {
      final now = DateTime.now();
      final adoptionsSnapshot = await _firestore
          .collection(FirestoreConstants.adoptionsCollection)
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final adoptions = adoptionsSnapshot.docs.map((doc) {
        return AdoptionModel.fromMap(doc.data());
      }).toList();

      // Filter plants that need care (next watering within 2 days)
      return adoptions.where((adoption) {
        final careSchedule = adoption.careSchedule;
        // ignore: unnecessary_null_comparison
        if (careSchedule != null && careSchedule['next_watering'] != null) {
          try {
            final nextWatering = DateTime.parse(careSchedule['next_watering']);
            return nextWatering.isBefore(now.add(const Duration(days: 2)));
          } catch (e) {
            return false;
          }
        }
        return false;
      }).toList();

    } catch (e) {
      throw Exception('Failed to get plants needing care: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}