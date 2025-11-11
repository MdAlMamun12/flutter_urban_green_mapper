import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role; // 'citizen', 'ngo', 'admin', 'sponsor'
  final Map<String, dynamic>? location;
  final int impactScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? phoneNumber;
  final String? profilePicture;
  final bool isEmailVerified;
  final bool isActive;
  final List<String>? preferences;
  final Map<String, dynamic>? settings;
  final String? verificationStatus; // For NGO verification
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final String? suspendedBy;

  // Sponsor-specific fields
  final String? organizationName;
  final String? organizationType;
  final String? website;
  final String? contactPerson;
  final String? sponsorTier; // 'bronze', 'silver', 'gold', 'platinum'
  final double totalContribution;
  final bool isActiveSponsor;
  final List<String> sponsoredEvents;
  final DateTime? sponsorSince;
  final String? businessAddress;
  final String? taxId;
  final String? paymentMethod;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.location,
    this.impactScore = 0,
    required this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.profilePicture,
    this.isEmailVerified = false,
    this.isActive = true,
    this.preferences,
    this.settings,
    this.verificationStatus,
    this.verifiedAt,
    this.verifiedBy,
    this.isSuspended = false,
    this.suspensionReason,
    this.suspendedAt,
    this.suspendedBy,

    // Sponsor-specific fields
    this.organizationName,
    this.organizationType,
    this.website,
    this.contactPerson,
    this.sponsorTier,
    this.totalContribution = 0.0,
    this.isActiveSponsor = false,
    this.sponsoredEvents = const [],
    this.sponsorSince,
    this.businessAddress,
    this.taxId,
    this.paymentMethod,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'location': location,
      'impact_score': impactScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'is_email_verified': isEmailVerified,
      'is_active': isActive,
      'preferences': preferences,
      'settings': settings,
      'verification_status': verificationStatus,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'is_suspended': isSuspended,
      'suspension_reason': suspensionReason,
      'suspended_at': suspendedAt?.toIso8601String(),
      'suspended_by': suspendedBy,

      // Sponsor fields
      'organization_name': organizationName,
      'organization_type': organizationType,
      'website': website,
      'contact_person': contactPerson,
      'sponsor_tier': sponsorTier,
      'total_contribution': totalContribution,
      'is_active_sponsor': isActiveSponsor,
      'sponsored_events': sponsoredEvents,
      'sponsor_since': sponsorSince?.toIso8601String(),
      'business_address': businessAddress,
      'tax_id': taxId,
      'payment_method': paymentMethod,
    };
  }

  // Create from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      return UserModel(
        userId: _parseString(map['user_id']) ?? '',
        name: _parseString(map['name']) ?? '',
        email: _parseString(map['email']) ?? '',
        role: _parseString(map['role']) ?? 'citizen',
        location: _parseLocation(map['location']),
        impactScore: _parseInt(map['impact_score']) ?? 0,
        createdAt: _parseDateTime(map['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTime(map['updated_at']),
        phoneNumber: _parseString(map['phone_number']),
        profilePicture: _parseString(map['profile_picture']),
        isEmailVerified: _parseBool(map['is_email_verified']) ?? false,
        isActive: _parseBool(map['is_active']) ?? true,
        preferences: _parseStringList(map['preferences']),
        settings: _parseMap(map['settings']),
        verificationStatus: _parseString(map['verification_status']),
        verifiedAt: _parseDateTime(map['verified_at']),
        verifiedBy: _parseString(map['verified_by']),
        isSuspended: _parseBool(map['is_suspended']) ?? false,
        suspensionReason: _parseString(map['suspension_reason']),
        suspendedAt: _parseDateTime(map['suspended_at']),
        suspendedBy: _parseString(map['suspended_by']),

        // Sponsor fields
        organizationName: _parseString(map['organization_name']),
        organizationType: _parseString(map['organization_type']),
        website: _parseString(map['website']),
        contactPerson: _parseString(map['contact_person']),
        sponsorTier: _parseString(map['sponsor_tier']),
        totalContribution: _parseDouble(map['total_contribution']) ?? 0.0,
        isActiveSponsor: _parseBool(map['is_active_sponsor']) ?? false,
        sponsoredEvents: _parseStringList(map['sponsored_events']) ?? [],
        sponsorSince: _parseDateTime(map['sponsor_since']),
        businessAddress: _parseString(map['business_address']),
        taxId: _parseString(map['tax_id']),
        paymentMethod: _parseString(map['payment_method']),
      );
    } catch (e) {
      throw FormatException('Failed to parse UserModel: $e');
    }
  }

  // Create empty user
  factory UserModel.empty() {
    return UserModel(
      userId: '',
      name: '',
      email: '',
      role: 'citizen',
      impactScore: 0,
      createdAt: DateTime.now(),
    );
  }

  // Create copy with updated fields
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    Map<String, dynamic>? location,
    int? impactScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? profilePicture,
    bool? isEmailVerified,
    bool? isActive,
    List<String>? preferences,
    Map<String, dynamic>? settings,
    String? verificationStatus,
    DateTime? verifiedAt,
    String? verifiedBy,
    bool? isSuspended,
    String? suspensionReason,
    DateTime? suspendedAt,
    String? suspendedBy,

    // Sponsor fields
    String? organizationName,
    String? organizationType,
    String? website,
    String? contactPerson,
    String? sponsorTier,
    double? totalContribution,
    bool? isActiveSponsor,
    List<String>? sponsoredEvents,
    DateTime? sponsorSince,
    String? businessAddress,
    String? taxId,
    String? paymentMethod,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      impactScore: impactScore ?? this.impactScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspendedBy: suspendedBy ?? this.suspendedBy,

      // Sponsor fields
      organizationName: organizationName ?? this.organizationName,
      organizationType: organizationType ?? this.organizationType,
      website: website ?? this.website,
      contactPerson: contactPerson ?? this.contactPerson,
      sponsorTier: sponsorTier ?? this.sponsorTier,
      totalContribution: totalContribution ?? this.totalContribution,
      isActiveSponsor: isActiveSponsor ?? this.isActiveSponsor,
      sponsoredEvents: sponsoredEvents ?? this.sponsoredEvents,
      sponsorSince: sponsorSince ?? this.sponsorSince,
      businessAddress: businessAddress ?? this.businessAddress,
      taxId: taxId ?? this.taxId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  // Helper methods for data validation
  bool get isValid => userId.isNotEmpty && name.isNotEmpty && email.isNotEmpty;
  
  bool get hasCompleteProfile => name.isNotEmpty && email.isNotEmpty && phoneNumber?.isNotEmpty == true;
  
  // ROLE SPECIFIC METHODS
  bool get isAdmin => role == 'admin';
  bool get isNGO => role == 'ngo';
  bool get isCitizen => role == 'citizen';
  bool get isSponsor => role == 'sponsor';
  
  // Sponsor-specific getters
  bool get isActiveSponsorUser => isSponsor && isActiveSponsor;
  bool get canSponsorEvents => isSponsor && isActiveSponsor;
  String get sponsorTierDisplay {
    switch (sponsorTier) {
      case 'platinum':
        return 'Platinum Sponsor';
      case 'gold':
        return 'Gold Sponsor';
      case 'silver':
        return 'Silver Sponsor';
      case 'bronze':
        return 'Bronze Sponsor';
      default:
        return 'Sponsor';
    }
  }

  // Color representation as hex string instead of Color object
  String get sponsorTierColor {
    switch (sponsorTier) {
      case 'platinum':
        return '#E5E4E2'; // Platinum color
      case 'gold':
        return '#FFD700'; // Gold color
      case 'silver':
        return '#C0C0C0'; // Silver color
      case 'bronze':
        return '#CD7F32'; // Bronze color
      default:
        return '#4CAF50'; // Green color
    }
  }

  // Alternative: Return color as integer value
  int get sponsorTierColorValue {
    switch (sponsorTier) {
      case 'platinum':
        return 0xFFE5E4E2;
      case 'gold':
        return 0xFFFFD700;
      case 'silver':
        return 0xFFC0C0C0;
      case 'bronze':
        return 0xFFCD7F32;
      default:
        return 0xFF4CAF50;
    }
  }

  double get tierMinimumContribution {
    switch (sponsorTier) {
      case 'platinum':
        return 5000.0;
      case 'gold':
        return 1000.0;
      case 'silver':
        return 500.0;
      case 'bronze':
        return 100.0;
      default:
        return 0.0;
    }
  }

  bool get meetsTierRequirements => totalContribution >= tierMinimumContribution;

  // Permission methods
  bool get canCreateEvents => isAdmin || isNGO;
  bool get canModerateContent => isAdmin || isNGO;
  bool get canManageUsers => isAdmin;
  bool get canAccessAdminDashboard => isAdmin;
  bool get canVerifyNGOs => isAdmin;
  bool get canManageSystemSettings => isAdmin;
  bool get canViewAnalytics => isAdmin || isNGO;
  bool get canExportData => isAdmin || isNGO;
  bool get canSponsor => isSponsor || isAdmin;

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'ngo':
        return 'NGO Member';
      case 'sponsor':
        return organizationName ?? 'Sponsor';
      case 'citizen':
        return 'Citizen';
      default:
        return 'User';
    }
  }

  // Get display name (prefers organization name for sponsors)
  String get displayName {
    if (isSponsor && organizationName != null) {
      return organizationName!;
    }
    if (name.isEmpty) return 'User';
    return name.split(' ').first;
  }

  // Get user level based on impact score
  String get userLevel {
    if (impactScore >= 1000) return 'Eco Champion';
    if (impactScore >= 500) return 'Green Guardian';
    if (impactScore >= 250) return 'Nature Lover';
    if (impactScore >= 100) return 'Eco Enthusiast';
    return 'Green Beginner';
  }

  // Calculate progress to next level
  double get levelProgress {
    if (impactScore >= 1000) return 1.0;
    if (impactScore >= 500) return (impactScore - 500) / 500.0;
    if (impactScore >= 250) return (impactScore - 250) / 250.0;
    if (impactScore >= 100) return (impactScore - 100) / 150.0;
    return impactScore / 100.0;
  }

  // Get next level requirements
  String get nextLevelRequirements {
    if (impactScore >= 1000) return 'Max Level Reached';
    if (impactScore >= 500) return '${1000 - impactScore} points to Eco Champion';
    if (impactScore >= 250) return '${500 - impactScore} points to Green Guardian';
    if (impactScore >= 100) return '${250 - impactScore} points to Nature Lover';
    return '${100 - impactScore} points to Eco Enthusiast';
  }

  // Check if user is verified (for NGOs and Admins)
  bool get isVerified => isAdmin || (isNGO && isEmailVerified && verificationStatus == 'approved');

  // Get user initials for avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Admin specific properties
  bool get needsVerification => isNGO && verificationStatus != 'approved';
  bool get isPendingVerification => isNGO && verificationStatus == 'pending';
  bool get isVerifiedNGO => isNGO && verificationStatus == 'approved';
  bool get isRejectedNGO => isNGO && verificationStatus == 'rejected';

  // Sponsor verification
  bool get needsSponsorVerification => isSponsor && !isActiveSponsor;
  bool get isVerifiedSponsor => isSponsor && isActiveSponsor;

  // Suspension status
  bool get canLogin => isActive && !isSuspended;
  String get accountStatus {
    if (isSuspended) return 'Suspended';
    if (!isActive) return 'Inactive';
    if (needsVerification) return 'Pending Verification';
    if (needsSponsorVerification) return 'Pending Sponsor Approval';
    return 'Active';
  }

  // Equality check
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, role: $role, impactScore: $impactScore, isAdmin: $isAdmin, isSponsor: $isSponsor)';
  }

  // Private helper methods for safe parsing
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value == 1;
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    // Firestore Timestamp from cloud_firestore
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static Map<String, dynamic>? _parseMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List<String>) return value;
    if (value is List) {
      try {
        return value.cast<String>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _parseLocation(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return null;
  }

  // Validation methods
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidRole(String role) {
    return ['citizen', 'ngo', 'admin', 'sponsor'].contains(role);
  }

  static bool isValidSponsorTier(String tier) {
    return ['bronze', 'silver', 'gold', 'platinum'].contains(tier);
  }

  // Create default settings
  static Map<String, dynamic> get defaultSettings {
    return {
      'notifications': {
        'email': true,
        'push': true,
        'event_reminders': true,
        'plant_care_reminders': true,
        'newsletter': false,
        'admin_alerts': false, // Only for admins
        'sponsorship_opportunities': false, // For sponsors
      },
      'privacy': {
        'show_profile': true,
        'show_impact_score': true,
        'show_location': false,
        'show_contributions': true, // For sponsors
      },
      'appearance': {
        'theme': 'system',
        'language': 'en',
      },
      'admin_settings': { // Only for admins
        'moderation_alerts': true,
        'user_registration_alerts': true,
        'system_health_alerts': true,
      },
      'sponsor_settings': { // Only for sponsors
        'receive_sponsor_emails': true,
        'show_in_sponsor_directory': true,
        'auto_renew_sponsorship': false,
      },
    };
  }

  // Get default preferences
  static List<String> get defaultPreferences {
    return [
      'tree_planting',
      'cleanup_events',
      'gardening',
      'wildlife_conservation',
    ];
  }

  // Create a new user with default values
  factory UserModel.createNew({
    required String userId,
    required String name,
    required String email,
    required String role,
    Map<String, dynamic>? location,
    String? phoneNumber,
    
    // Sponsor-specific parameters
    String? organizationName,
    String? organizationType,
    String? website,
    String? contactPerson,
    String? sponsorTier,
    String? businessAddress,
    String? taxId,
  }) {
    // Set verification status for NGOs and sponsors
    String? verificationStatus;
    bool isActiveSponsor = false;
    
    if (role == 'ngo') {
      verificationStatus = 'pending';
    } else if (role == 'admin') {
      verificationStatus = 'approved'; // Admins are auto-approved
    } else if (role == 'sponsor') {
      // Sponsors might need admin approval depending on business rules
      isActiveSponsor = true; // Auto-activate for now, can be changed
    }

    return UserModel(
      userId: userId,
      name: name,
      email: email,
      role: role,
      location: location,
      phoneNumber: phoneNumber,
      impactScore: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: false,
      isActive: true,
      preferences: defaultPreferences,
      settings: defaultSettings,
      verificationStatus: verificationStatus,

      // Sponsor fields
      organizationName: organizationName,
      organizationType: organizationType,
      website: website,
      contactPerson: contactPerson,
      sponsorTier: sponsorTier,
      totalContribution: 0.0,
      isActiveSponsor: isActiveSponsor,
      sponsoredEvents: [],
      sponsorSince: role == 'sponsor' ? DateTime.now() : null,
      businessAddress: businessAddress,
      taxId: taxId,
    );
  }

  // Create admin user (for setup)
  factory UserModel.createAdmin({
    required String userId,
    required String name,
    required String email,
    Map<String, dynamic>? location,
    String? phoneNumber,
  }) {
    return UserModel(
      userId: userId,
      name: name,
      email: email,
      role: 'admin',
      location: location,
      phoneNumber: phoneNumber,
      impactScore: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: true, // Admins should have verified email
      isActive: true,
      preferences: defaultPreferences,
      settings: defaultSettings,
      verificationStatus: 'approved',
      verifiedAt: DateTime.now(),
      verifiedBy: 'system',
    );
  }

  // Create NGO user
  factory UserModel.createNGO({
    required String userId,
    required String name,
    required String email,
    Map<String, dynamic>? location,
    String? phoneNumber,
  }) {
    return UserModel(
      userId: userId,
      name: name,
      email: email,
      role: 'ngo',
      location: location,
      phoneNumber: phoneNumber,
      impactScore: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: false,
      isActive: true,
      preferences: defaultPreferences,
      settings: defaultSettings,
      verificationStatus: 'pending', // NGOs need admin verification
    );
  }

  // Create citizen user
  factory UserModel.createCitizen({
    required String userId,
    required String name,
    required String email,
    Map<String, dynamic>? location,
    String? phoneNumber,
  }) {
    return UserModel(
      userId: userId,
      name: name,
      email: email,
      role: 'citizen',
      location: location,
      phoneNumber: phoneNumber,
      impactScore: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: false,
      isActive: true,
      preferences: defaultPreferences,
      settings: defaultSettings,
    );
  }

  // Create sponsor user
  factory UserModel.createSponsor({
    required String userId,
    required String name,
    required String email,
    required String organizationName,
    required String organizationType,
    String? website,
    required String contactPerson,
    required String sponsorTier,
    Map<String, dynamic>? location,
    String? phoneNumber,
    String? businessAddress,
    String? taxId,
  }) {
    return UserModel(
      userId: userId,
      name: name,
      email: email,
      role: 'sponsor',
      location: location,
      phoneNumber: phoneNumber,
      impactScore: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: false,
      isActive: true,
      preferences: defaultPreferences,
      settings: defaultSettings,

      // Sponsor-specific fields
      organizationName: organizationName,
      organizationType: organizationType,
      website: website,
      contactPerson: contactPerson,
      sponsorTier: sponsorTier,
      totalContribution: 0.0,
      isActiveSponsor: true, // Auto-activate sponsors
      sponsoredEvents: [],
      sponsorSince: DateTime.now(),
      businessAddress: businessAddress,
      taxId: taxId,
    );
  }

  // Method to verify NGO (admin only)
  UserModel verifyNGO({required String verifiedBy}) {
    if (!isNGO) {
      throw StateError('Only NGO users can be verified');
    }
    return copyWith(
      verificationStatus: 'approved',
      verifiedAt: DateTime.now(),
      verifiedBy: verifiedBy,
    );
  }

  // Method to verify/activate sponsor (admin only)
  UserModel activateSponsor({required String verifiedBy}) {
    if (!isSponsor) {
      throw StateError('Only sponsor users can be activated');
    }
    return copyWith(
      isActiveSponsor: true,
      sponsorSince: DateTime.now(),
    );
  }

  // Method to deactivate sponsor (admin only)
  UserModel deactivateSponsor({required String reason}) {
    if (!isSponsor) {
      throw StateError('Only sponsor users can be deactivated');
    }
    return copyWith(
      isActiveSponsor: false,
    );
  }

  // Method to update sponsor contribution
  UserModel updateSponsorContribution(double amount) {
    if (!isSponsor) {
      throw StateError('Only sponsor users can update contributions');
    }
    return copyWith(
      totalContribution: totalContribution + amount,
      updatedAt: DateTime.now(),
    );
  }

  // Method to add sponsored event
  UserModel addSponsoredEvent(String eventId) {
    if (!isSponsor) {
      throw StateError('Only sponsor users can sponsor events');
    }
    final updatedEvents = List<String>.from(sponsoredEvents)..add(eventId);
    return copyWith(
      sponsoredEvents: updatedEvents,
      updatedAt: DateTime.now(),
    );
  }

  // Method to upgrade sponsor tier
  UserModel upgradeSponsorTier(String newTier) {
    if (!isSponsor) {
      throw StateError('Only sponsor users can upgrade tiers');
    }
    if (!isValidSponsorTier(newTier)) {
      throw StateError('Invalid sponsor tier: $newTier');
    }
    return copyWith(
      sponsorTier: newTier,
      updatedAt: DateTime.now(),
    );
  }

  // Method to suspend user (admin only)
  UserModel suspendUser({required String reason, required String suspendedBy}) {
    return copyWith(
      isSuspended: true,
      suspensionReason: reason,
      suspendedAt: DateTime.now(),
      suspendedBy: suspendedBy,
    );
  }

  // Method to unsuspend user (admin only)
  UserModel unsuspendUser() {
    return copyWith(
      isSuspended: false,
      suspensionReason: null,
      suspendedAt: null,
      suspendedBy: null,
    );
  }

  // Method to update impact score
  UserModel updateImpactScore(int newScore) {
    return copyWith(
      impactScore: newScore,
      updatedAt: DateTime.now(),
    );
  }

  // Method to check if user can access specific feature
  bool canAccessFeature(String feature) {
    switch (feature) {
      case 'admin_dashboard':
        return isAdmin;
      case 'event_creation':
        return canCreateEvents;
      case 'content_moderation':
        return canModerateContent;
      case 'user_management':
        return canManageUsers;
      case 'analytics':
        return canViewAnalytics;
      case 'data_export':
        return canExportData;
      case 'system_settings':
        return canManageSystemSettings;
      case 'ngo_verification':
        return canVerifyNGOs;
      case 'sponsor_dashboard':
        return isSponsor;
      case 'sponsor_events':
        return canSponsor;
      case 'sponsor_management':
        return isAdmin;
      default:
        return true; // Default to allowing access for unknown features
    }
  }

  // Get user permissions list
  List<String> get permissions {
    List<String> permissions = [];
    
    if (isAdmin) {
      permissions.addAll([
        'manage_users',
        'manage_events',
        'manage_content',
        'view_analytics',
        'export_data',
        'system_settings',
        'verify_ngos',
        'manage_sponsors',
        'suspend_users',
        'broadcast_notifications',
      ]);
    } else if (isNGO) {
      permissions.addAll([
        'create_events',
        'manage_own_events',
        'moderate_content',
        'view_analytics',
        'export_data',
        'manage_sponsorships',
      ]);
    } else if (isSponsor) {
      permissions.addAll([
        'sponsor_events',
        'view_sponsor_dashboard',
        'track_contributions',
        'receive_sponsor_benefits',
      ]);
    } else {
      permissions.addAll([
        'join_events',
        'create_reports',
        'adopt_plants',
        'view_map',
      ]);
    }
    
    return permissions;
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  // Sponsor-specific methods
  List<String> get sponsorBenefits {
    switch (sponsorTier) {
      case 'platinum':
        return [
          'Logo on homepage',
          'Featured in all events',
          'Social media spotlight',
          'Press release mentions',
          'Executive meetings with NGO',
          'Naming rights for major events',
        ];
      case 'gold':
        return [
          'Logo on website',
          'Event signage',
          'Social media features',
          'Newsletter spotlight',
          'Recognition in annual report',
        ];
      case 'silver':
        return [
          'Logo on event pages',
          'Social media mentions',
          'Website recognition',
          'Email newsletter feature',
        ];
      case 'bronze':
        return [
          'Logo on website',
          'Social media thank you',
          'Event program listing',
        ];
      default:
        return [
          'Website recognition',
          'Social media thank you',
        ];
    }
  }

  // Get sponsorship progress towards next tier
  double get tierProgress {
    if (sponsorTier == 'platinum') return 1.0;
    
    final currentTierMin = tierMinimumContribution;
    double nextTierMin;
    
    switch (sponsorTier) {
      case 'bronze':
        nextTierMin = 500.0; // Silver
        break;
      case 'silver':
        nextTierMin = 1000.0; // Gold
        break;
      case 'gold':
        nextTierMin = 5000.0; // Platinum
        break;
      default:
        return 0.0;
    }
    
    final progress = (totalContribution - currentTierMin) / (nextTierMin - currentTierMin);
    return progress.clamp(0.0, 1.0);
  }

  // Get next tier information
  Map<String, dynamic>? get nextTierInfo {
    if (sponsorTier == 'platinum') return null;
    
    switch (sponsorTier) {
      case 'bronze':
        return {
          'tier': 'silver',
          'min_amount': 500.0,
          'remaining': (500.0 - totalContribution).clamp(0, double.infinity),
        };
      case 'silver':
        return {
          'tier': 'gold',
          'min_amount': 1000.0,
          'remaining': (1000.0 - totalContribution).clamp(0, double.infinity),
        };
      case 'gold':
        return {
          'tier': 'platinum',
          'min_amount': 5000.0,
          'remaining': (5000.0 - totalContribution).clamp(0, double.infinity),
        };
      default:
        return {
          'tier': 'bronze',
          'min_amount': 100.0,
          'remaining': (100.0 - totalContribution).clamp(0, double.infinity),
        };
    }
  }
}