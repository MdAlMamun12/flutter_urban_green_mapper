import 'dart:convert';

class SponsorshipModel {
  final String sponsorshipId;
  final String eventId;
  final String sponsorId;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final Map<String, dynamic> benefits;
  final DateTime proposedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;
  final String? notes;
  final String? rejectionReason;
  final String? paymentMethod;
  final String? transactionId;
  final Map<String, dynamic>? additionalTerms;
  final List<String>? benefitCategories;

  SponsorshipModel({
    required this.sponsorshipId,
    required this.eventId,
    required this.sponsorId,
    required this.amount,
    required this.status,
    required this.benefits,
    required this.proposedAt,
    this.approvedAt,
    this.rejectedAt,
    this.completedAt,
    this.notes,
    this.rejectionReason,
    this.paymentMethod,
    this.transactionId,
    this.additionalTerms,
    this.benefitCategories,
  });

  // Convert SponsorshipModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sponsorship_id': sponsorshipId,
      'event_id': eventId,
      'sponsor_id': sponsorId,
      'amount': amount,
      'status': status,
      'benefits': benefits,
      'proposed_at': proposedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'rejection_reason': rejectionReason,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'additional_terms': additionalTerms,
      'benefit_categories': benefitCategories,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Create SponsorshipModel from Map (from Firestore)
  factory SponsorshipModel.fromMap(Map<String, dynamic> map) {
    return SponsorshipModel(
      sponsorshipId: map['sponsorship_id'] ?? '',
      eventId: map['event_id'] ?? '',
      sponsorId: map['sponsor_id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      benefits: map['benefits'] != null 
          ? Map<String, dynamic>.from(map['benefits'])
          : {},
      proposedAt: DateTime.parse(map['proposed_at']),
      approvedAt: map['approved_at'] != null ? DateTime.parse(map['approved_at']) : null,
      rejectedAt: map['rejected_at'] != null ? DateTime.parse(map['rejected_at']) : null,
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
      notes: map['notes'],
      rejectionReason: map['rejection_reason'],
      paymentMethod: map['payment_method'],
      transactionId: map['transaction_id'],
      additionalTerms: map['additional_terms'] != null
          ? Map<String, dynamic>.from(map['additional_terms'])
          : null,
      benefitCategories: map['benefit_categories'] != null
          ? List<String>.from(map['benefit_categories'])
          : null,
    );
  }

  // Create a copy of SponsorshipModel with updated values
  SponsorshipModel copyWith({
    String? sponsorshipId,
    String? eventId,
    String? sponsorId,
    double? amount,
    String? status,
    Map<String, dynamic>? benefits,
    DateTime? proposedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    DateTime? completedAt,
    String? notes,
    String? rejectionReason,
    String? paymentMethod,
    String? transactionId,
    Map<String, dynamic>? additionalTerms,
    List<String>? benefitCategories,
  }) {
    return SponsorshipModel(
      sponsorshipId: sponsorshipId ?? this.sponsorshipId,
      eventId: eventId ?? this.eventId,
      sponsorId: sponsorId ?? this.sponsorId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      benefits: benefits ?? this.benefits,
      proposedAt: proposedAt ?? this.proposedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      additionalTerms: additionalTerms ?? this.additionalTerms,
      benefitCategories: benefitCategories ?? this.benefitCategories,
    );
  }

  // Approve sponsorship
  SponsorshipModel approve({String? notes, String? paymentMethod, String? transactionId}) {
    return copyWith(
      status: 'approved',
      approvedAt: DateTime.now(),
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );
  }

  // Reject sponsorship
  SponsorshipModel reject(String reason, {String? notes}) {
    return copyWith(
      status: 'rejected',
      rejectedAt: DateTime.now(),
      rejectionReason: reason,
      notes: notes ?? this.notes,
    );
  }

  // Mark as completed
  SponsorshipModel complete({String? notes}) {
    return copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
      notes: notes ?? this.notes,
    );
  }

  // Update amount
  SponsorshipModel updateAmount(double newAmount, {String? notes}) {
    return copyWith(
      amount: newAmount,
      notes: notes ?? this.notes,
    );
  }

