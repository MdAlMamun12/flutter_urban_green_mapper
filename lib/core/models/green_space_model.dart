import 'package:urban_green_mapper/core/utils/firestore_utils.dart';

class GreenSpaceModel {
  final String spaceId;
  final String name;
  final String description;
  final String location;
  final Map<String, dynamic> boundary; // POLYGON data
  final String type; // 'park', 'garden', 'forest'
  final String status; // 'healthy', 'degraded', 'restored', 'critical'
  final double area; // Area in square meters
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final int vegetationDensity; // Percentage
  final int biodiversityIndex; // Percentage
  final String maintenanceLevel; // 'low', 'medium', 'high'
  final bool publicAccess;
  final List<String> facilities; // Available facilities
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String>? tags;
  final int? treeCount;
  final int? plantSpeciesCount;
  final String? soilType;
  final String? irrigationSystem;
  final String? managementOrganization;

  GreenSpaceModel({
    required this.spaceId,
    required this.name,
    required this.description,
    required this.location,
    required this.boundary,
    required this.type,
    required this.status,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.vegetationDensity,
    required this.biodiversityIndex,
    required this.maintenanceLevel,
    required this.publicAccess,
    required this.facilities,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.tags,
    this.treeCount,
    this.plantSpeciesCount,
    this.soilType,
    this.irrigationSystem,
    this.managementOrganization,
  });

  // Copy with method for easy updates
  GreenSpaceModel copyWith({
    String? spaceId,
    String? name,
    String? description,
    String? location,
    Map<String, dynamic>? boundary,
    String? type,
    String? status,
    double? area,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    int? vegetationDensity,
    int? biodiversityIndex,
    String? maintenanceLevel,
    bool? publicAccess,
    List<String>? facilities,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? tags,
    int? treeCount,
    int? plantSpeciesCount,
    String? soilType,
    String? irrigationSystem,
    String? managementOrganization,
  }) {
    return GreenSpaceModel(
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      boundary: boundary ?? this.boundary,
      type: type ?? this.type,
      status: status ?? this.status,
      area: area ?? this.area,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      vegetationDensity: vegetationDensity ?? this.vegetationDensity,
      biodiversityIndex: biodiversityIndex ?? this.biodiversityIndex,
      maintenanceLevel: maintenanceLevel ?? this.maintenanceLevel,
      publicAccess: publicAccess ?? this.publicAccess,
      facilities: facilities ?? this.facilities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      treeCount: treeCount ?? this.treeCount,
      plantSpeciesCount: plantSpeciesCount ?? this.plantSpeciesCount,
      soilType: soilType ?? this.soilType,
      irrigationSystem: irrigationSystem ?? this.irrigationSystem,
      managementOrganization: managementOrganization ?? this.managementOrganization,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'space_id': spaceId,
      'name': name,
      'description': description,
      'location': location,
      'boundary': boundary,
      'type': type,
      'status': status,
      'area': area,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'vegetation_density': vegetationDensity,
      'biodiversity_index': biodiversityIndex,
      'maintenance_level': maintenanceLevel,
      'public_access': publicAccess,
      'facilities': facilities,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'tags': tags,
      'tree_count': treeCount,
      'plant_species_count': plantSpeciesCount,
      'soil_type': soilType,
      'irrigation_system': irrigationSystem,
      'management_organization': managementOrganization,
    };
  }

