class EventModel {
  final String eventId;
  final String ngoId;
  final String title;
  final String description;
  final String location; // Added missing property
  final DateTime startTime;
  final DateTime? endTime; // Made nullable
  final int maxParticipants;
  final int currentParticipants; // Added missing property
  final String status; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> participants; // List of user IDs
  final List<String> tags; // Event categories/tags
  final String? imageUrl; // Event banner image
  final double? latitude; // Location coordinates
  final double? longitude; // Location coordinates
  final String contactEmail;
  final String contactPhone;
  final double? budget; // Event budget if any
  final String? requirements; // Special requirements for participants

  EventModel({
    required this.eventId,
    required this.ngoId,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    this.endTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
    this.tags = const [],
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.contactEmail,
    required this.contactPhone,
    this.budget,
    this.requirements,
  });

  // Copy with method for easy updates
  EventModel copyWith({
    String? eventId,
    String? ngoId,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? maxParticipants,
    int? currentParticipants,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? participants,
    List<String>? tags,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? contactEmail,
    String? contactPhone,
    double? budget,
    String? requirements,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      ngoId: ngoId ?? this.ngoId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      budget: budget ?? this.budget,
      requirements: requirements ?? this.requirements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'ngo_id': ngoId,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participants': participants,
      'tags': tags,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'budget': budget,
      'requirements': requirements,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    DateTime _parseToDateTime(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      try {
        // Firestore Timestamp
        if (value.runtimeType.toString().contains('Timestamp') && value.toDate != null) {
          return value.toDate();
        }
      } catch (_) {}

      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }

      return fallback ?? DateTime.now();
    }

    final start = _parseToDateTime(map['start_time']);
    final end = map['end_time'] != null ? _parseToDateTime(map['end_time'], fallback: null) : null;
    final created = _parseToDateTime(map['created_at']);
    final updated = _parseToDateTime(map['updated_at']);

    return EventModel(
      eventId: map['event_id'] ?? '',
      ngoId: map['ngo_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startTime: start,
      endTime: end,
      maxParticipants: map['max_participants'] ?? 0,
      currentParticipants: map['current_participants'] ?? 0,
      status: map['status'] ?? 'upcoming',
      createdAt: created,
      updatedAt: updated,
      participants: List<String>.from(map['participants'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['image_url'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      contactEmail: map['contact_email'] ?? '',
      contactPhone: map['contact_phone'] ?? '',
      budget: map['budget']?.toDouble(),
      requirements: map['requirements'],
    );
  }

  // Helper methods
  bool get isFull => currentParticipants >= maxParticipants;
  
  bool get canJoin => !isFull && status == 'upcoming';
  
  bool get isUpcoming => status == 'upcoming';
  
  bool get isOngoing => status == 'ongoing';
  
  bool get isCompleted => status == 'completed';
  
  bool get isCancelled => status == 'cancelled';
  
  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }
  
  bool get hasLocationCoordinates => latitude != null && longitude != null;
  
  int get remainingSpots => maxParticipants - currentParticipants;
  
  double get participationRate {
    if (maxParticipants == 0) return 0.0;
    return (currentParticipants / maxParticipants) * 100;
  }

  // Formatted getters for UI
  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  String get formattedTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  String get durationText {
    if (endTime == null) return 'No end time';
    
    final duration = this.duration;
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  String get participantsText {
    return '$currentParticipants/$maxParticipants participants';
  }

  String get statusText {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'ongoing':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // Validation methods
  bool get isValid {
    return eventId.isNotEmpty &&
        ngoId.isNotEmpty &&
        title.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        maxParticipants > 0 &&
        currentParticipants >= 0 &&
        ['upcoming', 'ongoing', 'completed', 'cancelled'].contains(status) &&
        contactEmail.isNotEmpty &&
        contactPhone.isNotEmpty;
  }

  List<String> validate() {
    final errors = <String>[];
    
    if (eventId.isEmpty) errors.add('Event ID is required');
    if (ngoId.isEmpty) errors.add('NGO ID is required');
    if (title.isEmpty) errors.add('Title is required');
    if (description.isEmpty) errors.add('Description is required');
    if (location.isEmpty) errors.add('Location is required');
    if (maxParticipants <= 0) errors.add('Max participants must be greater than 0');
    if (currentParticipants < 0) errors.add('Current participants cannot be negative');
    if (!['upcoming', 'ongoing', 'completed', 'cancelled'].contains(status)) {
      errors.add('Invalid status');
    }
    if (contactEmail.isEmpty) errors.add('Contact email is required');
    if (contactPhone.isEmpty) errors.add('Contact phone is required');
    if (startTime.isBefore(DateTime.now())) {
      errors.add('Start time cannot be in the past');
    }
    if (endTime != null && endTime!.isBefore(startTime)) {
      errors.add('End time cannot be before start time');
    }
    
    return errors;
  }

  // Static methods
  static EventModel empty() {
    return EventModel(
      eventId: '',
      ngoId: '',
      title: '',
      description: '',
      location: '',
      startTime: DateTime.now(),
      endTime: null,
      maxParticipants: 0,
      currentParticipants: 0,
      status: 'upcoming',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      contactEmail: '',
      contactPhone: '',
    );
  }

  static EventModel sample() {
    final now = DateTime.now();
    return EventModel(
      eventId: 'event_123',
      ngoId: 'ngo_456',
      title: 'Community Tree Planting',
      description: 'Join us for a community tree planting event in the local park. Help us make our city greener!',
      location: 'Central Park, Main Street',
      startTime: now.add(const Duration(days: 7)),
      endTime: now.add(const Duration(days: 7, hours: 4)),
      maxParticipants: 50,
      currentParticipants: 25,
      status: 'upcoming',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
      participants: ['user1', 'user2', 'user3'],
      tags: ['environment', 'community', 'tree-planting'],
      imageUrl: 'https://example.com/event-image.jpg',
      latitude: 40.7128,
      longitude: -74.0060,
      contactEmail: 'contact@green-ngo.org',
      contactPhone: '+1-555-0123',
      budget: 500.0,
      requirements: 'Bring gloves and water bottle',
    );
  }

  @override
  String toString() {
    return 'EventModel(eventId: $eventId, title: $title, status: $status, participants: $currentParticipants/$maxParticipants)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.eventId == eventId;
  }

  @override
  int get hashCode {
    return eventId.hashCode;
  }
}