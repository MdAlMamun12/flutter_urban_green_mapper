import 'dart:convert';
import 'package:urban_green_mapper/core/utils/firestore_utils.dart';

class ParticipationModel {
  final String participationId;
  final String userId;
  final String eventId;
  final int hoursContributed;
  final String status; // 'registered', 'attended', 'cancelled'
  final DateTime joinedAt;
  final DateTime? attendedAt;
  final DateTime? cancelledAt;
  final String? feedback;
  final int? rating;
  final Map<String, dynamic>? additionalData;

  ParticipationModel({
    required this.participationId,
    required this.userId,
    required this.eventId,
    this.hoursContributed = 0,
    required this.status,
    required this.joinedAt,
    this.attendedAt,
    this.cancelledAt,
    this.feedback,
    this.rating,
    this.additionalData,
  });

  // Convert ParticipationModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'participation_id': participationId,
      'user_id': userId,
      'event_id': eventId,
      'hours_contributed': hoursContributed,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
      'attended_at': attendedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'feedback': feedback,
      'rating': rating,
      'additional_data': additionalData,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create ParticipationModel from Map (from Firestore)
  factory ParticipationModel.fromMap(Map<String, dynamic> map) {
    return ParticipationModel(
      participationId: map['participation_id'] ?? '',
      userId: map['user_id'] ?? '',
      eventId: map['event_id'] ?? '',
      hoursContributed: map['hours_contributed'] ?? 0,
      status: map['status'] ?? 'registered',
    joinedAt: parseFirestoreDateTime(map['joined_at']) ?? DateTime.now(),
    attendedAt: parseFirestoreDateTime(map['attended_at']),
    cancelledAt: parseFirestoreDateTime(map['cancelled_at']),
      feedback: map['feedback'],
      rating: map['rating'],
      additionalData: map['additional_data'] != null 
          ? Map<String, dynamic>.from(map['additional_data'])
          : null,
    );
  }

