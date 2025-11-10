class ReportModel {
  final String reportId;
  final String userId;
  final String spaceId;
  final String type; // 'maintenance', 'vandalism', 'safety', 'suggestion', 'other'
  final String description;
  final List<String> photos;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userName;
  final String? spaceName; // Added spaceName for better display
  final String? title; // Added title for better organization
  final String? location; // Added location property

  ReportModel({
    required this.reportId,
    required this.userId,
    required this.spaceId,
    required this.type,
    required this.description,
    required this.photos,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
    this.userName,
    this.spaceName,
    this.title,
    this.location,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'user_id': userId,
      'space_id': spaceId,
      'type': type,
      'description': description,
      'photos': photos,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_name': userName,
      'space_name': spaceName,
      'title': title,
      'location': location,
    };
  }

  // Create from Map from Firestore
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['report_id'] ?? '',
      userId: map['user_id'] ?? '',
      spaceId: map['space_id'] ?? '',
      type: map['type'] ?? 'other',
      description: map['description'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejection_reason'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : null,
      userName: map['user_name'],
      spaceName: map['space_name'],
      title: map['title'],
      location: map['location'],
    );
  }

  // Create empty report
  factory ReportModel.empty() {
    return ReportModel(
      reportId: '',
      userId: '',
      spaceId: '',
      type: 'other',
      description: '',
      photos: [],
      status: 'pending',
      createdAt: DateTime.now(),
      userName: '',
      spaceName: '',
      title: '',
      location: '',
    );
  }

  // Create copy with updated fields
  ReportModel copyWith({
    String? reportId,
    String? userId,
    String? spaceId,
    String? type,
    String? description,
    List<String>? photos,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? spaceName,
    String? title,
    String? location,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      spaceId: spaceId ?? this.spaceId,
      type: type ?? this.type,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      spaceName: spaceName ?? this.spaceName,
      title: title ?? this.title,
      location: location ?? this.location,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel.fromMap(json);

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get typeDisplay {
    switch (type) {
      case 'maintenance':
        return 'Maintenance Needed';
      case 'vandalism':
        return 'Vandalism Report';
      case 'safety':
        return 'Safety Concern';
      case 'suggestion':
        return 'Improvement Suggestion';
      case 'other':
        return 'Other Issue';
      default:
        return 'Report';
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'approved':
        return 'green';
      case 'rejected':
        return 'red';
      case 'pending':
        return 'orange';
      default:
        return 'grey';
    }
  }

  // Check if report has photos
  bool get hasPhotos => photos.isNotEmpty;

  // Get first photo if available
  String? get firstPhoto => hasPhotos ? photos.first : null;

  // Validation methods
  bool get isValid => 
      reportId.isNotEmpty && 
      userId.isNotEmpty && 
      spaceId.isNotEmpty && 
      description.isNotEmpty;

  // Get short description (first 100 characters)
  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  // Get display title
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    return '$typeDisplay - ${spaceName ?? 'Green Space'}';
  }

  // Get display name (user name or user ID)
  String get displayName {
    if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }
    return 'User ${userId.substring(0, 8)}...';
  }

  // Get display location
  String get displayLocation {
    if (location != null && location!.isNotEmpty) {
      return location!;
    }
    return spaceName ?? 'Unknown Location';
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if report is recent (within 7 days)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  // Check if report is urgent based on type
  bool get isUrgent {
    return type == 'safety' || type == 'vandalism';
  }

  // Get priority level
  String get priority {
    switch (type) {
      case 'safety':
      case 'vandalism':
        return 'high';
      case 'maintenance':
        return 'medium';
      case 'suggestion':
      case 'other':
        return 'low';
      default:
        return 'medium';
    }
  }

  // Get priority color
  String get priorityColor {
    switch (priority) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'grey';
    }
  }

  // Get priority display text
  String get priorityDisplay {
    switch (priority) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Normal Priority';
    }
  }

  // Check if report can be edited (only pending reports)
  bool get canEdit => isPending;

  // Check if report can be deleted (only pending reports)
  bool get canDelete => isPending;

  // Get status icon data (you can use this with Icons)
  String get statusIcon {
    switch (status) {
      case 'approved':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'pending':
        return 'schedule';
      default:
        return 'help';
    }
  }

  // Get type icon data
  String get typeIcon {
    switch (type) {
      case 'maintenance':
        return 'build';
      case 'vandalism':
        return 'warning';
      case 'safety':
        return 'security';
      case 'suggestion':
        return 'lightbulb';
      case 'other':
        return 'info';
      default:
        return 'assignment';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          reportId == other.reportId;

  @override
  int get hashCode => reportId.hashCode;

  @override
  String toString() {
    return 'ReportModel(\n'
        '  reportId: $reportId,\n'
        '  userId: $userId,\n'
        '  userName: $userName,\n'
        '  spaceId: $spaceId,\n'
        '  spaceName: $spaceName,\n'
        '  type: $type,\n'
        '  title: $title,\n'
        '  status: $status,\n'
        '  priority: $priority,\n'
        '  createdAt: $createdAt,\n'
        '  location: $location,\n'
        '  hasPhotos: $hasPhotos\n'
        ')';
  }

  // Compare methods for sorting
  int compareByDate(ReportModel other) {
    return other.createdAt.compareTo(createdAt); // Newest first
  }

  int compareByPriority(ReportModel other) {
    final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
    final thisPriority = priorityOrder[priority] ?? 0;
    final otherPriority = priorityOrder[other.priority] ?? 0;
    return otherPriority.compareTo(thisPriority); // High priority first
  }

  int compareByStatus(ReportModel other) {
    final statusOrder = {'pending': 3, 'approved': 2, 'rejected': 1};
    final thisStatus = statusOrder[status] ?? 0;
    final otherStatus = statusOrder[other.status] ?? 0;
    return otherStatus.compareTo(thisStatus); // Pending first
  }

  // Utility method to check if report matches search query
  bool matchesSearch(String query) {
    final searchLower = query.toLowerCase();
    return description.toLowerCase().contains(searchLower) ||
        (title?.toLowerCase().contains(searchLower) ?? false) ||
        (spaceName?.toLowerCase().contains(searchLower) ?? false) ||
        (userName?.toLowerCase().contains(searchLower) ?? false) ||
        (location?.toLowerCase().contains(searchLower) ?? false) ||
        typeDisplay.toLowerCase().contains(searchLower) ||
        statusDisplay.toLowerCase().contains(searchLower);
  }

  // Get report summary for notifications or previews
  String get summary {
    return '${typeDisplay}: $shortDescription';
  }

  // Check if report needs attention (pending and urgent)
  bool get needsAttention {
    return isPending && isUrgent;
  }

  // Get time since last update
  String get timeSinceUpdate {
    if (updatedAt == null) return formattedDate;
    
    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Updated $years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Updated $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Updated ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return 'Updated ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return 'Updated ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Updated just now';
    }
  }
}