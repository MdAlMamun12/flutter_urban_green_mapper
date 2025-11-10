import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';

class MapProvider with ChangeNotifier {
  List<GreenSpaceModel> _greenSpaces = [];
  bool _isLoading = false;
  String? _error;
  GreenSpaceModel? _selectedSpace;

  List<GreenSpaceModel> get greenSpaces => _greenSpaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  GreenSpaceModel? get selectedSpace => _selectedSpace;

  Future<void> loadGreenSpaces() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch green spaces from Firestore
      final spacesSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .get();

      _greenSpaces = spacesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['space_id'] = doc.id; // Ensure space_id is set
        return GreenSpaceModel.fromMap(data);
      }).toList();

      // If no data in Firestore, use sample data
      if (_greenSpaces.isEmpty) {
        _greenSpaces = _getSampleGreenSpaces();
      }

      print('✅ Loaded ${_greenSpaces.length} green spaces');

    } catch (e) {
      _error = 'Failed to load green spaces: $e';
      print('❌ Error loading green spaces: $e');
      
      // Fallback to sample data
      _greenSpaces = _getSampleGreenSpaces();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load green spaces by type
  Future<void> loadGreenSpacesByType(String type) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final spacesSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .where('type', isEqualTo: type)
          .get();

      _greenSpaces = spacesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['space_id'] = doc.id;
        return GreenSpaceModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_greenSpaces.length} green spaces of type: $type');

    } catch (e) {
      _error = 'Failed to load green spaces by type: $e';
      print('❌ Error loading green spaces by type: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load green spaces by status
  Future<void> loadGreenSpacesByStatus(String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final spacesSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .where('status', isEqualTo: status)
          .get();

      _greenSpaces = spacesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['space_id'] = doc.id;
        return GreenSpaceModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_greenSpaces.length} green spaces with status: $status');

    } catch (e) {
      _error = 'Failed to load green spaces by status: $e';
      print('❌ Error loading green spaces by status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search green spaces by name or location
  Future<void> searchGreenSpaces(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (query.isEmpty) {
        await loadGreenSpaces();
        return;
      }

      final nameSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final locationSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .where('location', isGreaterThanOrEqualTo: query)
          .where('location', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      // Combine results and remove duplicates
      final allDocs = {...nameSnapshot.docs, ...locationSnapshot.docs};
      
      _greenSpaces = allDocs.map((doc) {
        final data = doc.data();
        data['space_id'] = doc.id;
        return GreenSpaceModel.fromMap(data);
      }).toList();

      print('✅ Searched green spaces: found ${_greenSpaces.length} results for "$query"');

    } catch (e) {
      _error = 'Failed to search green spaces: $e';
      print('❌ Error searching green spaces: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get green space by ID
  Future<GreenSpaceModel?> getGreenSpaceById(String spaceId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .doc(spaceId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      data['space_id'] = doc.id;
      
      return GreenSpaceModel.fromMap(data);
    } catch (e) {
      print('❌ Error getting green space by ID: $e');
      return null;
    }
  }

  /// Select a green space
  void selectSpace(GreenSpaceModel space) {
    _selectedSpace = space;
    notifyListeners();
  }

  /// Clear selected space
  void clearSelectedSpace() {
    _selectedSpace = null;
    notifyListeners();
  }

  /// Get green spaces by bounding box (for map view)
  Future<void> loadGreenSpacesInBounds(
    double north, double south, double east, double west
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // This is a simplified implementation
      // In a real app, you'd use geospatial queries
      final spacesSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreConstants.greenSpacesCollection)
          .get();

      _greenSpaces = spacesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['space_id'] = doc.id;
        return GreenSpaceModel.fromMap(data);
      }).toList();

      print('✅ Loaded ${_greenSpaces.length} green spaces in bounds');

    } catch (e) {
      _error = 'Failed to load green spaces in bounds: $e';
      print('❌ Error loading green spaces in bounds: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get statistics about green spaces
  Map<String, dynamic> getGreenSpaceStats() {
    final totalSpaces = _greenSpaces.length;
    final healthySpaces = _greenSpaces.where((space) => space.isHealthy).length;
    final degradedSpaces = _greenSpaces.where((space) => space.isDegraded).length;
    final restoredSpaces = _greenSpaces.where((space) => space.isRestored).length;
    
    final totalArea = _greenSpaces.fold<double>(0, (sum, space) => sum + space.area);
    final averageVegetationDensity = _greenSpaces.isNotEmpty 
        ? _greenSpaces.fold<int>(0, (sum, space) => sum + space.vegetationDensity) / _greenSpaces.length
        : 0;
    final averageBiodiversityIndex = _greenSpaces.isNotEmpty 
        ? _greenSpaces.fold<int>(0, (sum, space) => sum + space.biodiversityIndex) / _greenSpaces.length
        : 0;

    return {
      'total_spaces': totalSpaces,
      'healthy_spaces': healthySpaces,
      'degraded_spaces': degradedSpaces,
      'restored_spaces': restoredSpaces,
      'total_area': totalArea,
      'average_vegetation_density': averageVegetationDensity,
      'average_biodiversity_index': averageBiodiversityIndex,
      'health_percentage': totalSpaces > 0 ? (healthySpaces / totalSpaces * 100) : 0,
    };
  }

  /// Get green spaces by type
  List<GreenSpaceModel> getSpacesByType(String type) {
    return _greenSpaces.where((space) => space.type == type).toList();
  }

  /// Get green spaces by maintenance level
  List<GreenSpaceModel> getSpacesByMaintenanceLevel(String level) {
    return _greenSpaces.where((space) => space.maintenanceLevel == level).toList();
  }

  /// Get green spaces with public access
  List<GreenSpaceModel> getPublicSpaces() {
    return _greenSpaces.where((space) => space.publicAccess).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh green spaces
  Future<void> refreshGreenSpaces() async {
    await loadGreenSpaces();
  }

  /// Reset provider state
  void reset() {
    _greenSpaces.clear();
    _selectedSpace = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Sample data for fallback
  List<GreenSpaceModel> _getSampleGreenSpaces() {
    final now = DateTime.now();
    return [
      GreenSpaceModel(
        spaceId: '1',
        name: 'Central Park Garden',
        description: 'A beautiful community garden in the heart of the city with diverse plant species and walking paths.',
        location: 'Central Park, Main Street',
        boundary: {
          'type': 'polygon',
          'coordinates': [
            {'lat': 40.7128, 'lng': -74.0060},
            {'lat': 40.7129, 'lng': -74.0061},
            {'lat': 40.7130, 'lng': -74.0060},
            {'lat': 40.7129, 'lng': -74.0059},
          ]
        },
        type: 'garden',
        status: 'healthy',
        area: 5000.0,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now,
        createdBy: 'user1',
        vegetationDensity: 85,
        biodiversityIndex: 75,
        maintenanceLevel: 'high',
        publicAccess: true,
        facilities: ['benches', 'watering_system', 'lighting', 'walking_paths'],
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      GreenSpaceModel(
        spaceId: '2',
        name: 'Riverside Garden',
        description: 'Scenic garden along the river with diverse plant species and beautiful views.',
        location: 'Riverside Drive',
        boundary: {
          'type': 'polygon',
          'coordinates': [
            {'lat': 40.7228, 'lng': -74.0160},
            {'lat': 40.7229, 'lng': -74.0161},
            {'lat': 40.7230, 'lng': -74.0160},
            {'lat': 40.7229, 'lng': -74.0159},
          ]
        },
        type: 'garden',
        status: 'healthy',
        area: 7500.0,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
        createdBy: 'user2',
        vegetationDensity: 90,
        biodiversityIndex: 80,
        maintenanceLevel: 'medium',
        publicAccess: true,
        facilities: ['benches', 'walking_paths', 'information_boards'],
        latitude: 40.7228,
        longitude: -74.0160,
      ),
      GreenSpaceModel(
        spaceId: '3',
        name: 'Community Forest',
        description: 'Restored native forest with walking trails and diverse wildlife.',
        location: 'Forest Hills Area',
        boundary: {
          'type': 'polygon',
          'coordinates': [
            {'lat': 40.7328, 'lng': -74.0260},
            {'lat': 40.7329, 'lng': -74.0261},
            {'lat': 40.7330, 'lng': -74.0260},
            {'lat': 40.7329, 'lng': -74.0259},
          ]
        },
        type: 'forest',
        status: 'restored',
        area: 15000.0,
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now,
        createdBy: 'user3',
        vegetationDensity: 95,
        biodiversityIndex: 85,
        maintenanceLevel: 'low',
        publicAccess: true,
        facilities: ['walking_trails', 'bird_watching', 'picnic_areas'],
        latitude: 40.7328,
        longitude: -74.0260,
      ),
      GreenSpaceModel(
        spaceId: '4',
        name: 'Urban Orchard',
        description: 'Community orchard with fruit trees and educational programs.',
        location: 'Orchard Street',
        boundary: {
          'type': 'polygon',
          'coordinates': [
            {'lat': 40.7428, 'lng': -74.0360},
            {'lat': 40.7429, 'lng': -74.0361},
            {'lat': 40.7430, 'lng': -74.0360},
            {'lat': 40.7429, 'lng': -74.0359},
          ]
        },
        type: 'park',
        status: 'degraded',
        area: 3000.0,
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now,
        createdBy: 'user4',
        vegetationDensity: 60,
        biodiversityIndex: 50,
        maintenanceLevel: 'medium',
        publicAccess: true,
        facilities: ['fruit_trees', 'educational_signs', 'seating'],
        latitude: 40.7428,
        longitude: -74.0360,
      ),
    ];
  }
}