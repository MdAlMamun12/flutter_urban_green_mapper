import 'package:urban_green_mapper/core/utils/firestore_utils.dart';

class PlantModel {
  final String plantId;
  final String spaceId;
  final String species;
  final String commonName;
  final String scientificName;
  final String description;
  final DateTime plantingDate;
  final String healthStatus; // 'excellent', 'good', 'fair', 'poor', 'critical'
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final String adoptedBy;
  final DateTime adoptionDate;
  final Map<String, dynamic> location; // GPS coordinates
  final double height; // in meters
  final double diameter; // in meters
  final String? notes;
  final List<String> images;
  final List<Map<String, dynamic>> maintenanceHistory;
  final String? soilType;
  final String? sunlightExposure;
  final String? waterRequirements;
  final String? fertilizerType;
  final DateTime? lastWatered;
  final DateTime? lastFertilized;
  final String? specialCareInstructions;
  final bool? isNativeSpecies;
  final String? conservationStatus;

  PlantModel({
    required this.plantId,
    required this.spaceId,
    required this.species,
    required this.commonName,
    required this.scientificName,
    required this.description,
    required this.plantingDate,
    required this.healthStatus,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.adoptedBy,
    required this.adoptionDate,
    required this.location,
    required this.height,
    required this.diameter,
    this.notes,
    this.images = const [],
    this.maintenanceHistory = const [],
    this.soilType,
    this.sunlightExposure,
    this.waterRequirements,
    this.fertilizerType,
    this.lastWatered,
    this.lastFertilized,
    this.specialCareInstructions,
    this.isNativeSpecies,
    this.conservationStatus,
  });

