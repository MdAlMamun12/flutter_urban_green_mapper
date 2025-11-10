class AdoptionModel {
  final String adoptionId;
  final String userId;
  final String plantId;
  final String status; // 'active', 'completed', 'released', 'cancelled', 'pending'
  final DateTime adoptedAt;
  final DateTime? completedAt;
  final DateTime? releasedAt;
  final DateTime? cancelledAt;
  final DateTime lastCareDate;
  final Map<String, dynamic> careSchedule;
  final String? notes;
  final int carePoints;
  final int totalCareActivities;
  final List<String>? carePhotos;
  final Map<String, dynamic>? plantDetails;

  AdoptionModel({
    required this.adoptionId,
    required this.userId,
    required this.plantId,
    required this.status,
    required this.adoptedAt,
    this.completedAt,
    this.releasedAt,
    this.cancelledAt,
    required this.lastCareDate,
    required this.careSchedule,
    this.notes,
    this.carePoints = 0,
    this.totalCareActivities = 0,
    this.carePhotos,
    this.plantDetails,
  });

  // Convert AdoptionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'adoption_id': adoptionId,
      'user_id': userId,
      'plant_id': plantId,
      'status': status,
      'adopted_at': adoptedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'released_at': releasedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'last_care_date': lastCareDate.toIso8601String(),
      'care_schedule': careSchedule,
      'notes': notes,
      'care_points': carePoints,
      'total_care_activities': totalCareActivities,
      'care_photos': carePhotos,
      'plant_details': plantDetails,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create AdoptionModel from Map (from Firestore)
  factory AdoptionModel.fromMap(Map<String, dynamic> map) {
    return AdoptionModel(
      adoptionId: map['adoption_id'] ?? '',
      userId: map['user_id'] ?? '',
      plantId: map['plant_id'] ?? '',
      status: map['status'] ?? 'active',
      adoptedAt: DateTime.parse(map['adopted_at']),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      releasedAt: map['released_at'] != null ? DateTime.parse(map['released_at']) : null,
      cancelledAt: map['cancelled_at'] != null ? DateTime.parse(map['cancelled_at']) : null,
      lastCareDate: DateTime.parse(map['last_care_date']),
      careSchedule: Map<String, dynamic>.from(map['care_schedule'] ?? {}),
      notes: map['notes'],
      carePoints: map['care_points'] ?? 0,
      totalCareActivities: map['total_care_activities'] ?? 0,
      carePhotos: map['care_photos'] != null ? List<String>.from(map['care_photos']) : null,
      plantDetails: map['plant_details'] != null ? Map<String, dynamic>.from(map['plant_details']) : null,
    );
  }

  // Create a copy of AdoptionModel with updated values
  AdoptionModel copyWith({
    String? adoptionId,
    String? userId,
    String? plantId,
    String? status,
    DateTime? adoptedAt,
    DateTime? completedAt,
    DateTime? releasedAt,
    DateTime? cancelledAt,
    DateTime? lastCareDate,
    Map<String, dynamic>? careSchedule,
    String? notes,
    int? carePoints,
    int? totalCareActivities,
    List<String>? carePhotos,
    Map<String, dynamic>? plantDetails,
  }) {
    return AdoptionModel(
      adoptionId: adoptionId ?? this.adoptionId,
      userId: userId ?? this.userId,
      plantId: plantId ?? this.plantId,
      status: status ?? this.status,
      adoptedAt: adoptedAt ?? this.adoptedAt,
      completedAt: completedAt ?? this.completedAt,
      releasedAt: releasedAt ?? this.releasedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      lastCareDate: lastCareDate ?? this.lastCareDate,
      careSchedule: careSchedule ?? this.careSchedule,
      notes: notes ?? this.notes,
      carePoints: carePoints ?? this.carePoints,
      totalCareActivities: totalCareActivities ?? this.totalCareActivities,
      carePhotos: carePhotos ?? this.carePhotos,
      plantDetails: plantDetails ?? this.plantDetails,
    );
  }

  // Mark adoption as completed
  AdoptionModel markAsCompleted() {
    return copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
    );
  }

  // Mark adoption as released
  AdoptionModel markAsReleased() {
    return copyWith(
      status: 'released',
      releasedAt: DateTime.now(),
    );
  }

  // Mark adoption as cancelled
  AdoptionModel markAsCancelled() {
    return copyWith(
      status: 'cancelled',
      cancelledAt: DateTime.now(),
    );
  }

  // Update last care date
  AdoptionModel updateLastCareDate() {
    return copyWith(
      lastCareDate: DateTime.now(),
    );
  }

  // Add care points
  AdoptionModel addCarePoints(int points) {
    return copyWith(
      carePoints: carePoints + points,
      totalCareActivities: totalCareActivities + 1,
    );
  }

  // Update care schedule
  AdoptionModel updateCareSchedule(Map<String, dynamic> newSchedule) {
    final updatedSchedule = Map<String, dynamic>.from(careSchedule);
    updatedSchedule.addAll(newSchedule);
    return copyWith(careSchedule: updatedSchedule);
  }

  // Add care photo
  AdoptionModel addCarePhoto(String photoUrl) {
    final updatedPhotos = List<String>.from(carePhotos ?? []);
    updatedPhotos.add(photoUrl);
    return copyWith(carePhotos: updatedPhotos);
  }

  // Update plant details
  AdoptionModel updatePlantDetails(Map<String, dynamic> details) {
    final updatedDetails = Map<String, dynamic>.from(plantDetails ?? {});
    updatedDetails.addAll(details);
    return copyWith(plantDetails: updatedDetails);
  }

  // Check if adoption is active
  bool get isActive => status == 'active';

  // Check if adoption is completed
  bool get isCompleted => status == 'completed';

  // Check if adoption is released
  bool get isReleased => status == 'released';

  // Check if adoption is cancelled
  bool get isCancelled => status == 'cancelled';

  // Get adoption duration in days
  int get adoptionDuration {
    final endDate = completedAt ?? releasedAt ?? cancelledAt ?? DateTime.now();
    final duration = endDate.difference(adoptedAt);
    return duration.inDays;
  }

  // Check if care is overdue
  bool get isCareOverdue {
    final nextWatering = careSchedule['next_watering'] != null 
        ? DateTime.parse(careSchedule['next_watering'])
        : null;
    return nextWatering != null && nextWatering.isBefore(DateTime.now());
  }

  // Get days until next watering
  int get daysUntilNextWatering {
    final nextWatering = careSchedule['next_watering'] != null 
        ? DateTime.parse(careSchedule['next_watering'])
        : null;
    if (nextWatering == null) return 0;
    final difference = nextWatering.difference(DateTime.now());
    return difference.inDays;
  }

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'active':
        return '#4CAF50'; // Green
      case 'completed':
        return '#2196F3'; // Blue
      case 'released':
        return '#FF9800'; // Orange
      case 'cancelled':
        return '#F44336'; // Red
      case 'pending':
        return '#9C27B0'; // Purple
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status text for display
  String get statusText {
    switch (status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'released':
        return 'Released';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending Approval';
      default:
        return 'Unknown';
    }
  }

  // Get status icon for UI
  String get statusIcon {
    switch (status) {
      case 'active':
        return '🌱';
      case 'completed':
        return '✅';
      case 'released':
        return '🔄';
      case 'cancelled':
        return '❌';
      case 'pending':
        return '⏳';
      default:
        return '❓';
    }
  }

  // Get care level based on care points
  String get careLevel {
    if (carePoints >= 100) return 'Expert Gardener';
    if (carePoints >= 50) return 'Dedicated Caretaker';
    if (carePoints >= 20) return 'Regular Caretaker';
    if (carePoints >= 10) return 'Beginner Gardener';
    return 'New Adopter';
  }

  // Validate adoption data
  List<String> validate() {
    final errors = <String>[];

    if (adoptionId.isEmpty) {
      errors.add('Adoption ID is required');
    }

    if (userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (plantId.isEmpty) {
      errors.add('Plant ID is required');
    }

    if (!['active', 'completed', 'released', 'cancelled', 'pending'].contains(status)) {
      errors.add('Invalid adoption status');
    }

    if (adoptedAt.isAfter(DateTime.now())) {
      errors.add('Adoption date cannot be in the future');
    }

    if (completedAt != null && completedAt!.isBefore(adoptedAt)) {
      errors.add('Completion date cannot be before adoption date');
    }

    if (releasedAt != null && releasedAt!.isBefore(adoptedAt)) {
      errors.add('Release date cannot be before adoption date');
    }

    if (cancelledAt != null && cancelledAt!.isBefore(adoptedAt)) {
      errors.add('Cancellation date cannot be before adoption date');
    }

    if (lastCareDate.isAfter(DateTime.now())) {
      errors.add('Last care date cannot be in the future');
    }

    if (carePoints < 0) {
      errors.add('Care points cannot be negative');
    }

    if (totalCareActivities < 0) {
      errors.add('Total care activities cannot be negative');
    }

    return errors;
  }

  // Check if adoption is valid
  bool get isValid => validate().isEmpty;

  // Convert to JSON string
  String toJson() {
    return '''
    {
      "adoption_id": "$adoptionId",
      "user_id": "$userId",
      "plant_id": "$plantId",
      "status": "$status",
      "adopted_at": "${adoptedAt.toIso8601String()}",
      "completed_at": ${completedAt != null ? '"${completedAt!.toIso8601String()}"' : 'null'},
      "released_at": ${releasedAt != null ? '"${releasedAt!.toIso8601String()}"' : 'null'},
      "cancelled_at": ${cancelledAt != null ? '"${cancelledAt!.toIso8601String()}"' : 'null'},
      "last_care_date": "${lastCareDate.toIso8601String()}",
      "care_schedule": ${_mapToJson(careSchedule)},
      "notes": ${notes != null ? '"$notes"' : 'null'},
      "care_points": $carePoints,
      "total_care_activities": $totalCareActivities,
      "care_photos": ${carePhotos != null ? _listToJson(carePhotos!) : 'null'},
      "plant_details": ${plantDetails != null ? _mapToJson(plantDetails!) : 'null'}
    }
    ''';
  }

  String _mapToJson(Map<String, dynamic> map) {
    final entries = map.entries.map((entry) {
      if (entry.value is String) {
        return '"${entry.key}": "${entry.value}"';
      } else if (entry.value is num) {
        return '"${entry.key}": ${entry.value}';
      } else if (entry.value is bool) {
        return '"${entry.key}": ${entry.value}';
      } else if (entry.value is DateTime) {
        return '"${entry.key}": "${entry.value.toIso8601String()}"';
      } else {
        return '"${entry.key}": "${entry.value.toString()}"';
      }
    });
    return '{${entries.join(',')}}';
  }

  String _listToJson(List<String> list) {
    return '[${list.map((item) => '"$item"').join(',')}]';
  }

  @override
  String toString() {
    return 'AdoptionModel(adoptionId: $adoptionId, userId: $userId, plantId: $plantId, status: $status, carePoints: $carePoints)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdoptionModel &&
        other.adoptionId == adoptionId &&
        other.userId == userId &&
        other.plantId == plantId &&
        other.status == status &&
        other.adoptedAt == adoptedAt &&
        other.carePoints == carePoints;
  }

  @override
  int get hashCode {
    return adoptionId.hashCode ^
        userId.hashCode ^
        plantId.hashCode ^
        status.hashCode ^
        adoptedAt.hashCode ^
        carePoints.hashCode;
  }
}

