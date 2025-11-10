import 'dart:convert';

class SponsorModel {
  final String sponsorId;
  final String name;
  final String contactEmail;
  final String tier; // 'bronze', 'silver', 'gold', 'platinum'
  final String? logoUrl;
  final String? website;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final double totalContribution;
  final int sponsoredEventsCount;
  final DateTime joinedAt;
  final bool isActive;
  final Map<String, dynamic>? benefits;
  final Map<String, dynamic>? contactPerson;
  final List<String> sponsoredEvents;
  
  // NEW PROPERTIES ADDED
  final String? organizationType;
  final String? taxId;
  final String? contactPersonName;
  final String? businessAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sponsorSince;

  SponsorModel({
    required this.sponsorId,
    required this.name,
    required this.contactEmail,
    required this.tier,
    this.logoUrl,
    this.website,
    this.phoneNumber,
    this.address,
    this.description,
    this.totalContribution = 0.0,
    this.sponsoredEventsCount = 0,
    required this.joinedAt,
    this.isActive = true,
    this.benefits,
    this.contactPerson,
    this.sponsoredEvents = const [],
    
    // NEW PROPERTIES
    this.organizationType,
    this.taxId,
    this.contactPersonName,
    this.businessAddress,
    this.createdAt,
    this.updatedAt,
    this.sponsorSince,
  });

  // Convert SponsorModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sponsor_id': sponsorId,
      'name': name,
      'contact_email': contactEmail,
      'tier': tier,
      'logo_url': logoUrl,
      'website': website,
      'phone_number': phoneNumber,
      'address': address,
      'description': description,
      'total_contribution': totalContribution,
      'sponsored_events_count': sponsoredEventsCount,
      'joined_at': joinedAt.toIso8601String(),
      'is_active': isActive,
      'benefits': benefits,
      'contact_person': contactPerson,
      'sponsored_events': sponsoredEvents,
      