  // Add benefits
  SponsorshipModel addBenefits(Map<String, dynamic> newBenefits) {
    final updatedBenefits = Map<String, dynamic>.from(benefits);
    updatedBenefits.addAll(newBenefits);
    return copyWith(benefits: updatedBenefits);
  }

  // Remove benefit
  SponsorshipModel removeBenefit(String benefitKey) {
    final updatedBenefits = Map<String, dynamic>.from(benefits);
    updatedBenefits.remove(benefitKey);
    return copyWith(benefits: updatedBenefits);
  }

  // Add additional terms
  SponsorshipModel addTerms(Map<String, dynamic> terms) {
    final updatedTerms = Map<String, dynamic>.from(additionalTerms ?? {});
    updatedTerms.addAll(terms);
    return copyWith(additionalTerms: updatedTerms);
  }

  // Update payment information
  SponsorshipModel updatePayment(String method, String transactionId) {
    return copyWith(
      paymentMethod: method,
      transactionId: transactionId,
    );
  }

  // Check if sponsorship is active
  bool get isActive => status == 'approved' || status == 'pending';

  // Check if sponsorship is completed
  bool get isCompleted => status == 'completed';

  // Check if sponsorship is pending approval
  bool get isPending => status == 'pending';

  // Check if sponsorship is approved
  bool get isApproved => status == 'approved';

  // Check if sponsorship is rejected
  bool get isRejected => status == 'rejected';

  // Get sponsorship duration in days
  int get sponsorshipDuration {
    final endDate = completedAt ?? DateTime.now();
    final duration = endDate.difference(proposedAt);
    return duration.inDays;
  }

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'approved':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'rejected':
        return '#F44336'; // Red
      case 'completed':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status text for display
  String get statusText {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending Review';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  // Get status icon for UI
  String get statusIcon {
    switch (status) {
      case 'approved':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'rejected':
        return 'cancel';
      case 'completed':
        return 'verified';
      default:
        return 'help';
    }
  }

  // Get formatted amount
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Calculate platform fee (5%)
  double get platformFee {
    return amount * 0.05;
  }

  // Calculate net amount for organization
  double get netAmount {
    return amount - platformFee;
  }

  // Get benefit categories
  List<String> get effectiveBenefitCategories {
    return benefitCategories ?? _extractBenefitCategories();
  }

  List<String> _extractBenefitCategories() {
    final categories = <String>[];
    
    if (benefits.containsKey('logo_placement')) {
      categories.add('Brand Visibility');
    }
    
    if (benefits.containsKey('social_media') || benefits.containsKey('website_feature')) {
      categories.add('Digital Marketing');
    }
    
    if (benefits.containsKey('event_presence') || benefits.containsKey('verbal_acknowledgment')) {
      categories.add('Event Presence');
    }
    
    if (benefits.containsKey('newsletter') || benefits.containsKey('tier_specific')) {
      categories.add('Exclusive Benefits');
    }
    
    return categories;
  }

  // Get benefit summary
  String get benefitSummary {
    final benefitList = <String>[];
    
    if (benefits['logo_placement'] != null) {
      benefitList.add('Logo Placement');
    }
    
    if (benefits['social_media'] != null) {
      benefitList.add('Social Media');
    }
    
    if (benefits['event_presence'] != null) {
      benefitList.add('Event Presence');
    }
    
    if (benefitList.length > 2) {
      return '${benefitList.take(2).join(', ')} +${benefitList.length - 2} more';
    }
    
    return benefitList.join(', ');
  }

  // Validate sponsorship data
  List<String> validate() {
    final errors = <String>[];

    if (sponsorshipId.isEmpty) {
      errors.add('Sponsorship ID is required');
    }

    if (eventId.isEmpty) {
      errors.add('Event ID is required');
    }

    if (sponsorId.isEmpty) {
      errors.add('Sponsor ID is required');
    }

    if (amount <= 0) {
      errors.add('Sponsorship amount must be greater than 0');
    }

    if (!['pending', 'approved', 'rejected', 'completed'].contains(status)) {
      errors.add('Invalid sponsorship status');
    }

    if (benefits.isEmpty) {
      errors.add('At least one benefit must be specified');
    }

    if (proposedAt.isAfter(DateTime.now())) {
      errors.add('Proposal date cannot be in the future');
    }

    if (approvedAt != null && approvedAt!.isBefore(proposedAt)) {
      errors.add('Approval date cannot be before proposal date');
    }

    if (rejectedAt != null && rejectedAt!.isBefore(proposedAt)) {
      errors.add('Rejection date cannot be before proposal date');
    }

    if (completedAt != null && completedAt!.isBefore(proposedAt)) {
      errors.add('Completion date cannot be before proposal date');
    }

    if (status == 'rejected' && (rejectionReason == null || rejectionReason!.isEmpty)) {
      errors.add('Rejection reason is required for rejected sponsorships');
    }

    return errors;
  }

  // Check if sponsorship is valid
  bool get isValid => validate().isEmpty;

  // Check if sponsorship can be edited (only pending sponsorships can be edited)
  bool get canEdit => status == 'pending';

  // Check if sponsorship can be approved (only pending sponsorships can be approved)
  bool get canApprove => status == 'pending';

  // Check if sponsorship can be rejected (only pending sponsorships can be rejected)
  bool get canReject => status == 'pending';

  // Check if sponsorship can be completed (only approved sponsorships can be completed)
  bool get canComplete => status == 'approved';

  // Get sponsorship value tier based on amount
  String get valueTier {
    if (amount >= 10000) return 'premium';
    if (amount >= 5000) return 'large';
    if (amount >= 1000) return 'medium';
    return 'small';
  }

  // Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Create from JSON string
  factory SponsorshipModel.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return SponsorshipModel.fromMap(map);
  }