// Extension methods for List<AdoptionModel>
extension AdoptionListExtensions on List<AdoptionModel> {
  // Filter adoptions by status
  List<AdoptionModel> filterByStatus(String status) {
    return where((adoption) => adoption.status == status).toList();
  }

  // Get all active adoptions
  List<AdoptionModel> get active {
    return filterByStatus('active');
  }

  // Get all completed adoptions
  List<AdoptionModel> get completed {
    return filterByStatus('completed');
  }

  // Get all released adoptions
  List<AdoptionModel> get released {
    return filterByStatus('released');
  }

  // Get all cancelled adoptions
  List<AdoptionModel> get cancelled {
    return filterByStatus('cancelled');
  }

  // Get total care points
  int get totalCarePoints {
    return fold(0, (sum, adoption) => sum + adoption.carePoints);
  }

  // Get total care activities
  int get totalCareActivities {
    return fold(0, (sum, adoption) => sum + adoption.totalCareActivities);
  }

  // Get adoptions that need care (overdue)
  List<AdoptionModel> get needCare {
    return where((adoption) => adoption.isCareOverdue).toList();
  }

  // Group adoptions by plant ID
  Map<String, List<AdoptionModel>> groupByPlant() {
    final Map<String, List<AdoptionModel>> grouped = {};
    for (final adoption in this) {
      grouped.putIfAbsent(adoption.plantId, () => []).add(adoption);
    }
    return grouped;
  }

