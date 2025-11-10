// ==================== COLLECTION NAMES ====================

class FirestoreCollections {
  static const String users = 'users';
  static const String greenSpaces = 'green_spaces';
  static const String plants = 'plants';
  static const String reports = 'reports';
  static const String events = 'events';
  static const String participations = 'participations';
  static const String sponsors = 'sponsors';
  static const String sponsorships = 'sponsorships';
  static const String adoptions = 'adoptions';
  static const String careReports = 'care_reports';
  static const String notifications = 'notifications';
  static const String comments = 'comments';
  static const String verificationRequests = 'verification_requests';
}

// ==================== USER FIELDS ====================

class UserFields {
  static const String userId = 'user_id';
  static const String name = 'name';
  static const String email = 'email';
  static const String role = 'role';
  static const String location = 'location';
  static const String impactScore = 'impact_score';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String phoneNumber = 'phone_number';
  static const String profilePicture = 'profile_picture';
  static const String isEmailVerified = 'is_email_verified';
  static const String isActive = 'is_active';
  static const String preferences = 'preferences';
  static const String settings = 'settings';
  static const String verificationStatus = 'verification_status';
  static const String verifiedAt = 'verified_at';
  static const String verifiedBy = 'verified_by';
  static const String isReported = 'is_reported';
  static const String isSuspended = 'is_suspended';
  static const String suspendedAt = 'suspended_at';
  static const String suspensionReason = 'suspension_reason';
  static const String suspendedBy = 'suspended_by';
  static const String totalContribution = 'total_contribution';
  static const String sponsoredEventsCount = 'sponsored_events_count';
}

// ==================== GREEN SPACE FIELDS ====================

class GreenSpaceFields {
  static const String spaceId = 'space_id';
  static const String name = 'name';
  static const String boundary = 'boundary';
  static const String type = 'type';
  static const String status = 'status';
  static const String description = 'description';
  static const String location = 'location';
  static const String area = 'area';
  static const String plantCount = 'plant_count';
  static const String lastMaintenance = 'last_maintenance';
  static const String maintainedBy = 'maintained_by';
  static const String photos = 'photos';
  static const String tags = 'tags';
}

// ==================== PLANT FIELDS ====================

class PlantFields {
  static const String plantId = 'plant_id';
  static const String spaceId = 'space_id';
  static const String species = 'species';
  static const String plantingDate = 'planting_date';
  static const String healthStatus = 'health_status';
  static const String lastWatered = 'last_watered';
  static const String lastFertilized = 'last_fertilized';
  static const String nextCareDate = 'next_care_date';
  static const String careInstructions = 'care_instructions';
  static const String photos = 'photos';
  static const String growthStage = 'growth_stage';
  static const String notes = 'notes';
}

// ==================== REPORT FIELDS ====================