  @override
  String toString() {
    return 'SponsorshipModel(sponsorshipId: $sponsorshipId, eventId: $eventId, sponsorId: $sponsorId, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SponsorshipModel &&
        other.sponsorshipId == sponsorshipId &&
        other.eventId == eventId &&
        other.sponsorId == sponsorId &&
        other.amount == amount &&
        other.status == status &&
        other.proposedAt == proposedAt;
  }

  @override
  int get hashCode {
    return sponsorshipId.hashCode ^
        eventId.hashCode ^
        sponsorId.hashCode ^
        amount.hashCode ^
        status.hashCode ^
        proposedAt.hashCode;
  }
}

// Extension methods for List<SponsorshipModel>
extension SponsorshipListExtensions on List<SponsorshipModel> {
  // Filter sponsorships by status
  List<SponsorshipModel> filterByStatus(String status) {
    return where((sponsorship) => sponsorship.status == status).toList();
  }

  // Get all pending sponsorships
  List<SponsorshipModel> get pending {
    return filterByStatus('pending');
  }

  // Get all approved sponsorships
  List<SponsorshipModel> get approved {
    return filterByStatus('approved');
  }

  // Get all rejected sponsorships
  List<SponsorshipModel> get rejected {
    return filterByStatus('rejected');
  }

  // Get all completed sponsorships
  List<SponsorshipModel> get completed {
    return filterByStatus('completed');
  }

  // Get total sponsorship amount
  double get totalAmount {
    return fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);
  }

  // Get total net amount (after platform fees)
  double get totalNetAmount {
    return fold(0.0, (sum, sponsorship) => sum + sponsorship.netAmount);
  }

  // Get total platform fees
  double get totalPlatformFees {
    return fold(0.0, (sum, sponsorship) => sum + sponsorship.platformFee);
  }

  // Group sponsorships by event ID
  Map<String, List<SponsorshipModel>> groupByEvent() {
    final Map<String, List<SponsorshipModel>> grouped = {};
    for (final sponsorship in this) {
      grouped.putIfAbsent(sponsorship.eventId, () => []).add(sponsorship);
    }
    return grouped;
  }

  // Group sponsorships by sponsor ID
  Map<String, List<SponsorshipModel>> groupBySponsor() {
    final Map<String, List<SponsorshipModel>> grouped = {};
    for (final sponsorship in this) {
      grouped.putIfAbsent(sponsorship.sponsorId, () => []).add(sponsorship);
    }
    return grouped;
  }

  // Get sponsorships for a specific event
  List<SponsorshipModel> forEvent(String eventId) {
    return where((sponsorship) => sponsorship.eventId == eventId).toList();
  }

  // Get sponsorships for a specific sponsor
  List<SponsorshipModel> forSponsor(String sponsorId) {
    return where((sponsorship) => sponsorship.sponsorId == sponsorId).toList();
  }

  // Get active sponsorships (approved and pending)
  List<SponsorshipModel> get active {
    return where((sponsorship) => sponsorship.isActive).toList();
  }

  // Sort by amount (descending)
  List<SponsorshipModel> sortedByAmount() {
    return List.from(this)..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // Sort by proposal date (newest first)
  List<SponsorshipModel> sortedByProposalDate() {
    return List.from(this)..sort((a, b) => b.proposedAt.compareTo(a.proposedAt));
  }

  // Get top sponsorships by amount
  List<SponsorshipModel> topSponsorships(int count) {
    return sortedByAmount().take(count).toList();
  }

  // Check if event has any sponsorships
  bool eventHasSponsorships(String eventId) {
    return any((sponsorship) => sponsorship.eventId == eventId);
  }

  // Check if sponsor has any sponsorships
  bool sponsorHasSponsorships(String sponsorId) {
    return any((sponsorship) => sponsorship.sponsorId == sponsorId);
  }

  // Get total sponsorship count by status
  Map<String, int> get statusCounts {
    final counts = <String, int>{};
    for (final sponsorship in this) {
      counts[sponsorship.status] = (counts[sponsorship.status] ?? 0) + 1;
    }
    return counts;
  }
}