  // Sort by adoption date (newest first)
  List<AdoptionModel> sortedByAdoptionDate() {
    return List.from(this)..sort((a, b) => b.adoptedAt.compareTo(a.adoptedAt));
  }

  // Sort by care points (highest first)
  List<AdoptionModel> sortedByCarePoints() {
    return List.from(this)..sort((a, b) => b.carePoints.compareTo(a.carePoints));
  }

  // Check if user has adopted a plant
  bool hasAdoptedPlant(String userId, String plantId) {
    return any((adoption) => 
        adoption.userId == userId && 
        adoption.plantId == plantId && 
        adoption.isActive);
  }

  // Get user's adoption for a plant
  AdoptionModel? getUserAdoption(String userId, String plantId) {
    try {
      return firstWhere((adoption) =>
          adoption.userId == userId && 
          adoption.plantId == plantId);
    } catch (e) {
      return null;
    }
  }
}

// Helper class for creating adoption records
class AdoptionBuilder {
  String _adoptionId = '';
  String _userId = '';
  String _plantId = '';
  String _status = 'active';
  DateTime _adoptedAt = DateTime.now();
  DateTime? _completedAt;
  DateTime? _releasedAt;
  DateTime? _cancelledAt;
  DateTime _lastCareDate = DateTime.now();
  Map<String, dynamic> _careSchedule = {};
  String? _notes;
  int _carePoints = 0;
  int _totalCareActivities = 0;
  List<String>? _carePhotos;
  Map<String, dynamic>? _plantDetails;