class ReportFields {
  static const String reportId = 'report_id';
  static const String userId = 'user_id';
  static const String spaceId = 'space_id';
  static const String description = 'description';
  static const String photos = 'photos';
  static const String status = 'status';
  static const String type = 'type';
  static const String priority = 'priority';
  static const String assignedTo = 'assigned_to';
  static const String resolvedAt = 'resolved_at';
  static const String resolutionNotes = 'resolution_notes';
  static const String flagCount = 'flag_count';
  static const String isSpam = 'is_spam';
  static const String isRemoved = 'is_removed';
  static const String removedAt = 'removed_at';
  static const String removalReason = 'removal_reason';
  static const String removedBy = 'removed_by';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

// ==================== EVENT FIELDS ====================

class EventFields {
  static const String eventId = 'event_id';
  static const String ngoId = 'ngo_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String maxParticipants = 'max_participants';
  static const String status = 'status';
  static const String location = 'location';
  static const String photos = 'photos';
  static const String requirements = 'requirements';
  static const String equipmentProvided = 'equipment_provided';
  static const String skillsRequired = 'skills_required';
  static const String budget = 'budget';
  static const String actualParticipants = 'actual_participants';
  static const String eventCompletedAt = 'completed_at';
  static const String eventFeedback = 'feedback';
  static const String averageRating = 'average_rating';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

// ==================== PARTICIPATION FIELDS ====================

class ParticipationFields {
  static const String participationId = 'participation_id';
  static const String userId = 'user_id';
  static const String eventId = 'event_id';
  static const String hoursContributed = 'hours_contributed';
  static const String status = 'status';
  static const String joinedAt = 'joined_at';
  static const String attendedAt = 'attended_at';
  static const String cancelledAt = 'cancelled_at';
  static const String participationFeedback = 'feedback';
  static const String rating = 'rating';
  static const String certificateIssued = 'certificate_issued';
  static const String certificateIssuedAt = 'certificate_issued_at';
  static const String updatedAt = 'updated_at';
}

// ==================== SPONSOR FIELDS ====================

class SponsorFields {
  static const String sponsorId = 'sponsor_id';
  static const String name = 'name';
  static const String contactEmail = 'contact_email';
  static const String tier = 'tier';
  static const String logoUrl = 'logo_url';
  static const String website = 'website';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String contactPerson = 'contact_person';
  static const String description = 'description';
  static const String joinedAt = 'joined_at';
  static const String isActive = 'is_active';
  static const String totalContribution = 'total_contribution';
  static const String sponsoredEventsCount = 'sponsored_events_count';
  static const String updatedAt = 'updated_at';
}

// ==================== SPONSORSHIP FIELDS ====================

class SponsorshipFields {
  static const String sponsorshipId = 'sponsorship_id';
  static const String eventId = 'event_id';
  static const String sponsorId = 'sponsor_id';
  static const String amount = 'amount';
  static const String benefits = 'benefits';
  static const String proposedAt = 'proposed_at';
  static const String approvedAt = 'approved_at';
  static const String rejectedAt = 'rejected_at';
  static const String sponsorshipCompletedAt = 'completed_at';
  static const String paymentMethod = 'payment_method';
  static const String transactionId = 'transaction_id';
  static const String rejectionReason = 'rejection_reason';
  static const String status = 'status';
  static const String updatedAt = 'updated_at';
}

// ==================== ADOPTION FIELDS ====================

class AdoptionFields {
  static const String adoptionId = 'adoption_id';
  static const String userId = 'user_id';
  static const String plantId = 'plant_id';
  static const String careSchedule = 'care_schedule';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String status = 'status';
  static const String lastCareDate = 'last_care_date';
  static const String adoptionNextCareDate = 'next_care_date';
  static const String adoptionCareNotes = 'care_notes';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

// ==================== CARE REPORT FIELDS ====================

class CareReportFields {
  static const String careReportId = 'care_report_id';
  static const String adoptionId = 'adoption_id';
  static const String careType = 'care_type';
  static const String careDate = 'care_date';
  static const String careNotes = 'care_notes';
  static const String photos = 'photos';
  static const String healthUpdate = 'health_update';
  static const String createdAt = 'created_at';
}

// ==================== NOTIFICATION FIELDS ====================

class NotificationFields {
  static const String notificationId = 'notification_id';
  static const String userId = 'user_id';
  static const String title = 'title';
  static const String message = 'message';
  static const String type = 'type';
  static const String isRead = 'is_read';
  static const String createdAt = 'created_at';
  static const String actionUrl = 'action_url';
  static const String audience = 'audience';
  static const String eventId = 'event_id';
  static const String reportId = 'report_id';
}

// ==================== COMMENT FIELDS ====================

class CommentFields {
  static const String commentId = 'comment_id';
  static const String userId = 'user_id';
  static const String content = 'content';
  static const String photos = 'photos';
  static const String likes = 'likes';
  static const String createdAt = 'created_at';
  static const String parentCommentId = 'parent_comment_id';
  static const String isRemoved = 'is_removed';
  static const String reportId = 'report_id';
  static const String eventId = 'event_id';
}

// ==================== VERIFICATION REQUEST FIELDS ====================

class VerificationRequestFields {
  static const String verificationId = 'verification_id';
  static const String userId = 'user_id';
  static const String documentType = 'document_type';
  static const String documentUrl = 'document_url';
  static const String status = 'status';
  static const String submittedAt = 'submitted_at';
  static const String reviewedAt = 'reviewed_at';
  static const String reviewedBy = 'reviewed_by';
  static const String reviewNotes = 'review_notes';
}

// ==================== STATUS VALUES ====================

class StatusValues {
  // User status
  static const String active = 'active';
  static const String suspended = 'suspended';
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  
  // Report status
  static const String reportPending = 'pending';
  static const String reportInProgress = 'in_progress';
  static const String reportResolved = 'resolved';
  static const String reportClosed = 'closed';
  