  // Create a copy of ParticipationModel with updated values
  ParticipationModel copyWith({
    String? participationId,
    String? userId,
    String? eventId,
    int? hoursContributed,
    String? status,
    DateTime? joinedAt,
    DateTime? attendedAt,
    DateTime? cancelledAt,
    String? feedback,
    int? rating,
    Map<String, dynamic>? additionalData,
  }) {
    return ParticipationModel(
      participationId: participationId ?? this.participationId,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      hoursContributed: hoursContributed ?? this.hoursContributed,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      attendedAt: attendedAt ?? this.attendedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Mark participation as attended
  ParticipationModel markAsAttended({int hours = 0, String? feedback, int? rating}) {
    return copyWith(
      status: 'attended',
      hoursContributed: hours,
      attendedAt: DateTime.now(),
      feedback: feedback,
      rating: rating,
    );
  }

  // Mark participation as cancelled
  ParticipationModel markAsCancelled() {
    return copyWith(
      status: 'cancelled',
      cancelledAt: DateTime.now(),
    );
  }

  // Update hours contributed
  ParticipationModel updateHours(int hours) {
    return copyWith(
      hoursContributed: hours,
    );
  }

  // Add feedback and rating
  ParticipationModel addFeedback(String feedback, int rating) {
    return copyWith(
      feedback: feedback,
      rating: rating,
    );
  }

  // Check if participation is active (not cancelled)
  bool get isActive => status != 'cancelled';

  // Check if user attended the event
  bool get hasAttended => status == 'attended';

  // Check if participation can be cancelled (only if not already attended or cancelled)
  bool get canCancel => status == 'registered';

  // Check if feedback can be provided (only if attended and no feedback given yet)
  bool get canProvideFeedback => hasAttended && feedback == null;

  // Get participation duration in hours
  double get participationDuration {
    if (attendedAt != null) {
      final duration = attendedAt!.difference(joinedAt);
      return duration.inHours.toDouble();
    }
    return 0.0;
  }

  // Validate participation data
  List<String> validate() {
    final errors = <String>[];

    if (participationId.isEmpty) {
      errors.add('Participation ID is required');
    }

    if (userId.isEmpty) {
      errors.add('User ID is required');
    }

    if (eventId.isEmpty) {
      errors.add('Event ID is required');
    }

    if (hoursContributed < 0) {
      errors.add('Hours contributed cannot be negative');
    }

    if (!['registered', 'attended', 'cancelled'].contains(status)) {
      errors.add('Invalid participation status');
    }

    if (joinedAt.isAfter(DateTime.now())) {
      errors.add('Join date cannot be in the future');
    }

    if (attendedAt != null && attendedAt!.isBefore(joinedAt)) {
      errors.add('Attended date cannot be before join date');
    }

    if (cancelledAt != null && cancelledAt!.isBefore(joinedAt)) {
      errors.add('Cancelled date cannot be before join date');
    }

    if (rating != null && (rating! < 1 || rating! > 5)) {
      errors.add('Rating must be between 1 and 5');
    }

    return errors;
  }

  // Check if participation is valid
  bool get isValid => validate().isEmpty;

  // Convert to JSON string
  String toJson() {
    final map = toMap();
    return jsonEncode(map);
  }

  // Create from JSON string
  factory ParticipationModel.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return ParticipationModel.fromMap(map);
  }

  @override
  String toString() {
    return 'ParticipationModel(participationId: $participationId, userId: $userId, eventId: $eventId, status: $status, hoursContributed: $hoursContributed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParticipationModel &&
        other.participationId == participationId &&
        other.userId == userId &&
        other.eventId == eventId &&
        other.hoursContributed == hoursContributed &&
        other.status == status &&
        other.joinedAt == joinedAt &&
        other.attendedAt == attendedAt &&
        other.cancelledAt == cancelledAt &&
        other.feedback == feedback &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return participationId.hashCode ^
        userId.hashCode ^
        eventId.hashCode ^
        hoursContributed.hashCode ^
        status.hashCode ^
        joinedAt.hashCode ^
        (attendedAt?.hashCode ?? 0) ^
        (cancelledAt?.hashCode ?? 0) ^
        (feedback?.hashCode ?? 0) ^
        (rating?.hashCode ?? 0);
  }
}

// Extension methods for List<ParticipationModel>
extension ParticipationListExtensions on List<ParticipationModel> {
  // Filter participations by status
  List<ParticipationModel> filterByStatus(String status) {
    return where((participation) => participation.status == status).toList();
  }

  // Get all registered participations
  List<ParticipationModel> get registered {
    return filterByStatus('registered');
  }

  // Get all attended participations
  List<ParticipationModel> get attended {
    return filterByStatus('attended');
  }

  // Get all cancelled participations
  List<ParticipationModel> get cancelled {
    return filterByStatus('cancelled');
  }

  // Get total hours contributed
  int get totalHoursContributed {
    return fold(0, (sum, participation) => sum + participation.hoursContributed);
  }

  // Get average rating
  double get averageRating {
    final ratedParticipations = where((p) => p.rating != null).toList();
    if (ratedParticipations.isEmpty) return 0.0;
    final totalRating = ratedParticipations.fold(0, (sum, p) => sum + p.rating!);
    return totalRating / ratedParticipations.length;
  }

  // Group participations by event ID
  Map<String, List<ParticipationModel>> groupByEvent() {
    final Map<String, List<ParticipationModel>> grouped = {};
    for (final participation in this) {
      grouped.putIfAbsent(participation.eventId, () => []).add(participation);
    }
    return grouped;
  }

  // Check if user is participating in an event
  bool isUserParticipating(String userId, String eventId) {
    return any((participation) =>
        participation.userId == userId &&
        participation.eventId == eventId &&
        participation.isActive);
  }

  // Get user's participation for an event
  ParticipationModel? getUserParticipation(String userId, String eventId) {
    try {
      return firstWhere((participation) =>
          participation.userId == userId && participation.eventId == eventId);
    } catch (e) {
      return null;
    }
  }