      // NEW PROPERTIES
      'organization_type': organizationType,
      'tax_id': taxId,
      'contact_person_name': contactPersonName,
      'business_address': businessAddress,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'sponsor_since': sponsorSince,
    };
  }

  // Create SponsorModel from Map (from Firestore)
  factory SponsorModel.fromMap(Map<String, dynamic> map) {
    return SponsorModel(
      sponsorId: map['sponsor_id'] ?? '',
      name: map['name'] ?? '',
      contactEmail: map['contact_email'] ?? '',
      tier: map['tier'] ?? 'bronze',
      logoUrl: map['logo_url'],
      website: map['website'],
      phoneNumber: map['phone_number'],
      address: map['address'],
      description: map['description'],
      totalContribution: (map['total_contribution'] ?? 0.0).toDouble(),
      sponsoredEventsCount: map['sponsored_events_count'] ?? 0,
      joinedAt: map['joined_at'] != null 
          ? DateTime.parse(map['joined_at'])
          : DateTime.now(),
      isActive: map['is_active'] ?? true,
      benefits: map['benefits'] != null 
          ? Map<String, dynamic>.from(map['benefits'])
          : null,
      contactPerson: map['contact_person'] != null
          ? Map<String, dynamic>.from(map['contact_person'])
          : null,
      sponsoredEvents: map['sponsored_events'] != null
          ? List<String>.from(map['sponsored_events'])
          : [],
      
      // NEW PROPERTIES
      organizationType: map['organization_type'],
      taxId: map['tax_id'],
      contactPersonName: map['contact_person_name'],
      businessAddress: map['business_address'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      sponsorSince: map['sponsor_since'],
    );
  }

  // Create empty sponsor
  factory SponsorModel.empty() {
    return SponsorModel(
      sponsorId: '',
      name: '',
      contactEmail: '',
      tier: 'bronze',
      totalContribution: 0.0,
      sponsoredEventsCount: 0,
      joinedAt: DateTime.now(),
      isActive: true,
      sponsoredEvents: [],
    );
  }

  // Create a copy of SponsorModel with updated values
  SponsorModel copyWith({
    String? sponsorId,
    String? name,
    String? contactEmail,
    String? tier,
    String? logoUrl,
    String? website,
    String? phoneNumber,
    String? address,
    String? description,
    double? totalContribution,
    int? sponsoredEventsCount,
    DateTime? joinedAt,
    bool? isActive,
    Map<String, dynamic>? benefits,
    Map<String, dynamic>? contactPerson,
    List<String>? sponsoredEvents,
    
    // NEW PROPERTIES
    String? organizationType,
    String? taxId,
    String? contactPersonName,
    String? businessAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sponsorSince,
  }) {
    return SponsorModel(
      sponsorId: sponsorId ?? this.sponsorId,
      name: name ?? this.name,
      contactEmail: contactEmail ?? this.contactEmail,
      tier: tier ?? this.tier,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      totalContribution: totalContribution ?? this.totalContribution,
      sponsoredEventsCount: sponsoredEventsCount ?? this.sponsoredEventsCount,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      benefits: benefits ?? this.benefits,
      contactPerson: contactPerson ?? this.contactPerson,
      sponsoredEvents: sponsoredEvents ?? this.sponsoredEvents,
      
      // NEW PROPERTIES
      organizationType: organizationType ?? this.organizationType,
      taxId: taxId ?? this.taxId,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      businessAddress: businessAddress ?? this.businessAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sponsorSince: sponsorSince ?? this.sponsorSince,
    );
  }

  // Update sponsor tier
  SponsorModel updateTier(String newTier) {
    return copyWith(tier: newTier);
  }

  // Add contribution amount
  SponsorModel addContribution(double amount) {
    return copyWith(
      totalContribution: totalContribution + amount,
      sponsoredEventsCount: sponsoredEventsCount + 1,
    );
  }

  // Add sponsored event
  SponsorModel addSponsoredEvent(String eventId) {
    final updatedEvents = List<String>.from(sponsoredEvents);
    if (!updatedEvents.contains(eventId)) {
      updatedEvents.add(eventId);
    }
    return copyWith(
      sponsoredEvents: updatedEvents,
      sponsoredEventsCount: updatedEvents.length,
    );
  }

  // Remove sponsored event
  SponsorModel removeSponsoredEvent(String eventId) {
    final updatedEvents = List<String>.from(sponsoredEvents);
    updatedEvents.remove(eventId);
    return copyWith(
      sponsoredEvents: updatedEvents,
      sponsoredEventsCount: updatedEvents.length,
    );
  }

  // Deactivate sponsor
  SponsorModel deactivate() {
    return copyWith(isActive: false);
  }

  // Activate sponsor
  SponsorModel activate() {
    return copyWith(isActive: true);
  }

  // Update contact information
  SponsorModel updateContactInfo({
    String? email,
    String? phone,
    String? newAddress,
    Map<String, dynamic>? contactPersonInfo,
    String? contactPersonName,
  }) {
    return copyWith(
      contactEmail: email ?? contactEmail,
      phoneNumber: phone ?? phoneNumber,
      address: newAddress ?? address,
      contactPerson: contactPersonInfo ?? contactPerson,
      contactPersonName: contactPersonName ?? this.contactPersonName,
    );
  }

  // NEW: Update organization information
  SponsorModel updateOrganizationInfo({
    String? organizationType,
    String? taxId,
    String? businessAddress,
  }) {
    return copyWith(
      organizationType: organizationType ?? this.organizationType,
      taxId: taxId ?? this.taxId,
      businessAddress: businessAddress ?? this.businessAddress,
    );
  }

  // Get tier color for UI
  String get tierColor {
    switch (tier) {
      case 'platinum':
        return '#E5E4E2'; // Platinum
      case 'gold':
        return '#FFD700'; // Gold
      case 'silver':
        return '#C0C0C0'; // Silver
      case 'bronze':
        return '#CD7F32'; // Bronze
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get tier display name
  String get tierDisplayName {
    switch (tier) {
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

  // Get tier benefits based on tier level
  Map<String, dynamic> get defaultBenefits {
    switch (tier) {
      case 'platinum':
        return {
          'logo_placement': 'Premium logo placement on all materials',
          'social_media': 'Featured posts and stories on all platforms',
          'event_presence': 'Exclusive VIP booth space',
          'verbal_acknowledgment': 'Keynote mentions and dedicated segments',
          'website_feature': 'Hero section placement on website',
          'newsletter': 'Dedicated feature in monthly newsletter',
          'tier_specific': 'Executive networking, media coverage, naming rights',
        };
      case 'gold':
        return {
          'logo_placement': 'Large logo on all event materials',
          'social_media': 'Featured posts on all social media platforms',
          'event_presence': 'Dedicated booth space at events',
          'verbal_acknowledgment': 'Multiple verbal acknowledgments during events',
          'website_feature': 'Premium placement on website sponsor page',
          'newsletter': 'Featured in monthly newsletter',
          'tier_specific': 'VIP event invitations, exclusive networking opportunities',
        };
      case 'silver':
        return {
          'logo_placement': 'Medium logo on event materials',
          'social_media': 'Mention in social media posts',
          'event_presence': 'Shared booth space',
          'verbal_acknowledgment': 'Verbal acknowledgment during events',
          'website_feature': 'Standard placement on website sponsor page',
          'newsletter': 'Mention in quarterly newsletter',
        };
      case 'bronze':
        return {
          'logo_placement': 'Small logo on event materials',
          'social_media': 'Included in sponsor thank you posts',
          'website_feature': 'Listed on website sponsor page',
          'verbal_acknowledgment': 'General acknowledgment',
        };
      default:
        return {
          'logo_placement': 'Logo on event materials',
          'website_feature': 'Listed on website',
        };
    }
  }

  // Get minimum contribution amount for tier
  double get minimumContribution {
    switch (tier) {
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

  // Check if sponsor meets tier requirements
  bool get meetsTierRequirements {
    return totalContribution >= minimumContribution;
  }

  // Get next tier information
  Map<String, dynamic>? get nextTierInfo {
    switch (tier) {
      case 'bronze':
        return {
          'tier': 'silver',
          'minimum_amount': 500.0,
          'amount_needed': (500.0 - totalContribution).clamp(0, double.infinity),
          'benefits': {
            'logo_placement': 'Medium logo on event materials',
            'social_media': 'Mention in social media posts',
            'additional_features': 'Shared booth space, verbal acknowledgment',
          },
        };
      case 'silver':
        return {
          'tier': 'gold',
          'minimum_amount': 1000.0,
          'amount_needed': (1000.0 - totalContribution).clamp(0, double.infinity),
          'benefits': {
            'logo_placement': 'Large logo on all event materials',
            'social_media': 'Featured posts on all social media platforms',
            'additional_features': 'Dedicated booth space, VIP event invitations',
          },
        };
      case 'gold':
        return {
          'tier': 'platinum',
          'minimum_amount': 5000.0,
          'amount_needed': (5000.0 - totalContribution).clamp(0, double.infinity),
          'benefits': {
            'logo_placement': 'Premium logo placement on all materials',
            'social_media': 'Featured posts and stories on all platforms',
            'additional_features': 'Exclusive VIP booth, executive networking',
          },
        };
      default:
        return null;
    }
  }

  // Validate sponsor data
  List<String> validate() {
    final errors = <String>[];

    if (sponsorId.isEmpty) {
      errors.add('Sponsor ID is required');
    }

    if (name.isEmpty) {
      errors.add('Sponsor name is required');
    }

    if (contactEmail.isEmpty) {
      errors.add('Contact email is required');
    } else if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(contactEmail)) {
      errors.add('Valid contact email is required');
    }

    if (!['bronze', 'silver', 'gold', 'platinum'].contains(tier)) {
      errors.add('Invalid sponsor tier');
    }

    if (totalContribution < 0) {
      errors.add('Total contribution cannot be negative');
    }

    if (sponsoredEventsCount < 0) {
      errors.add('Sponsored events count cannot be negative');
    }

    if (joinedAt.isAfter(DateTime.now())) {
      errors.add('Join date cannot be in the future');
    }

    if (website != null && website!.isNotEmpty) {
      final urlRegex = RegExp(
        r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
      );
      if (!urlRegex.hasMatch(website!)) {
        errors.add('Invalid website URL');
      }
    }

    return errors;
  }

  // Check if sponsor is valid
  bool get isValid => validate().isEmpty;

  // Get contact person name
  String get contactPersonDisplayName {
    if (contactPersonName != null && contactPersonName!.isNotEmpty) {
      return contactPersonName!;
    }
    if (contactPerson != null && contactPerson!['name'] != null) {
      return contactPerson!['name'] as String;
    }
    return 'Contact Person';
  }

  // Get contact person phone
  String get contactPersonPhone {
    if (contactPerson != null && contactPerson!['phone'] != null) {
      return contactPerson!['phone'] as String;
    }
    return phoneNumber ?? '';
  }

  // Get contact person title
  String get contactPersonTitle {
    if (contactPerson != null && contactPerson!['title'] != null) {
      return contactPerson!['title'] as String;
    }
    return 'Representative';
  }

  // Calculate impact score based on contributions
  double get impactScore {
    return totalContribution / 100; // 1 point per 100 currency units
  }

  // Get sponsorship duration in months
  int get sponsorshipDuration {
    final now = DateTime.now();
    final duration = now.difference(joinedAt);
    return (duration.inDays / 30).ceil();
  }

  // Check if sponsor is long-term (more than 6 months)
  bool get isLongTermSponsor {
    return sponsorshipDuration >= 6;
  }

  // Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Create from JSON string
  factory SponsorModel.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return SponsorModel.fromMap(map);
  }

  @override
  String toString() {
    return 'SponsorModel(sponsorId: $sponsorId, name: $name, tier: $tier, totalContribution: $totalContribution, sponsoredEvents: ${sponsoredEvents.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SponsorModel &&
        other.sponsorId == sponsorId &&
        other.name == name &&
        other.contactEmail == contactEmail &&
        other.tier == tier &&
        other.logoUrl == logoUrl &&
        other.totalContribution == totalContribution &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return sponsorId.hashCode ^
        name.hashCode ^
        contactEmail.hashCode ^
        tier.hashCode ^
        logoUrl.hashCode ^
        totalContribution.hashCode ^
        isActive.hashCode;
  }
}

// Extension methods for List<SponsorModel>
extension SponsorListExtensions on List<SponsorModel> {
  // Filter sponsors by tier
  List<SponsorModel> filterByTier(String tier) {
    return where((sponsor) => sponsor.tier == tier).toList();
  }

  // Get all active sponsors
  List<SponsorModel> get active {
    return where((sponsor) => sponsor.isActive).toList();
  }

  // Get all inactive sponsors
  List<SponsorModel> get inactive {
    return where((sponsor) => !sponsor.isActive).toList();
  }

  // Get platinum sponsors
  List<SponsorModel> get platinumSponsors {
    return filterByTier('platinum');
  }

  // Get gold sponsors
  List<SponsorModel> get goldSponsors {
    return filterByTier('gold');
  }

  // Get silver sponsors
  List<SponsorModel> get silverSponsors {
    return filterByTier('silver');
  }

  // Get bronze sponsors
  List<SponsorModel> get bronzeSponsors {
    return filterByTier('bronze');
  }

  // Get total contributions
  double get totalContributions {
    return fold(0.0, (sum, sponsor) => sum + sponsor.totalContribution);
  }

  // Get average contribution
  double get averageContribution {
    if (isEmpty) return 0.0;
    return totalContributions / length;
  }

  // Get sponsors sorted by contribution (descending)
  List<SponsorModel> sortedByContribution() {
    return List.from(this)..sort((a, b) => b.totalContribution.compareTo(a.totalContribution));
  }

  // Get sponsors sorted by join date (newest first)
  List<SponsorModel> sortedByJoinDate() {
    return List.from(this)..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
  }

  // Group sponsors by tier
  Map<String, List<SponsorModel>> groupByTier() {
    final Map<String, List<SponsorModel>> grouped = {};
    for (final sponsor in this) {
      grouped.putIfAbsent(sponsor.tier, () => []).add(sponsor);
    }
    return grouped;
  }

  // Get top contributors
  List<SponsorModel> topContributors(int count) {
    return sortedByContribution().take(count).toList();
  }

  // Check if email already exists
  bool emailExists(String email) {
    return any((sponsor) => sponsor.contactEmail.toLowerCase() == email.toLowerCase());
  }

  // Find sponsor by email
  SponsorModel? findByEmail(String email) {
    try {
      return firstWhere((sponsor) => 
          sponsor.contactEmail.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}

// Helper class for creating sponsor records
class SponsorBuilder {
  String _sponsorId = '';
  String _name = '';
  String _contactEmail = '';
  String _tier = 'bronze';
  String? _logoUrl;
  String? _website;
  String? _phoneNumber;
  String? _address;
  String? _description;
  double _totalContribution = 0.0;
  int _sponsoredEventsCount = 0;
  DateTime _joinedAt = DateTime.now();
  bool _isActive = true;
  Map<String, dynamic>? _benefits;
  Map<String, dynamic>? _contactPerson;
  List<String> _sponsoredEvents = [];
  
  // NEW PROPERTIES
  String? _organizationType;
  String? _taxId;
  String? _contactPersonName;
  String? _businessAddress;
  DateTime? _createdAt;
  DateTime? _updatedAt;
  String? _sponsorSince;

  SponsorBuilder();

  SponsorBuilder withId(String id) {
    _sponsorId = id;
    return this;
  }

  SponsorBuilder withName(String name) {
    _name = name;
    return this;
  }

  SponsorBuilder withEmail(String email) {
    _contactEmail = email;
    return this;
  }

  SponsorBuilder withTier(String tier) {
    _tier = tier;
    return this;
  }

  SponsorBuilder withLogo(String logoUrl) {
    _logoUrl = logoUrl;
    return this;
  }

  SponsorBuilder withWebsite(String website) {
    _website = website;
    return this;
  }

  SponsorBuilder withPhone(String phone) {
    _phoneNumber = phone;
    return this;
  }

  SponsorBuilder withAddress(String address) {
    _address = address;
    return this;
  }

  SponsorBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  SponsorBuilder withContribution(double amount) {
    _totalContribution = amount;
    return this;
  }

  SponsorBuilder withEventsCount(int count) {
    _sponsoredEventsCount = count;
    return this;
  }

  SponsorBuilder joinedAt(DateTime date) {
    _joinedAt = date;
    return this;
  }

  SponsorBuilder setActive(bool active) {
    _isActive = active;
    return this;
  }

  SponsorBuilder withBenefits(Map<String, dynamic> benefits) {
    _benefits = benefits;
    return this;
  }

  SponsorBuilder withContactPerson(Map<String, dynamic> contactPerson) {
    _contactPerson = contactPerson;
    return this;
  }

  SponsorBuilder withSponsoredEvents(List<String> eventIds) {
    _sponsoredEvents = eventIds;
    return this;
  }

  // NEW BUILDER METHODS
  SponsorBuilder withOrganizationType(String organizationType) {
    _organizationType = organizationType;
    return this;
  }

  SponsorBuilder withTaxId(String taxId) {
    _taxId = taxId;
    return this;
  }

  SponsorBuilder withContactPersonName(String contactPersonName) {
    _contactPersonName = contactPersonName;
    return this;
  }

  SponsorBuilder withBusinessAddress(String businessAddress) {
    _businessAddress = businessAddress;
    return this;
  }

  SponsorBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  SponsorBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  SponsorBuilder withSponsorSince(String sponsorSince) {
    _sponsorSince = sponsorSince;
    return this;
  }

  SponsorModel build() {
    return SponsorModel(
      sponsorId: _sponsorId,
      name: _name,
      contactEmail: _contactEmail,
      tier: _tier,
      logoUrl: _logoUrl,
      website: _website,
      phoneNumber: _phoneNumber,
      address: _address,
      description: _description,
      totalContribution: _totalContribution,
      sponsoredEventsCount: _sponsoredEventsCount,
      joinedAt: _joinedAt,
      isActive: _isActive,
      benefits: _benefits,
      contactPerson: _contactPerson,
      sponsoredEvents: _sponsoredEvents,
      
      // NEW PROPERTIES
      organizationType: _organizationType,
      taxId: _taxId,
      contactPersonName: _contactPersonName,
      businessAddress: _businessAddress,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      sponsorSince: _sponsorSince,
    );
  }
}