  // Event status
  static const String eventUpcoming = 'upcoming';
  static const String eventOngoing = 'ongoing';
  static const String eventCompleted = 'completed';
  static const String eventCancelled = 'cancelled';
  
  // Participation status
  static const String participationRegistered = 'registered';
  static const String participationAttended = 'attended';
  static const String participationCancelled = 'cancelled';
  static const String participationNoShow = 'no_show';
  
  // Sponsorship status
  static const String sponsorshipPending = 'pending';
  static const String sponsorshipApproved = 'approved';
  static const String sponsorshipRejected = 'rejected';
  static const String sponsorshipCompleted = 'completed';
  
  // Adoption status
  static const String adoptionActive = 'active';
  static const String adoptionCompleted = 'completed';
  static const String adoptionCancelled = 'cancelled';
  
  // Green space status
  static const String spaceHealthy = 'healthy';
  static const String spaceDegraded = 'degraded';
  static const String spaceRestored = 'restored';
  static const String spaceUnderMaintenance = 'under_maintenance';
  
  // Plant health status
  static const String plantExcellent = 'excellent';
  static const String plantGood = 'good';
  static const String plantFair = 'fair';
  static const String plantPoor = 'poor';
  static const String plantCritical = 'critical';
  
  // Verification status
  static const String verificationPending = 'pending';
  static const String verificationApproved = 'approved';
  static const String verificationRejected = 'rejected';
}

// ==================== ROLE VALUES ====================

class RoleValues {
  static const String citizen = 'citizen';
  static const String ngo = 'ngo';
  static const String admin = 'admin';
  static const String moderator = 'moderator';
}

// ==================== TIER VALUES ====================

class TierValues {
  static const String bronze = 'bronze';
  static const String silver = 'silver';
  static const String gold = 'gold';
  static const String platinum = 'platinum';
}

// ==================== TYPE VALUES ====================

class TypeValues {
  // Green space types
  static const String park = 'park';
  static const String garden = 'garden';
  static const String forest = 'forest';
  static const String urbanFarm = 'urban_farm';
  static const String communityGarden = 'community_garden';
  
  // Report types
  static const String maintenance = 'maintenance';
  static const String vandalism = 'vandalism';
  static const String litter = 'litter';
  static const String plantHealth = 'plant_health';
  static const String safety = 'safety';
  static const String suggestion = 'suggestion';
  
  // Event types
  static const String treePlanting = 'tree_planting';
  static const String cleanup = 'cleanup';
  static const String workshop = 'workshop';
  static const String fundraising = 'fundraising';
  static const String awareness = 'awareness';
  
  // Care types
  static const String watering = 'watering';
  static const String fertilizing = 'fertilizing';
  static const String pruning = 'pruning';
  static const String pestControl = 'pest_control';
  static const String weeding = 'weeding';
  