  factory GreenSpaceModel.fromMap(Map<String, dynamic> map) {
    return GreenSpaceModel(
      spaceId: map['space_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      boundary: Map<String, dynamic>.from(map['boundary'] ?? {}),
      type: map['type'] ?? 'park',
      status: map['status'] ?? 'healthy',
      area: (map['area'] ?? 0.0).toDouble(),
    createdAt: parseFirestoreDateTime(map['created_at']) ?? DateTime.now(),
    updatedAt: parseFirestoreDateTime(map['updated_at']) ?? DateTime.now(),
      createdBy: map['created_by'] ?? '',
      vegetationDensity: map['vegetation_density'] ?? 0,
      biodiversityIndex: map['biodiversity_index'] ?? 0,
      maintenanceLevel: map['maintenance_level'] ?? 'medium',
      publicAccess: map['public_access'] ?? true,
      facilities: List<String>.from(map['facilities'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      imageUrl: map['image_url'],
      tags: List<String>.from(map['tags'] ?? []),
      treeCount: map['tree_count'],
      plantSpeciesCount: map['plant_species_count'],
      soilType: map['soil_type'],
      irrigationSystem: map['irrigation_system'],
      managementOrganization: map['management_organization'],
    );
  }

  // Helper methods
  bool get isHealthy => status == 'healthy';
  bool get isDegraded => status == 'degraded';
  bool get isRestored => status == 'restored';
  bool get isCritical => status == 'critical';

  String get statusText {
    switch (status) {
      case 'healthy':
        return 'Healthy';
      case 'degraded':
        return 'Degraded';
      case 'restored':
        return 'Restored';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String get typeText {
    switch (type) {
      case 'park':
        return 'Park';
      case 'garden':
        return 'Garden';
      case 'forest':
        return 'Forest';
      case 'wetland':
        return 'Wetland';
      default:
        return 'Green Space';
    }
  }

  String get areaText {
    if (area < 1000) {
      return '${area.toStringAsFixed(0)} m²';
    } else {
      return '${(area / 1000).toStringAsFixed(1)} ha';
    }
  }

  String get maintenanceLevelText {
    switch (maintenanceLevel) {
      case 'low':
        return 'Low Maintenance';
      case 'medium':
        return 'Medium Maintenance';
      case 'high':
        return 'High Maintenance';
      default:
        return 'Unknown';
    }
  }

  // Validation methods
  bool get isValid {
    return spaceId.isNotEmpty &&
        name.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        boundary.isNotEmpty &&
        area > 0 &&
        vegetationDensity >= 0 &&
        vegetationDensity <= 100 &&
        biodiversityIndex >= 0 &&
        biodiversityIndex <= 100;
  }

  List<String> validate() {
    final errors = <String>[];
    
    if (spaceId.isEmpty) errors.add('Space ID is required');
    if (name.isEmpty) errors.add('Name is required');
    if (description.isEmpty) errors.add('Description is required');
    if (location.isEmpty) errors.add('Location is required');
    if (boundary.isEmpty) errors.add('Boundary data is required');
    if (area <= 0) errors.add('Area must be greater than 0');
    if (vegetationDensity < 0 || vegetationDensity > 100) {
      errors.add('Vegetation density must be between 0 and 100');
    }
    if (biodiversityIndex < 0 || biodiversityIndex > 100) {
      errors.add('Biodiversity index must be between 0 and 100');
    }
    
    return errors;
  }

  // Static methods
  static GreenSpaceModel empty() {
    return GreenSpaceModel(
      spaceId: '',
      name: '',
      description: '',
      location: '',
      boundary: {},
      type: 'park',
      status: 'healthy',
      area: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: '',
      vegetationDensity: 0,
      biodiversityIndex: 0,
      maintenanceLevel: 'medium',
      publicAccess: true,
      facilities: [],
    );
  }

  static GreenSpaceModel sample() {
    return GreenSpaceModel(
      spaceId: 'space_123',
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
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
      createdBy: 'user123',
      vegetationDensity: 85,
      biodiversityIndex: 75,
      maintenanceLevel: 'high',
      publicAccess: true,
      facilities: ['benches', 'watering_system', 'lighting', 'walking_paths'],
      latitude: 40.7128,
      longitude: -74.0060,
      imageUrl: 'https://example.com/garden.jpg',
      tags: ['community', 'garden', 'public'],
      treeCount: 150,
      plantSpeciesCount: 45,
      soilType: 'loamy',
      irrigationSystem: 'sprinkler',
      managementOrganization: 'City Parks Department',
    );
  }

  @override
  String toString() {
    return 'GreenSpaceModel(spaceId: $spaceId, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GreenSpaceModel && other.spaceId == spaceId;
  }

  @override
  int get hashCode {
    return spaceId.hashCode;
  }
}