  AdoptionBuilder();

  AdoptionBuilder withId(String id) {
    _adoptionId = id;
    return this;
  }

  AdoptionBuilder forUser(String userId) {
    _userId = userId;
    return this;
  }

  AdoptionBuilder forPlant(String plantId) {
    _plantId = plantId;
    return this;
  }

  AdoptionBuilder withStatus(String status) {
    _status = status;
    return this;
  }

  AdoptionBuilder adoptedAt(DateTime date) {
    _adoptedAt = date;
    return this;
  }

  AdoptionBuilder completedAt(DateTime? date) {
    _completedAt = date;
    return this;
  }

  AdoptionBuilder releasedAt(DateTime? date) {
    _releasedAt = date;
    return this;
  }

  AdoptionBuilder cancelledAt(DateTime? date) {
    _cancelledAt = date;
    return this;
  }

  AdoptionBuilder withLastCareDate(DateTime date) {
    _lastCareDate = date;
    return this;
  }

  AdoptionBuilder withCareSchedule(Map<String, dynamic> schedule) {
    _careSchedule = schedule;
    return this;
  }

  AdoptionBuilder withNotes(String notes) {
    _notes = notes;
    return this;
  }

  AdoptionBuilder withCarePoints(int points) {
    _carePoints = points;
    return this;
  }

  AdoptionBuilder withTotalCareActivities(int activities) {
    _totalCareActivities = activities;
    return this;
  }

  AdoptionBuilder withCarePhotos(List<String> photos) {
    _carePhotos = photos;
    return this;
  }

  AdoptionBuilder withPlantDetails(Map<String, dynamic> details) {
    _plantDetails = details;
    return this;
  }

  AdoptionModel build() {
    return AdoptionModel(
      adoptionId: _adoptionId,
      userId: _userId,
      plantId: _plantId,
      status: _status,
      adoptedAt: _adoptedAt,
      completedAt: _completedAt,
      releasedAt: _releasedAt,
      cancelledAt: _cancelledAt,
      lastCareDate: _lastCareDate,
      careSchedule: _careSchedule,
      notes: _notes,
      carePoints: _carePoints,
      totalCareActivities: _totalCareActivities,
      carePhotos: _carePhotos,
      plantDetails: _plantDetails,
    );
  }
}