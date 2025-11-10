import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/participation_model.dart';
import 'package:urban_green_mapper/core/models/sponsorship_model.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== UTILITY TYPE SAFETY METHODS ====================
  
  /// Safe type conversion from Object to Map<String, dynamic>
  // ignore: unused_element
  Map<String, dynamic> _convertToMap(Object data) {
    return data as Map<String, dynamic>;
  }
  
  /// Safe document data extraction
  Map<String, dynamic> _getDocumentData(DocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }
  
  /// Safe query document data extraction
  Map<String, dynamic> _getQueryDocumentData(QueryDocumentSnapshot doc) {
    return doc.data() as Map<String, dynamic>;
  }

  // ==================== SPONSOR OPERATIONS ====================

  /// Add a new sponsor - UPDATED to use users collection
  Future<void> addSponsor(SponsorModel sponsor) async {
    try {
      print('🏢 Adding new sponsor: ${sponsor.sponsorId}');
      print('📊 Organization: ${sponsor.name}, Tier: ${sponsor.tier}');
      
      // Create a user document with sponsor role in the users collection
      final userData = {
        'user_id': sponsor.sponsorId,
        'email': sponsor.contactEmail,
        'name': sponsor.contactPersonDisplayName,
        'role': 'sponsor',
        'organization_name': sponsor.name,
        'organization_type': sponsor.organizationType,
        'contact_person': sponsor.contactPersonDisplayName,
        'sponsor_tier': sponsor.tier,
        'website': sponsor.website,
        'business_address': sponsor.businessAddress ?? sponsor.address,
        'tax_id': sponsor.taxId,
        'phone_number': sponsor.phoneNumber,
        'is_active_sponsor': sponsor.isActive,
        'sponsor_since': sponsor.sponsorSince ?? DateTime.now().toIso8601String(),
        'total_contribution': sponsor.totalContribution,
        'sponsored_events': sponsor.sponsoredEvents,
        'impact_score': 0,
        'created_at': sponsor.createdAt ?? DateTime.now(),
        'updated_at': sponsor.updatedAt ?? DateTime.now(),
      };
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsor.sponsorId)
          .set(userData);
      
      print('✅ Sponsor added successfully to users collection: ${sponsor.name}');
    } catch (e) {
      print('❌ Failed to add sponsor: $e');
      throw Exception('Failed to add sponsor: $e');
    }
  }

  /// Update sponsor information - UPDATED to use users collection
  Future<void> updateSponsor(String sponsorId, Map<String, dynamic> data) async {
    try {
      print('📝 Updating sponsor: $sponsorId');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsor updated successfully');
    } catch (e) {
      print('❌ Failed to update sponsor: $e');
      throw Exception('Failed to update sponsor: $e');
    }
  }

  /// Get sponsor by ID (SponsorModel version) - UPDATED to use users collection
  Future<SponsorModel> getSponsorById(String sponsorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .get();
      
      if (doc.exists) {
        final userData = _getDocumentData(doc);
        return SponsorModel(
          sponsorId: sponsorId,
          name: userData['organization_name'] ?? userData['name'] ?? '',
          contactEmail: userData['email'] ?? '',
          tier: userData['sponsor_tier'] ?? 'bronze',
          logoUrl: userData['logo_url'],
          website: userData['website'],
          phoneNumber: userData['phone_number'],
          address: userData['business_address'] ?? userData['address'],
          description: userData['description'],
          totalContribution: (userData['total_contribution'] ?? 0).toDouble(),
          sponsoredEventsCount: (userData['sponsored_events'] as List? ?? []).length,
          joinedAt: userData['sponsor_since'] != null 
              ? DateTime.parse(userData['sponsor_since'])
              : DateTime.now(),
          isActive: userData['is_active_sponsor'] ?? false,
          benefits: userData['benefits'] != null 
              ? Map<String, dynamic>.from(userData['benefits'])
              : null,
          contactPerson: {
            'name': userData['contact_person'] ?? userData['name'] ?? '',
            'email': userData['email'] ?? '',
            'phone': userData['phone_number'] ?? '',
          },
          sponsoredEvents: List<String>.from(userData['sponsored_events'] ?? []),
          organizationType: userData['organization_type'],
          taxId: userData['tax_id'],
          contactPersonName: userData['contact_person'],
          businessAddress: userData['business_address'],
          createdAt: userData['created_at'] != null 
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
          updatedAt: userData['updated_at'] != null 
              ? DateTime.parse(userData['updated_at'])
              : DateTime.now(),
          sponsorSince: userData['sponsor_since'],
        );
      } else {
        throw Exception('Sponsor not found');
      }
    } catch (e) {
      throw Exception('Failed to get sponsor: $e');
    }
  }

  /// Get all sponsors (SponsorModel version) - UPDATED to use users collection
  Future<List<SponsorModel>> getAllSponsorModels() async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .orderBy('total_contribution', descending: true)
          .get();

      return sponsorsSnapshot.docs.map((doc) {
        final userData = _getQueryDocumentData(doc);
        return SponsorModel(
          sponsorId: doc.id,
          name: userData['organization_name'] ?? userData['name'] ?? '',
          contactEmail: userData['email'] ?? '',
          tier: userData['sponsor_tier'] ?? 'bronze',
          logoUrl: userData['logo_url'],
          website: userData['website'],
          phoneNumber: userData['phone_number'],
          address: userData['business_address'] ?? userData['address'],
          description: userData['description'],
          totalContribution: (userData['total_contribution'] ?? 0).toDouble(),
          sponsoredEventsCount: (userData['sponsored_events'] as List? ?? []).length,
          joinedAt: userData['sponsor_since'] != null 
              ? DateTime.parse(userData['sponsor_since'])
              : DateTime.now(),
          isActive: userData['is_active_sponsor'] ?? false,
          benefits: userData['benefits'] != null 
              ? Map<String, dynamic>.from(userData['benefits'])
              : null,
          contactPerson: {
            'name': userData['contact_person'] ?? userData['name'] ?? '',
            'email': userData['email'] ?? '',
            'phone': userData['phone_number'] ?? '',
          },
          sponsoredEvents: List<String>.from(userData['sponsored_events'] ?? []),
          organizationType: userData['organization_type'],
          taxId: userData['tax_id'],
          contactPersonName: userData['contact_person'],
          businessAddress: userData['business_address'],
          createdAt: userData['created_at'] != null 
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
          updatedAt: userData['updated_at'] != null 
              ? DateTime.parse(userData['updated_at'])
              : DateTime.now(),
          sponsorSince: userData['sponsor_since'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all sponsors: $e');
    }
  }

  /// Delete sponsor - UPDATED to use users collection
  Future<void> deleteSponsor(String sponsorId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            'is_active_sponsor': false,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to delete sponsor: $e');
    }
  }

  /// Get sponsors by tier (SponsorModel version) - UPDATED to use users collection
  Future<List<SponsorModel>> getSponsorsByTierModel(String tier) async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .where('sponsor_tier', isEqualTo: tier)
          .orderBy('total_contribution', descending: true)
          .get();

      return sponsorsSnapshot.docs.map((doc) {
        final userData = _getQueryDocumentData(doc);
        return SponsorModel(
          sponsorId: doc.id,
          name: userData['organization_name'] ?? userData['name'] ?? '',
          contactEmail: userData['email'] ?? '',
          tier: userData['sponsor_tier'] ?? 'bronze',
          logoUrl: userData['logo_url'],
          website: userData['website'],
          phoneNumber: userData['phone_number'],
          address: userData['business_address'] ?? userData['address'],
          description: userData['description'],
          totalContribution: (userData['total_contribution'] ?? 0).toDouble(),
          sponsoredEventsCount: (userData['sponsored_events'] as List? ?? []).length,
          joinedAt: userData['sponsor_since'] != null 
              ? DateTime.parse(userData['sponsor_since'])
              : DateTime.now(),
          isActive: userData['is_active_sponsor'] ?? false,
          benefits: userData['benefits'] != null 
              ? Map<String, dynamic>.from(userData['benefits'])
              : null,
          contactPerson: {
            'name': userData['contact_person'] ?? userData['name'] ?? '',
            'email': userData['email'] ?? '',
            'phone': userData['phone_number'] ?? '',
          },
          sponsoredEvents: List<String>.from(userData['sponsored_events'] ?? []),
          organizationType: userData['organization_type'],
          taxId: userData['tax_id'],
          contactPersonName: userData['contact_person'],
          businessAddress: userData['business_address'],
          createdAt: userData['created_at'] != null 
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
          updatedAt: userData['updated_at'] != null 
              ? DateTime.parse(userData['updated_at'])
              : DateTime.now(),
          sponsorSince: userData['sponsor_since'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sponsors by tier: $e');
    }
  }

  // ==================== SPONSORSHIP OPERATIONS ====================

  /// Create a new sponsorship
  Future<void> createSponsorship(SponsorshipModel sponsorship) async {
    try {
      print('🤝 Creating new sponsorship: ${sponsorship.sponsorshipId}');
      print('🏢 Sponsor: ${sponsorship.sponsorId}, Event: ${sponsorship.eventId}');
      print('💰 Amount: \$${sponsorship.amount}');
      
      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorship.sponsorshipId)
          .set(sponsorship.toMap());
      
      await updateSponsorContribution(sponsorship.sponsorId, sponsorship.amount);
      await addSponsoredEvent(sponsorship.sponsorId, sponsorship.eventId);
      
      print('✅ Sponsorship created successfully');
    } catch (e) {
      print('❌ Failed to create sponsorship: $e');
      throw Exception('Failed to create sponsorship: $e');
    }
  }

  /// Get all sponsorships
  Stream<QuerySnapshot> getSponsorships() {
    return _firestore
        .collection(FirestoreConstants.sponsorshipsCollection)
        .orderBy('proposed_at', descending: true)
        .snapshots();
  }

  /// Get sponsorships by event
  Stream<QuerySnapshot> getSponsorshipsByEvent(String eventId) {
    return _firestore
        .collection(FirestoreConstants.sponsorshipsCollection)
        .where('event_id', isEqualTo: eventId)
        .orderBy('amount', descending: true)
        .snapshots();
  }

  /// Get sponsorships by sponsor
  Stream<QuerySnapshot> getSponsorshipsBySponsor(String sponsorId) async* {
    try {
      // ignore: unused_local_variable
      final user = await getSponsorUser(sponsorId);
      
      yield* _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .where('sponsor_id', isEqualTo: sponsorId)
          .orderBy('proposed_at', descending: true)
          .snapshots();
    } catch (e) {
      print('❌ User is not a sponsor or not found: $e');
      yield* const Stream.empty();
    }
  }

  /// Get pending sponsorships
  Stream<QuerySnapshot> getPendingSponsorships() {
    return _firestore
        .collection(FirestoreConstants.sponsorshipsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('proposed_at', descending: true)
        .snapshots();
  }

  /// Get approved sponsorships
  Stream<QuerySnapshot> getApprovedSponsorships() {
    return _firestore
        .collection(FirestoreConstants.sponsorshipsCollection)
        .where('status', isEqualTo: 'approved')
        .orderBy('approved_at', descending: true)
        .snapshots();
  }

  /// Get completed sponsorships
  Stream<QuerySnapshot> getCompletedSponsorships() {
    return _firestore
        .collection(FirestoreConstants.sponsorshipsCollection)
        .where('status', isEqualTo: 'completed')
        .orderBy('completed_at', descending: true)
        .snapshots();
  }

  /// Update sponsorship status
  Future<void> updateSponsorshipStatus(
    String sponsorshipId, 
    String status, {
    String? rejectionReason,
    String? paymentMethod,
    String? transactionId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'approved') {
        updateData['approved_at'] = DateTime.now().toIso8601String();
        if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
        if (transactionId != null) updateData['transaction_id'] = transactionId;
      } else if (status == 'rejected') {
        updateData['rejected_at'] = DateTime.now().toIso8601String();
        if (rejectionReason != null) updateData['rejection_reason'] = rejectionReason;
      } else if (status == 'completed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .update(updateData);
      
      print('✅ Sponsorship status updated to: $status');
    } catch (e) {
      print('❌ Failed to update sponsorship status: $e');
      throw Exception('Failed to update sponsorship status: $e');
    }
  }

  /// Update sponsorship amount
  Future<void> updateSponsorshipAmount(String sponsorshipId, double newAmount) async {
    try {
      print('💰 Updating sponsorship amount: $sponsorshipId');
      print('💵 New amount: \$$newAmount');
      
      final currentSponsorship = await getSponsorship(sponsorshipId);
      final amountDifference = newAmount - currentSponsorship.amount;
      
      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .update({
            'amount': newAmount,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      if (currentSponsorship.isApproved || currentSponsorship.isCompleted) {
        await updateSponsorContribution(currentSponsorship.sponsorId, amountDifference);
      }
      
      print('✅ Sponsorship amount updated successfully');
    } catch (e) {
      print('❌ Failed to update sponsorship amount: $e');
      throw Exception('Failed to update sponsorship amount: $e');
    }
  }

  /// Update sponsorship benefits
  Future<void> updateSponsorshipBenefits(
    String sponsorshipId, 
    Map<String, dynamic> benefits
  ) async {
    try {
      print('🎁 Updating sponsorship benefits: $sponsorshipId');
      
      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .update({
            'benefits': benefits,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsorship benefits updated successfully');
    } catch (e) {
      print('❌ Failed to update sponsorship benefits: $e');
      throw Exception('Failed to update sponsorship benefits: $e');
    }
  }

  /// Add additional terms to sponsorship
  Future<void> addSponsorshipTerms(
    String sponsorshipId, 
    Map<String, dynamic> additionalTerms
  ) async {
    try {
      print('📝 Adding sponsorship terms: $sponsorshipId');
      
      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .update({
            'additional_terms': additionalTerms,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsorship terms added successfully');
    } catch (e) {
      print('❌ Failed to add sponsorship terms: $e');
      throw Exception('Failed to add sponsorship terms: $e');
    }
  }

  /// Get sponsorship by ID
  Future<SponsorshipModel> getSponsorship(String sponsorshipId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .get();
      
      if (doc.exists) {
        return SponsorshipModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Sponsorship not found');
      }
    } catch (e) {
      throw Exception('Failed to get sponsorship: $e');
    }
  }

  /// Delete sponsorship
  Future<void> deleteSponsorship(String sponsorshipId) async {
    try {
      print('🗑️ Deleting sponsorship: $sponsorshipId');
      
      final sponsorship = await getSponsorship(sponsorshipId);
      
      await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .doc(sponsorshipId)
          .delete();
      
      if (sponsorship.isApproved || sponsorship.isCompleted) {
        await removeSponsoredEvent(sponsorship.sponsorId, sponsorship.eventId);
        await updateSponsorContribution(sponsorship.sponsorId, -sponsorship.amount);
      }
      
      print('✅ Sponsorship deleted successfully');
    } catch (e) {
      print('❌ Failed to delete sponsorship: $e');
      throw Exception('Failed to delete sponsorship: $e');
    }
  }

  /// Get sponsorship statistics for a sponsor
  Future<Map<String, dynamic>> getSponsorSponsorshipStats(String sponsorId) async {
    try {
      final sponsorshipsSnapshot = await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .where('sponsor_id', isEqualTo: sponsorId)
          .get();

      final sponsorships = sponsorshipsSnapshot.docs.map((doc) {
        return SponsorshipModel.fromMap(_getQueryDocumentData(doc));
      }).toList();

      final total = sponsorships.length;
      final approved = sponsorships.where((s) => s.isApproved).length;
      final pending = sponsorships.where((s) => s.isPending).length;
      final rejected = sponsorships.where((s) => s.isRejected).length;
      final completed = sponsorships.where((s) => s.isCompleted).length;

      final totalAmount = sponsorships
          .where((s) => s.isApproved || s.isCompleted)
          .fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);

      return {
        'total_sponsorships': total,
        'approved_sponsorships': approved,
        'pending_sponsorships': pending,
        'rejected_sponsorships': rejected,
        'completed_sponsorships': completed,
        'total_amount': totalAmount,
        'approval_rate': total > 0 ? (approved / total * 100) : 0,
        'completion_rate': total > 0 ? (completed / total * 100) : 0,
      };
    } catch (e) {
      throw Exception('Failed to get sponsor sponsorship stats: $e');
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      print('📝 Creating user in Firestore: ${user.userId}');
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(user.userId)
          .set(user.toMap());
      print('✅ User created successfully in Firestore: ${user.userId}');
    } catch (e) {
      print('❌ Failed to create user in Firestore: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Create a new sponsor user
  Future<void> createSponsorUser(UserModel sponsor) async {
    try {
      print('🏢 Creating sponsor user in Firestore: ${sponsor.userId}');
      print('📊 Organization: ${sponsor.organizationName}, Tier: ${sponsor.sponsorTier}');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsor.userId)
          .set(sponsor.toMap(), SetOptions(merge: true));
      
      print('✅ Sponsor user created successfully: ${sponsor.organizationName}');
    } catch (e) {
      print('❌ Failed to create sponsor user: $e');
      throw Exception('Failed to create sponsor user: $e');
    }
  }

  /// Get user by ID
  Future<UserModel> getUser(String userId) async {
    try {
      print('📖 Getting user from Firestore: $userId');
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final userData = _getDocumentData(doc);
        print('✅ User found in Firestore: $userId');
        return UserModel.fromMap(userData);
      } else {
        print('❌ User not found in Firestore: $userId');
        throw Exception('User not found');
      }
    } catch (e) {
      print('❌ Failed to get user from Firestore: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return await getUser(user.uid);
  }

  /// Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Update user to sponsor role
  Future<void> upgradeUserToSponsor({
    required String userId,
    required String organizationName,
    required String organizationType,
    required String contactPerson,
    required String sponsorTier,
    String? website,
    String? businessAddress,
    String? taxId,
    String? phoneNumber,
  }) async {
    try {
      print('🔄 Upgrading user to sponsor: $userId');
      print('🏢 Organization: $organizationName, Tier: $sponsorTier');
      
      final updateData = {
        'role': 'sponsor',
        'organization_name': organizationName,
        'organization_type': organizationType,
        'contact_person': contactPerson,
        'sponsor_tier': sponsorTier,
        'is_active_sponsor': true,
        'sponsor_since': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (website != null) updateData['website'] = website;
      if (businessAddress != null) updateData['business_address'] = businessAddress;
      if (taxId != null) updateData['tax_id'] = taxId;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update(updateData);
      
      print('✅ User upgraded to sponsor successfully');
    } catch (e) {
      print('❌ Failed to upgrade user to sponsor: $e');
      throw Exception('Failed to upgrade user to sponsor: $e');
    }
  }

  /// Complete sponsor registration
  Future<void> completeSponsorRegistration({
    required String userId,
    required String organizationName,
    required String organizationType,
    required String contactPerson,
    required String sponsorTier,
    required String email,
    String? website,
    String? businessAddress,
    String? taxId,
    String? phoneNumber,
    String? name,
  }) async {
    try {
      print('🎯 Completing sponsor registration: $userId');
      print('🏢 Organization: $organizationName, Tier: $sponsorTier');

      final userExists = await userExistsInFirestore(userId);
      
      if (userExists) {
        await upgradeUserToSponsor(
          userId: userId,
          organizationName: organizationName,
          organizationType: organizationType,
          contactPerson: contactPerson,
          sponsorTier: sponsorTier,
          website: website,
          businessAddress: businessAddress,
          taxId: taxId,
          phoneNumber: phoneNumber,
        );
      } else {
        final sponsorUser = UserModel(
          userId: userId,
          email: email,
          name: name ?? contactPerson,
          role: 'sponsor',
          organizationName: organizationName,
          organizationType: organizationType,
          contactPerson: contactPerson,
          sponsorTier: sponsorTier,
          website: website,
          businessAddress: businessAddress,
          taxId: taxId,
          phoneNumber: phoneNumber,
          isActiveSponsor: true,
          sponsorSince: DateTime.now(),
          totalContribution: 0.0,
          sponsoredEvents: [],
          impactScore: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createSponsorUser(sponsorUser);
      }

      print('✅ Sponsor registration completed successfully');
    } catch (e) {
      print('❌ Failed to complete sponsor registration: $e');
      throw Exception('Failed to complete sponsor registration: $e');
    }
  }

  /// Update sponsor profile
  Future<void> updateSponsorProfile({
    required String userId,
    String? organizationName,
    String? organizationType,
    String? website,
    String? contactPerson,
    String? sponsorTier,
    String? businessAddress,
    String? taxId,
    String? paymentMethod,
    String? phoneNumber,
  }) async {
    try {
      print('📝 Updating sponsor profile: $userId');
      
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (organizationName != null) updateData['organization_name'] = organizationName;
      if (organizationType != null) updateData['organization_type'] = organizationType;
      if (website != null) updateData['website'] = website;
      if (contactPerson != null) updateData['contact_person'] = contactPerson;
      if (sponsorTier != null) updateData['sponsor_tier'] = sponsorTier;
      if (businessAddress != null) updateData['business_address'] = businessAddress;
      if (taxId != null) updateData['tax_id'] = taxId;
      if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update(updateData);
      
      print('✅ Sponsor profile updated successfully');
    } catch (e) {
      print('❌ Failed to update sponsor profile: $e');
      throw Exception('Failed to update sponsor profile: $e');
    }
  }

  /// Update sponsor contribution
  Future<void> updateSponsorContribution(String sponsorId, double amount) async {
    try {
      print('💰 Updating sponsor contribution: $sponsorId');
      print('💵 Amount: \$$amount');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            'total_contribution': FieldValue.increment(amount),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsor contribution updated successfully');
    } catch (e) {
      print('❌ Failed to update sponsor contribution: $e');
      throw Exception('Failed to update sponsor contribution: $e');
    }
  }

  /// Add sponsored event to sponsor
  Future<void> addSponsoredEvent(String sponsorId, String eventId) async {
    try {
      print('🎯 Adding sponsored event to sponsor: $sponsorId');
      print('📅 Event ID: $eventId');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            'sponsored_events': FieldValue.arrayUnion([eventId]),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsored event added successfully');
    } catch (e) {
      print('❌ Failed to add sponsored event: $e');
      throw Exception('Failed to add sponsored event: $e');
    }
  }

  /// Remove sponsored event from sponsor
  Future<void> removeSponsoredEvent(String sponsorId, String eventId) async {
    try {
      print('🗑️ Removing sponsored event from sponsor: $sponsorId');
      print('📅 Event ID: $eventId');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            'sponsored_events': FieldValue.arrayRemove([eventId]),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsored event removed successfully');
    } catch (e) {
      print('❌ Failed to remove sponsored event: $e');
      throw Exception('Failed to remove sponsored event: $e');
    }
  }

  /// Upgrade sponsor tier
  Future<void> upgradeSponsorTier(String sponsorId, String newTier) async {
    try {
      print('⬆️ Upgrading sponsor tier: $sponsorId');
      print('🎯 New tier: $newTier');
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update({
            'sponsor_tier': newTier,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Sponsor tier upgraded successfully');
    } catch (e) {
      print('❌ Failed to upgrade sponsor tier: $e');
      throw Exception('Failed to upgrade sponsor tier: $e');
    }
  }

  /// Activate/deactivate sponsor
  Future<void> manageSponsorStatus({
    required String sponsorId,
    required bool activate,
    String? reason,
    required String adminId,
  }) async {
    try {
      print('🛠️ Managing sponsor status: $sponsorId');
      print('📊 Action: ${activate ? 'Activate' : 'Deactivate'}');
      
      final updateData = {
        'is_active_sponsor': activate,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (!activate && reason != null) {
        updateData['deactivation_reason'] = reason;
        updateData['deactivated_at'] = DateTime.now().toIso8601String();
        updateData['deactivated_by'] = adminId;
      } else if (activate) {
        updateData['sponsor_since'] = DateTime.now().toIso8601String();
      }

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .update(updateData);
      
      print('✅ Sponsor status updated successfully');
    } catch (e) {
      print('❌ Failed to manage sponsor status: $e');
      throw Exception('Failed to manage sponsor status: $e');
    }
  }

  /// Update user impact score
  Future<void> updateUserImpactScore(String userId, int points) async {
    try {
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'impact_score': FieldValue.increment(points),
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update impact score: $e');
    }
  }

  /// Stream user data for real-time updates
  Stream<UserModel> streamUser(String userId) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return UserModel.fromMap(_getDocumentData(snapshot));
          }
          throw Exception('User not found');
        });
  }

  // ==================== SPONSOR MANAGEMENT OPERATIONS ====================

  /// Get all sponsors
  Stream<QuerySnapshot> getSponsors() {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .where('role', isEqualTo: 'sponsor')
        .where('is_active_sponsor', isEqualTo: true)
        .orderBy('total_contribution', descending: true)
        .snapshots();
  }

  /// Get all sponsors as UserModel list
  Future<List<UserModel>> getAllSponsors() async {
    try {
      print('📋 Fetching all sponsors from Firestore');
      
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .orderBy('total_contribution', descending: true)
          .get();

      final sponsors = sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();

      print('✅ Retrieved ${sponsors.length} sponsors');
      return sponsors;
    } catch (e) {
      print('❌ Failed to get all sponsors: $e');
      throw Exception('Failed to get all sponsors: $e');
    }
  }

  /// Get sponsors by tier
  Future<List<UserModel>> getSponsorsByTier(String tier) async {
    try {
      print('🏷️ Fetching sponsors by tier: $tier');
      
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .where('sponsor_tier', isEqualTo: tier)
          .orderBy('total_contribution', descending: true)
          .get();

      final sponsors = sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();

      print('✅ Retrieved ${sponsors.length} $tier sponsors');
      return sponsors;
    } catch (e) {
      print('❌ Failed to get sponsors by tier: $e');
      throw Exception('Failed to get sponsors by tier: $e');
    }
  }

  /// Get active sponsors
  Future<List<UserModel>> getActiveSponsors() async {
    try {
      print('📊 Fetching active sponsors');
      
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .orderBy('total_contribution', descending: true)
          .get();

      final sponsors = sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();

      print('✅ Retrieved ${sponsors.length} active sponsors');
      return sponsors;
    } catch (e) {
      print('❌ Failed to get active sponsors: $e');
      throw Exception('Failed to get active sponsors: $e');
    }
  }

  /// Get sponsor user by ID
  Future<UserModel> getSponsorUser(String sponsorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(sponsorId)
          .get();
      
      if (doc.exists) {
        final userData = _getDocumentData(doc);
        if (userData['role'] == 'sponsor') {
          return UserModel.fromMap(userData);
        } else {
          throw Exception('User is not a sponsor');
        }
      } else {
        throw Exception('Sponsor not found');
      }
    } catch (e) {
      throw Exception('Failed to get sponsor: $e');
    }
  }

  /// Get top sponsors by contribution
  Future<List<UserModel>> getTopSponsors({int limit = 10}) async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .orderBy('total_contribution', descending: true)
          .limit(limit)
          .get();

      return sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get top sponsors: $e');
    }
  }

  /// Get sponsors with pending approval
  Future<List<UserModel>> getPendingSponsors() async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: false)
          .get();

      return sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pending sponsors: $e');
    }
  }

  /// Get sponsors by organization type
  Future<List<UserModel>> getSponsorsByOrganizationType(String organizationType) async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .where('organization_type', isEqualTo: organizationType)
          .orderBy('total_contribution', descending: true)
          .get();

      return sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sponsors by organization type: $e');
    }
  }

  /// Search sponsors by name or organization
  Future<List<UserModel>> searchSponsors(String query) async {
    try {
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .get();

      final allSponsors = sponsorsSnapshot.docs.map((doc) {
        return UserModel.fromMap(_getQueryDocumentData(doc));
      }).toList();

      return allSponsors.where((sponsor) {
        final name = sponsor.organizationName?.toLowerCase() ?? '';
        final contactPerson = sponsor.contactPerson?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               contactPerson.contains(searchQuery) ||
               sponsor.email.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search sponsors: $e');
    }
  }

  // ==================== GREEN SPACE OPERATIONS ====================

  /// Add a new green space
  Future<void> addGreenSpace(GreenSpaceModel greenSpace) async {
    try {
      await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .doc(greenSpace.spaceId)
          .set(greenSpace.toMap());
    } catch (e) {
      throw Exception('Failed to add green space: $e');
    }
  }

  /// Get all green spaces
  Stream<QuerySnapshot> getGreenSpaces() {
    return _firestore
        .collection(FirestoreConstants.greenSpacesCollection)
        .snapshots();
  }

  /// Get green space by ID
  Future<GreenSpaceModel> getGreenSpace(String spaceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .doc(spaceId)
          .get();
      
      if (doc.exists) {
        return GreenSpaceModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Green space not found');
      }
    } catch (e) {
      throw Exception('Failed to get green space: $e');
    }
  }

  /// Update green space status
  Future<void> updateGreenSpaceStatus(String spaceId, String status) async {
    try {
      await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .doc(spaceId)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update green space status: $e');
    }
  }

  /// Get green spaces by type
  Stream<QuerySnapshot> getGreenSpacesByType(String type) {
    return _firestore
        .collection(FirestoreConstants.greenSpacesCollection)
        .where('type', isEqualTo: type)
        .snapshots();
  }

  /// Get green spaces by status
  Stream<QuerySnapshot> getGreenSpacesByStatus(String status) {
    return _firestore
        .collection(FirestoreConstants.greenSpacesCollection)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  // ==================== PLANT OPERATIONS ====================

  /// Add a new plant
  Future<void> addPlant(PlantModel plant) async {
    try {
      await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plant.plantId)
          .set(plant.toMap());
    } catch (e) {
      throw Exception('Failed to add plant: $e');
    }
  }

  /// Get plants by green space
  Stream<QuerySnapshot> getPlantsBySpace(String spaceId) {
    return _firestore
        .collection(FirestoreConstants.plantsCollection)
        .where('space_id', isEqualTo: spaceId)
        .snapshots();
  }

  /// Get adopted plants by user
  Stream<QuerySnapshot> getAdoptedPlantsByUser(String userId) {
    return _firestore
        .collection(FirestoreConstants.plantsCollection)
        .where('adopted_by', isEqualTo: userId)
        .snapshots();
  }

  /// Get plant by ID
  Future<PlantModel> getPlant(String plantId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .get();
      
      if (doc.exists) {
        return PlantModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Plant not found');
      }
    } catch (e) {
      throw Exception('Failed to get plant: $e');
    }
  }

  /// Update plant health status
  Future<void> updatePlantHealth(String plantId, String healthStatus) async {
    try {
      await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .update({
            'health_status': healthStatus,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update plant health: $e');
    }
  }

  /// Adopt a plant
  Future<void> adoptPlant(String plantId, String userId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .doc(plantId)
          .update({
            'adopted_by': userId,
            'adoption_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      await updateUserImpactScore(userId, 50);
    } catch (e) {
      throw Exception('Failed to adopt plant: $e');
    }
  }

  /// Get plants by health status
  Stream<QuerySnapshot> getPlantsByHealthStatus(String healthStatus) {
    return _firestore
        .collection(FirestoreConstants.plantsCollection)
        .where('health_status', isEqualTo: healthStatus)
        .snapshots();
  }

  // ==================== REPORT OPERATIONS ====================

  /// Submit a new report
  Future<void> submitReport(ReportModel report) async {
    try {
      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(report.reportId)
          .set(report.toMap());
      
      await updateUserImpactScore(report.userId, 10);
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  /// Get reports by user
  Stream<QuerySnapshot> getUserReports(String userId) {
    return _firestore
        .collection(FirestoreConstants.reportsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Get all pending reports for moderation
  Stream<QuerySnapshot> getPendingReports() {
    return _firestore
        .collection(FirestoreConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Get reports by green space
  Stream<QuerySnapshot> getReportsBySpace(String spaceId) {
    return _firestore
        .collection(FirestoreConstants.reportsCollection)
        .where('space_id', isEqualTo: spaceId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  /// Update report status
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      if (status == 'approved') {
        final reportDoc = await _firestore
            .collection(FirestoreConstants.reportsCollection)
            .doc(reportId)
            .get();
        
        if (reportDoc.exists) {
          final reportData = _getDocumentData(reportDoc);
          final userId = reportData['user_id'] as String;
          await updateUserImpactScore(userId, 20);
        }
      }
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  /// Get report by ID
  Future<ReportModel> getReport(String reportId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .get();
      
      if (doc.exists) {
        return ReportModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Report not found');
      }
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  // ==================== EVENT OPERATIONS ====================

  /// Create a new event
  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(event.eventId)
          .set(event.toMap());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Get all events
  Stream<QuerySnapshot> getEvents() {
    return _firestore
        .collection(FirestoreConstants.eventsCollection)
        .orderBy('start_time')
        .snapshots();
  }

  /// Get upcoming events
  Stream<QuerySnapshot> getUpcomingEvents() {
    return _firestore
        .collection(FirestoreConstants.eventsCollection)
        .where('start_time', isGreaterThan: DateTime.now())
        .where('status', isEqualTo: 'upcoming')
        .orderBy('start_time')
        .snapshots();
  }

  /// Get events by NGO
  Stream<QuerySnapshot> getEventsByNGO(String ngoId) {
    return _firestore
        .collection(FirestoreConstants.eventsCollection)
        .where('ngo_id', isEqualTo: ngoId)
        .orderBy('start_time', descending: true)
        .snapshots();
  }

  /// Get event by ID
  Future<EventModel> getEvent(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .get();
      
      if (doc.exists) {
        return EventModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  /// Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .doc(eventId)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update event status: $e');
    }
  }

  // ==================== PARTICIPATION OPERATIONS ====================

  /// Join an event (create participation)
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      final participationId = '${eventId}_$userId';
      
      final participation = ParticipationModel(
        participationId: participationId,
        userId: userId,
        eventId: eventId,
        hoursContributed: 0,
        status: 'registered',
        joinedAt: DateTime.now(),
      );
      
      await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .doc(participationId)
          .set(participation.toMap());
      
      await updateUserImpactScore(userId, 15);
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }

  /// Get user participations
  Stream<QuerySnapshot> getUserParticipations(String userId) {
    return _firestore
        .collection(FirestoreConstants.participationsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('joined_at', descending: true)
        .snapshots();
  }

  /// Get event participations
  Stream<QuerySnapshot> getEventParticipations(String eventId) {
    return _firestore
        .collection(FirestoreConstants.participationsCollection)
        .where('event_id', isEqualTo: eventId)
        .snapshots();
  }

  /// Update participation status
  Future<void> updateParticipationStatus(
    String participationId, 
    String status, {
    int hours = 0,
    String? feedback,
    int? rating,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'attended') {
        updateData['attended_at'] = DateTime.now().toIso8601String();
        updateData['hours_contributed'] = hours;
        if (feedback != null) updateData['feedback'] = feedback;
        if (rating != null) updateData['rating'] = rating;
        
        final participationDoc = await _firestore
            .collection(FirestoreConstants.participationsCollection)
            .doc(participationId)
            .get();
        
        if (participationDoc.exists) {
          final participationData = _getDocumentData(participationDoc);
          final userId = participationData['user_id'] as String;
          await updateUserImpactScore(userId, 30);
          
          if (hours > 0) {
            await updateUserImpactScore(userId, hours * 10);
          }
        }
      } else if (status == 'cancelled') {
        updateData['cancelled_at'] = DateTime.now().toIso8601String();
      }

      await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .doc(participationId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update participation status: $e');
    }
  }

  /// Check if user is already participating in an event
  Future<bool> isUserParticipating(String eventId, String userId) async {
    try {
      final participationId = '${eventId}_$userId';
      final doc = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .doc(participationId)
          .get();
      
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check participation: $e');
    }
  }

  /// Get participation by ID
  Future<ParticipationModel> getParticipation(String participationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .doc(participationId)
          .get();
      
      if (doc.exists) {
        return ParticipationModel.fromMap(_getDocumentData(doc));
      } else {
        throw Exception('Participation not found');
      }
    } catch (e) {
      throw Exception('Failed to get participation: $e');
    }
  }

  // ==================== SPONSOR ANALYTICS ====================

  /// Get sponsor statistics
  Future<Map<String, dynamic>> getSponsorStatistics(String sponsorId) async {
    try {
      print('📊 Getting sponsor statistics: $sponsorId');
      
      final sponsor = await getSponsorUser(sponsorId);
      
      final sponsorshipsSnapshot = await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .where('sponsor_id', isEqualTo: sponsorId)
          .get();

      final totalSponsorships = sponsorshipsSnapshot.docs.length;
      final approvedSponsorships = sponsorshipsSnapshot.docs
          .where((doc) => _getQueryDocumentData(doc)['status'] == 'approved')
          .length;
      final totalContributed = sponsorshipsSnapshot.docs.fold<double>(0.0, (sum, doc) {
        final data = _getQueryDocumentData(doc);
        if (data['status'] == 'approved') {
          return sum + (data['amount'] as double? ?? 0.0);
        }
        return sum;
      });

      final sponsoredEvents = sponsor.sponsoredEvents.length;

      return {
        'sponsor_id': sponsorId,
        'organization_name': sponsor.organizationName,
        'sponsor_tier': sponsor.sponsorTier,
        'total_contribution': sponsor.totalContribution,
        'total_sponsorships': totalSponsorships,
        'approved_sponsorships': approvedSponsorships,
        'pending_sponsorships': totalSponsorships - approvedSponsorships,
        'total_contributed': totalContributed,
        'sponsored_events': sponsoredEvents,
        'approval_rate': totalSponsorships > 0 ? (approvedSponsorships / totalSponsorships * 100) : 0,
        'average_sponsorship_amount': approvedSponsorships > 0 ? totalContributed / approvedSponsorships : 0,
        'sponsor_since': sponsor.sponsorSince?.toIso8601String(),
        'is_active': sponsor.isActiveSponsor,
      };

    } catch (e) {
      print('❌ Failed to get sponsor statistics: $e');
      throw Exception('Failed to get sponsor statistics: $e');
    }
  }

  /// Get overall sponsorship analytics
  Future<Map<String, dynamic>> getSponsorshipAnalytics() async {
    try {
      print('📈 Getting overall sponsorship analytics');
      
      final sponsors = await getAllSponsors();
      
      final sponsorshipsSnapshot = await _firestore
          .collection(FirestoreConstants.sponsorshipsCollection)
          .get();

      final totalSponsors = sponsors.length;
      final totalSponsorships = sponsorshipsSnapshot.docs.length;
      final approvedSponsorships = sponsorshipsSnapshot.docs
          .where((doc) => _getQueryDocumentData(doc)['status'] == 'approved')
          .length;
      
      final totalContributions = sponsors.fold<double>(0.0, (sum, sponsor) => sum + sponsor.totalContribution);
      final averageContribution = totalSponsors > 0 ? totalContributions / totalSponsors : 0;

      final tierDistribution = {
        'platinum': sponsors.where((s) => s.sponsorTier == 'platinum').length,
        'gold': sponsors.where((s) => s.sponsorTier == 'gold').length,
        'silver': sponsors.where((s) => s.sponsorTier == 'silver').length,
        'bronze': sponsors.where((s) => s.sponsorTier == 'bronze').length,
      };

      return {
        'total_sponsors': totalSponsors,
        'total_sponsorships': totalSponsorships,
        'approved_sponsorships': approvedSponsorships,
        'pending_sponsorships': totalSponsorships - approvedSponsorships,
        'total_contributions': totalContributions,
        'average_contribution': averageContribution,
        'approval_rate': totalSponsorships > 0 ? (approvedSponsorships / totalSponsorships * 100) : 0,
        'tier_distribution': tierDistribution,
        'top_sponsor': sponsors.isNotEmpty ? sponsors.first.organizationName : 'None',
        'top_contribution': sponsors.isNotEmpty ? sponsors.first.totalContribution : 0,
      };

    } catch (e) {
      print('❌ Failed to get sponsorship analytics: $e');
      throw Exception('Failed to get sponsorship analytics: $e');
    }
  }

  // ==================== IMPACT STATISTICS & ANALYTICS ====================

  /// Get comprehensive user impact statistics
  Future<Map<String, dynamic>> getUserImpactStatistics(String userId) async {
    try {
      final reports = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('user_id', isEqualTo: userId)
          .get();
      
      final participations = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final adoptedPlants = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('adopted_by', isEqualTo: userId)
          .get();

      final approvedReports = reports.docs
          .where((doc) {
            final data = _getQueryDocumentData(doc);
            return data['status'] == 'approved';
          })
          .length;

      final pendingReports = reports.docs
          .where((doc) {
            final data = _getQueryDocumentData(doc);
            return data['status'] == 'pending';
          })
          .length;

      final attendedEvents = participations.docs
          .where((doc) {
            final data = _getQueryDocumentData(doc);
            return data['status'] == 'attended';
          })
          .length;

      final totalHours = participations.docs.fold<int>(0, (sum, doc) {
        final data = _getQueryDocumentData(doc);
        final hours = data['hours_contributed'] as int? ?? 0;
        return sum + hours;
      });

      final totalEventsJoined = participations.docs.length;

      final impactScore = (approvedReports * 20) + 
                         (attendedEvents * 30) + 
                         (totalHours * 10) + 
                         (adoptedPlants.docs.length * 50);

      return {
        'total_reports': reports.docs.length,
        'approved_reports': approvedReports,
        'pending_reports': pendingReports,
        'total_events_joined': totalEventsJoined,
        'attended_events': attendedEvents,
        'total_volunteer_hours': totalHours,
        'adopted_plants_count': adoptedPlants.docs.length,
        'report_approval_rate': reports.docs.length > 0 ? 
            (approvedReports / reports.docs.length * 100) : 0,
        'event_attendance_rate': totalEventsJoined > 0 ? 
            (attendedEvents / totalEventsJoined * 100) : 0,
        'calculated_impact_score': impactScore,
      };
    } catch (e) {
      print('❌ Error getting user impact statistics: $e');
      throw Exception('Failed to get user impact statistics: $e');
    }
  }

  /// Update user impact score based on all activities
  Future<void> updateUserImpactFromActivities(String userId) async {
    try {
      final stats = await getUserImpactStatistics(userId);
      final impactScore = stats['calculated_impact_score'] as int;
      
      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'impact_score': impactScore,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      print('✅ Updated user impact score: $impactScore for user: $userId');
    } catch (e) {
      print('❌ Error updating user impact from activities: $e');
      throw Exception('Failed to update user impact: $e');
    }
  }

  /// Get user statistics (legacy method - maintained for compatibility)
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    return await getUserImpactStatistics(userId);
  }

  /// Get system-wide statistics
  Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      final users = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .get();
      
      final greenSpaces = await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .get();
      
      final reports = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .get();
      
      final events = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .get();

      final sponsors = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .where('is_active_sponsor', isEqualTo: true)
          .get();

      final plants = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .get();

      final participations = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .get();

      final totalContributions = sponsors.docs.fold<double>(0.0, (sum, doc) {
        final data = _getQueryDocumentData(doc);
        final contribution = data['total_contribution'] as double? ?? 0.0;
        return sum + contribution;
      });

      final totalVolunteerHours = participations.docs.fold<int>(0, (sum, doc) {
        final data = _getQueryDocumentData(doc);
        final hours = data['hours_contributed'] as int? ?? 0;
        return sum + hours;
      });

      final adoptedPlants = plants.docs
          .where((doc) => _getQueryDocumentData(doc)['adopted_by'] != null)
          .length;

      return {
        'total_users': users.docs.length,
        'total_green_spaces': greenSpaces.docs.length,
        'total_reports': reports.docs.length,
        'total_events': events.docs.length,
        'total_sponsors': sponsors.docs.length,
        'total_plants': plants.docs.length,
        'total_adopted_plants': adoptedPlants,
        'total_volunteer_hours': totalVolunteerHours,
        'total_contributions': totalContributions,
      };
    } catch (e) {
      throw Exception('Failed to get system statistics: $e');
    }
  }

  /// Get leaderboard data for top users
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final users = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .orderBy('impact_score', descending: true)
          .limit(limit)
          .get();

      return users.docs.map((doc) {
        final data = _getQueryDocumentData(doc);
        return {
          'userId': doc.id,
          'name': data['name'] ?? 'Anonymous',
          'impact_score': data['impact_score'] ?? 0,
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  // ==================== SEARCH OPERATIONS ====================

  /// Search green spaces by name
  Stream<QuerySnapshot> searchGreenSpaces(String query) {
    return _firestore
        .collection(FirestoreConstants.greenSpacesCollection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots();
  }

  /// Search events by title
  Stream<QuerySnapshot> searchEvents(String query) {
    return _firestore
        .collection(FirestoreConstants.eventsCollection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Delete user and all associated data
  Future<void> deleteUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      final reports = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('user_id', isEqualTo: userId)
          .get();
      
      for (final doc in reports.docs) {
        batch.delete(doc.reference);
      }

      final participations = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .where('user_id', isEqualTo: userId)
          .get();
      
      for (final doc in participations.docs) {
        batch.delete(doc.reference);
      }

      final adoptedPlants = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('adopted_by', isEqualTo: userId)
          .get();
      
      for (final doc in adoptedPlants.docs) {
        batch.update(doc.reference, {
          'adopted_by': null,
          'adoption_date': null,
        });
      }

      final userRef = _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId);
      batch.delete(userRef);

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if document exists
  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check document existence: $e');
    }
  }

  /// Get document count in collection
  Future<int> getCollectionCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get collection count: $e');
    }
  }

  /// Run a transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction transaction) transactionHandler) async {
    return await _firestore.runTransaction(transactionHandler);
  }

  /// Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Generate a unique ID for new documents
  String generateId(String collection) {
    return _firestore.collection(collection).doc().id;
  }

  /// Get documents with pagination
  Future<QuerySnapshot> getDocumentsWithPagination(
    String collection, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    String orderBy = 'created_at',
    bool descending = true,
  }) async {
    Query query = _firestore
        .collection(collection)
        .orderBy(orderBy, descending: descending)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  /// Get documents with filters
  Stream<QuerySnapshot> getDocumentsWithFilters(
    String collection, {
    List<Map<String, dynamic>>? filters,
    String? orderBy,
    bool descending = true,
  }) {
    Query query = _firestore.collection(collection);

    if (filters != null) {
      for (final filter in filters) {
        query = query.where(
          filter['field'] as String,
          isEqualTo: filter['value'],
        );
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    return query.snapshots();
  }

  // ==================== DEBUGGING & TESTING ====================

  /// Print all users for debugging
  Future<void> printAllUsers() async {
    try {
      final users = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .get();
      
      print('=== ALL USERS IN FIRESTORE ===');
      for (final doc in users.docs) {
        print('User: ${doc.id} - ${doc.data()}');
      }
      print('=== END USERS ===');
    } catch (e) {
      print('Error printing users: $e');
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExistsInFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  /// Print user impact statistics for debugging
  Future<void> printUserImpactStats(String userId) async {
    try {
      final stats = await getUserImpactStatistics(userId);
      print('=== IMPACT STATS FOR USER: $userId ===');
      print('Total Reports: ${stats['total_reports']}');
      print('Approved Reports: ${stats['approved_reports']}');
      print('Attended Events: ${stats['attended_events']}');
      print('Volunteer Hours: ${stats['total_volunteer_hours']}');
      print('Adopted Plants: ${stats['adopted_plants_count']}');
      print('Report Approval Rate: ${stats['report_approval_rate']}%');
      print('Event Attendance Rate: ${stats['event_attendance_rate']}%');
      print('Calculated Impact Score: ${stats['calculated_impact_score']}');
      print('=== END STATS ===');
    } catch (e) {
      print('Error printing user impact stats: $e');
    }
  }

  /// Print all sponsors for debugging
  Future<void> printAllSponsors() async {
    try {
      final sponsors = await getAllSponsors();
      
      print('=== ALL SPONSORS IN FIRESTORE ===');
      for (final sponsor in sponsors) {
        print('Sponsor: ${sponsor.organizationName} - Tier: ${sponsor.sponsorTier} - Contribution: \$${sponsor.totalContribution}');
      }
      print('=== END SPONSORS ===');
    } catch (e) {
      print('Error printing sponsors: $e');
    }
  }

  /// Print sponsor statistics for debugging
  Future<void> printSponsorStats(String sponsorId) async {
    try {
      final stats = await getSponsorStatistics(sponsorId);
      print('=== SPONSOR STATS FOR: $sponsorId ===');
      print('Organization: ${stats['organization_name']}');
      print('Tier: ${stats['sponsor_tier']}');
      print('Total Contribution: \$${stats['total_contribution']}');
      print('Total Sponsorships: ${stats['total_sponsorships']}');
      print('Approved Sponsorships: ${stats['approved_sponsorships']}');
      print('Sponsored Events: ${stats['sponsored_events']}');
      print('Approval Rate: ${stats['approval_rate']}%');
      print('Average Sponsorship: \$${stats['average_sponsorship_amount']}');
      print('=== END STATS ===');
    } catch (e) {
      print('Error printing sponsor stats: $e');
    }
  }
}