  // Document types for verification
  static const String ngoRegistration = 'ngo_registration';
  static const String businessLicense = 'business_license';
  static const String taxCertificate = 'tax_certificate';
}

// ==================== NOTIFICATION TYPES ====================

class NotificationTypeValues {
  static const String eventReminder = 'event_reminder';
  static const String reportUpdate = 'report_update';
  static const String plantCare = 'plant_care';
  static const String achievement = 'achievement';
  static const String system = 'system';
  static const String broadcast = 'broadcast';
  static const String eventUpdate = 'event_update';
  static const String verificationUpdate = 'verification_update';
}

// ==================== PREFERENCE CATEGORIES ====================

class PreferenceValues {
  static const String treePlanting = 'tree_planting';
  static const String cleanupEvents = 'cleanup_events';
  static const String gardening = 'gardening';
  static const String wildlifeConservation = 'wildlife_conservation';
  static const String education = 'education';
  static const String communityEvents = 'community_events';
}

// ==================== SETTINGS CATEGORIES ====================

class SettingsCategories {
  static const String notifications = 'notifications';
  static const String privacy = 'privacy';
  static const String appearance = 'appearance';
  static const String language = 'language';
}

// ==================== LEGACY COMPATIBILITY ====================

/// Legacy class for backward compatibility
class FirestoreConstants {
  // Collections
  static const String usersCollection = FirestoreCollections.users;
  static const String greenSpacesCollection = FirestoreCollections.greenSpaces;
  static const String plantsCollection = FirestoreCollections.plants;
  static const String reportsCollection = FirestoreCollections.reports;
  static const String eventsCollection = FirestoreCollections.events;
  static const String participationsCollection = FirestoreCollections.participations;
  static const String sponsorsCollection = FirestoreCollections.sponsors;
  static const String sponsorshipsCollection = FirestoreCollections.sponsorships;
  static const String adoptionsCollection = FirestoreCollections.adoptions;
  static const String careReportsCollection = FirestoreCollections.careReports;
  
  // Common fields
  static const String userId = UserFields.userId;
  static const String name = UserFields.name;
  static const String email = UserFields.email;
  static const String role = UserFields.role;
  static const String location = UserFields.location;
  static const String impactScore = UserFields.impactScore;
  static const String createdAt = UserFields.createdAt;
  
  // Other common fields
  static const String spaceId = GreenSpaceFields.spaceId;
  static const String spaceName = GreenSpaceFields.name;
  static const String boundary = GreenSpaceFields.boundary;
  static const String spaceType = GreenSpaceFields.type;
  static const String spaceStatus = GreenSpaceFields.status;
  
  static const String plantId = PlantFields.plantId;
  static const String species = PlantFields.species;
  static const String plantingDate = PlantFields.plantingDate;
  static const String healthStatus = PlantFields.healthStatus;
  
  static const String reportId = ReportFields.reportId;
  static const String description = ReportFields.description;
  static const String photos = ReportFields.photos;
  static const String reportStatus = ReportFields.status;
  
  static const String eventId = EventFields.eventId;
  static const String ngoId = EventFields.ngoId;
  static const String title = EventFields.title;
  static const String eventDescription = EventFields.description;
  static const String startTime = EventFields.startTime;
  static const String endTime = EventFields.endTime;
  static const String maxParticipants = EventFields.maxParticipants;
  static const String eventStatus = EventFields.status;
  
  static const String participationId = ParticipationFields.participationId;
  static const String hoursContributed = ParticipationFields.hoursContributed;
  static const String participationStatus = ParticipationFields.status;
  
  static const String sponsorId = SponsorFields.sponsorId;
  static const String sponsorName = SponsorFields.name;
  static const String contactEmail = SponsorFields.contactEmail;
  static const String tier = SponsorFields.tier;
  
  static const String sponsorshipId = SponsorshipFields.sponsorshipId;
  static const String amount = SponsorshipFields.amount;
  static const String benefits = SponsorshipFields.benefits;
}