  // Get participations for a specific event
  List<ParticipationModel> getParticipationsForEvent(String eventId) {
    return where((participation) => participation.eventId == eventId).toList();
  }

  // Get participations for a specific user
  List<ParticipationModel> getParticipationsForUser(String userId) {
    return where((participation) => participation.userId == userId).toList();
  }

  // Get active participations count
  int get activeCount {
    return where((participation) => participation.isActive).length;
  }

  // Get completed participations count
  int get completedCount {
    return where((participation) => participation.hasAttended).length;
  }
}

// Helper class for creating participation records
class ParticipationBuilder {
  String _participationId = '';
  String _userId = '';
  String _eventId = '';
  int _hoursContributed = 0;
  String _status = 'registered';
  DateTime _joinedAt = DateTime.now();
  DateTime? _attendedAt;
  DateTime? _cancelledAt;
  String? _feedback;
  int? _rating;
  Map<String, dynamic>? _additionalData;

  ParticipationBuilder();

  ParticipationBuilder withId(String id) {
    _participationId = id;
    return this;
  }

  ParticipationBuilder forUser(String userId) {
    _userId = userId;
    return this;
  }

  ParticipationBuilder forEvent(String eventId) {
    _eventId = eventId;
    return this;
  }

  ParticipationBuilder withHours(int hours) {
    _hoursContributed = hours;
    return this;
  }

  ParticipationBuilder withStatus(String status) {
    _status = status;
    return this;
  }

  ParticipationBuilder joinedAt(DateTime date) {
    _joinedAt = date;
    return this;
  }

  ParticipationBuilder attendedAt(DateTime? date) {
    _attendedAt = date;
    return this;
  }

  ParticipationBuilder cancelledAt(DateTime? date) {
    _cancelledAt = date;
    return this;
  }

  ParticipationBuilder withFeedback(String feedback, int rating) {
    _feedback = feedback;
    _rating = rating;
    return this;
  }

  ParticipationBuilder withAdditionalData(Map<String, dynamic> data) {
    _additionalData = data;
    return this;
  }

  ParticipationModel build() {
    return ParticipationModel(
      participationId: _participationId,
      userId: _userId,
      eventId: _eventId,
      hoursContributed: _hoursContributed,
      status: _status,
      joinedAt: _joinedAt,
      attendedAt: _attendedAt,
      cancelledAt: _cancelledAt,
      feedback: _feedback,
      rating: _rating,
      additionalData: _additionalData,
    );
  }
}

// Utility class for participation statistics
class ParticipationStats {
  final int totalParticipations;
  final int registeredCount;
  final int attendedCount;
  final int cancelledCount;
  final int totalHours;
  final double averageRating;
  final double attendanceRate;

  ParticipationStats({
    required this.totalParticipations,
    required this.registeredCount,
    required this.attendedCount,
    required this.cancelledCount,
    required this.totalHours,
    required this.averageRating,
    required this.attendanceRate,
  });

  factory ParticipationStats.fromParticipations(List<ParticipationModel> participations) {
    final total = participations.length;
    final registered = participations.registered.length;
    final attended = participations.attended.length;
    final cancelled = participations.cancelled.length;
    final totalHours = participations.totalHoursContributed;
    final averageRating = participations.averageRating;
    final attendanceRate = total > 0 ? attended / total : 0.0;

    return ParticipationStats(
      totalParticipations: total,
      registeredCount: registered,
      attendedCount: attended,
      cancelledCount: cancelled,
      totalHours: totalHours,
      averageRating: averageRating,
      attendanceRate: attendanceRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_participations': totalParticipations,
      'registered_count': registeredCount,
      'attended_count': attendedCount,
      'cancelled_count': cancelledCount,
      'total_hours': totalHours,
      'average_rating': averageRating,
      'attendance_rate': attendanceRate,
    };
  }
}