  // Copy with method for easy updates
  PlantModel copyWith({
    String? plantId,
    String? spaceId,
    String? species,
    String? commonName,
    String? scientificName,
    String? description,
    DateTime? plantingDate,
    String? healthStatus,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    String? adoptedBy,
    DateTime? adoptionDate,
    Map<String, dynamic>? location,
    double? height,
    double? diameter,
    String? notes,
    List<String>? images,
    List<Map<String, dynamic>>? maintenanceHistory,
    String? soilType,
    String? sunlightExposure,
    String? waterRequirements,
    String? fertilizerType,
    DateTime? lastWatered,
    DateTime? lastFertilized,
    String? specialCareInstructions,
    bool? isNativeSpecies,
    String? conservationStatus,
  }) {
    return PlantModel(
      plantId: plantId ?? this.plantId,
      spaceId: spaceId ?? this.spaceId,
      species: species ?? this.species,
      commonName: commonName ?? this.commonName,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      plantingDate: plantingDate ?? this.plantingDate,
      healthStatus: healthStatus ?? this.healthStatus,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      adoptedBy: adoptedBy ?? this.adoptedBy,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      location: location ?? this.location,
      height: height ?? this.height,
      diameter: diameter ?? this.diameter,
      notes: notes ?? this.notes,
      images: images ?? this.images,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      soilType: soilType ?? this.soilType,
      sunlightExposure: sunlightExposure ?? this.sunlightExposure,
      waterRequirements: waterRequirements ?? this.waterRequirements,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      lastWatered: lastWatered ?? this.lastWatered,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      specialCareInstructions: specialCareInstructions ?? this.specialCareInstructions,
      isNativeSpecies: isNativeSpecies ?? this.isNativeSpecies,
      conservationStatus: conservationStatus ?? this.conservationStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plant_id': plantId,
      'space_id': spaceId,
      'species': species,
      'common_name': commonName,
      'scientific_name': scientificName,
      'description': description,
      'planting_date': plantingDate.toIso8601String(),
      'health_status': healthStatus,
      'last_maintenance': lastMaintenance.toIso8601String(),
      'next_maintenance': nextMaintenance.toIso8601String(),
      'adopted_by': adoptedBy,
      'adoption_date': adoptionDate.toIso8601String(),
      'location': location,
      'height': height,
      'diameter': diameter,
      'notes': notes,
      'images': images,
      'maintenance_history': maintenanceHistory,
      'soil_type': soilType,
      'sunlight_exposure': sunlightExposure,
      'water_requirements': waterRequirements,
      'fertilizer_type': fertilizerType,
      'last_watered': lastWatered?.toIso8601String(),
      'last_fertilized': lastFertilized?.toIso8601String(),
      'special_care_instructions': specialCareInstructions,
      'is_native_species': isNativeSpecies,
      'conservation_status': conservationStatus,
    };
  }

  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      plantId: map['plant_id'] ?? '',
      spaceId: map['space_id'] ?? '',
      species: map['species'] ?? '',
      commonName: map['common_name'] ?? '',
      scientificName: map['scientific_name'] ?? '',
      description: map['description'] ?? '',
      plantingDate: parseFirestoreDateTime(map['planting_date']) ?? DateTime.now(),
      healthStatus: map['health_status'] ?? 'good',
      lastMaintenance: parseFirestoreDateTime(map['last_maintenance']) ?? DateTime.now(),
      nextMaintenance: parseFirestoreDateTime(map['next_maintenance']) ?? DateTime.now().add(const Duration(days: 7)),
      adoptedBy: map['adopted_by'] ?? '',
      adoptionDate: parseFirestoreDateTime(map['adoption_date']) ?? DateTime.now(),
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      height: (map['height'] ?? 0.0).toDouble(),
      diameter: (map['diameter'] ?? 0.0).toDouble(),
      notes: map['notes'],
      images: List<String>.from(map['images'] ?? []),
      maintenanceHistory: List<Map<String, dynamic>>.from(map['maintenance_history'] ?? []),
      soilType: map['soil_type'],
      sunlightExposure: map['sunlight_exposure'],
      waterRequirements: map['water_requirements'],
      fertilizerType: map['fertilizer_type'],
      lastWatered: parseFirestoreDateTime(map['last_watered']),
      lastFertilized: parseFirestoreDateTime(map['last_fertilized']),
      specialCareInstructions: map['special_care_instructions'],
      isNativeSpecies: map['is_native_species'],
      conservationStatus: map['conservation_status'],
    );
  }

  // Helper methods
  bool get isHealthy => healthStatus == 'excellent' || healthStatus == 'good';
  bool get needsAttention => healthStatus == 'poor' || healthStatus == 'critical';
  
  bool get needsWatering {
    if (lastWatered == null) return true;
    final daysSinceWatering = DateTime.now().difference(lastWatered!).inDays;
    return daysSinceWatering >= 2; // Assume plants need watering every 2 days
  }
  
  bool get needsFertilizing {
    if (lastFertilized == null) return true;
    final daysSinceFertilizing = DateTime.now().difference(lastFertilized!).inDays;
    return daysSinceFertilizing >= 30; // Assume fertilizing every 30 days
  }

  String get healthStatusText {
    switch (healthStatus) {
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      case 'poor':
        return 'Poor';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String get ageText {
    final age = DateTime.now().difference(plantingDate);
    if (age.inDays < 30) {
      return '${age.inDays} days';
    } else if (age.inDays < 365) {
      return '${(age.inDays / 30).toStringAsFixed(1)} months';
    } else {
      return '${(age.inDays / 365).toStringAsFixed(1)} years';
    }
  }

  String get adoptionDurationText {
    final duration = DateTime.now().difference(adoptionDate);
    if (duration.inDays < 30) {
      return '${duration.inDays} days';
    } else if (duration.inDays < 365) {
      return '${(duration.inDays / 30).toStringAsFixed(1)} months';
    } else {
      return '${(duration.inDays / 365).toStringAsFixed(1)} years';
    }
  }

  // Validation methods
  bool get isValid {
    return plantId.isNotEmpty &&
        spaceId.isNotEmpty &&
        species.isNotEmpty &&
        commonName.isNotEmpty &&
        height > 0 &&
        diameter >= 0;
  }

  List<String> validate() {
    final errors = <String>[];
    
    if (plantId.isEmpty) errors.add('Plant ID is required');
    if (spaceId.isEmpty) errors.add('Space ID is required');
    if (species.isEmpty) errors.add('Species is required');
    if (commonName.isEmpty) errors.add('Common name is required');
    if (height <= 0) errors.add('Height must be greater than 0');
    if (diameter < 0) errors.add('Diameter cannot be negative');
    if (adoptedBy.isEmpty) errors.add('Adopter information is required');
    
    return errors;
  }

  // Static methods
  static PlantModel empty() {
    return PlantModel(
      plantId: '',
      spaceId: '',
      species: '',
      commonName: '',
      scientificName: '',
      description: '',
      plantingDate: DateTime.now(),
      healthStatus: 'good',
      lastMaintenance: DateTime.now(),
      nextMaintenance: DateTime.now().add(const Duration(days: 7)),
      adoptedBy: '',
      adoptionDate: DateTime.now(),
      location: {},
      height: 0.0,
      diameter: 0.0,
    );
  }

  static PlantModel sample() {
    final now = DateTime.now();
    return PlantModel(
      plantId: 'plant_123',
      spaceId: 'space_456',
      species: 'Oak Tree',
      commonName: 'Northern Red Oak',
      scientificName: 'Quercus rubra',
      description: 'A majestic native oak tree known for its beautiful fall foliage and strong wood.',
      plantingDate: now.subtract(const Duration(days: 30)),
      healthStatus: 'good',
      lastMaintenance: now.subtract(const Duration(days: 7)),
      nextMaintenance: now.add(const Duration(days: 7)),
      adoptedBy: 'user123',
      adoptionDate: now.subtract(const Duration(days: 30)),
      location: {'lat': 40.7128, 'lng': -74.0060},
      height: 2.5,
      diameter: 0.15,
      notes: 'Growing well, needs regular watering during dry spells',
      images: ['https://example.com/oak-tree.jpg'],
      maintenanceHistory: [
        {
          'date': now.subtract(const Duration(days: 7)),
          'type': 'watering',
          'notes': 'Regular watering',
          'performed_by': 'user123'
        },
        {
          'date': now.subtract(const Duration(days: 14)),
          'type': 'pruning',
          'notes': 'Light pruning of dead branches',
          'performed_by': 'user123'
        }
      ],
      soilType: 'loamy',
      sunlightExposure: 'full_sun',
      waterRequirements: 'moderate',
      fertilizerType: 'organic',
      lastWatered: now.subtract(const Duration(days: 1)),
      lastFertilized: now.subtract(const Duration(days: 15)),
      specialCareInstructions: 'Protect from strong winds',
      isNativeSpecies: true,
      conservationStatus: 'least_concern',
    );
  }

  @override
  String toString() {
    return 'PlantModel(plantId: $plantId, species: $species, health: $healthStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlantModel && other.plantId == plantId;
  }

  @override
  int get hashCode {
    return plantId.hashCode;
  }
}