// Helper class for creating sponsorship records
class SponsorshipBuilder {
  String _sponsorshipId = '';
  String _eventId = '';
  String _sponsorId = '';
  double _amount = 0.0;
  String _status = 'pending';
  Map<String, dynamic> _benefits = {};
  DateTime _proposedAt = DateTime.now();
  DateTime? _approvedAt;
  DateTime? _rejectedAt;
  DateTime? _completedAt;
  String? _notes;
  String? _rejectionReason;
  String? _paymentMethod;
  String? _transactionId;
  Map<String, dynamic>? _additionalTerms;
  List<String>? _benefitCategories;

  SponsorshipBuilder();

  SponsorshipBuilder withId(String id) {
    _sponsorshipId = id;
    return this;
  }

  SponsorshipBuilder forEvent(String eventId) {
    _eventId = eventId;
    return this;
  }

  SponsorshipBuilder fromSponsor(String sponsorId) {
    _sponsorId = sponsorId;
    return this;
  }

  SponsorshipBuilder withAmount(double amount) {
    _amount = amount;
    return this;
  }

  SponsorshipBuilder withStatus(String status) {
    _status = status;
    return this;
  }

  SponsorshipBuilder withBenefits(Map<String, dynamic> benefits) {
    _benefits = benefits;
    return this;
  }

  SponsorshipBuilder proposedAt(DateTime date) {
    _proposedAt = date;
    return this;
  }

  SponsorshipBuilder approvedAt(DateTime? date) {
    _approvedAt = date;
    return this;
  }

  SponsorshipBuilder rejectedAt(DateTime? date) {
    _rejectedAt = date;
    return this;
  }

  SponsorshipBuilder completedAt(DateTime? date) {
    _completedAt = date;
    return this;
  }

  SponsorshipBuilder withNotes(String notes) {
    _notes = notes;
    return this;
  }

  SponsorshipBuilder withRejectionReason(String reason) {
    _rejectionReason = reason;
    return this;
  }

  SponsorshipBuilder withPayment(String method, String transactionId) {
    _paymentMethod = method;
    _transactionId = transactionId;
    return this;
  }

  SponsorshipBuilder withAdditionalTerms(Map<String, dynamic> terms) {
    _additionalTerms = terms;
    return this;
  }

  SponsorshipBuilder withBenefitCategories(List<String> categories) {
    _benefitCategories = categories;
    return this;
  }

  SponsorshipModel build() {
    return SponsorshipModel(
      sponsorshipId: _sponsorshipId,
      eventId: _eventId,
      sponsorId: _sponsorId,
      amount: _amount,
      status: _status,
      benefits: _benefits,
      proposedAt: _proposedAt,
      approvedAt: _approvedAt,
      rejectedAt: _rejectedAt,
      completedAt: _completedAt,
      notes: _notes,
      rejectionReason: _rejectionReason,
      paymentMethod: _paymentMethod,
      transactionId: _transactionId,
      additionalTerms: _additionalTerms,
      benefitCategories: _benefitCategories,
    );
  }
}