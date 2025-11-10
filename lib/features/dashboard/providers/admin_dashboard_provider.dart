import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/services/pdf_export_service.dart';

class AdminDashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Statistics
  int _totalUsers = 0;
  int _totalReports = 0;
  int _totalEvents = 0;
  int _activeNGOs = 0;
  int _totalSponsors = 0;
  int _greenSpacesCount = 0;
  int _pendingVerifications = 0;
  int _reportedUsers = 0;
  int _newRegistrations = 0;
  int _pendingReports = 0;
  int _flaggedContent = 0;
  int _spamCount = 0;
  int _totalPlants = 0;
  int _adoptedPlants = 0;
  
  // System health
  String _serverStatus = 'optimal';
  double _databasePerformance = 99.9;
  int _apiResponseTime = 45;
  double _storageUsage = 68.0;
  double _cpuUsage = 45.0;
  double _memoryUsage = 60.0;
  
  // Activity log
  List<Map<String, dynamic>> _recentActivity = [];
  
  // Moderation queues
  List<UserModel> _pendingVerificationUsers = [];
  List<ReportModel> _pendingModerationReports = [];
  List<UserModel> _reportedUsersList = [];
  List<ReportModel> _flaggedReports = [];
  List<ReportModel> _spamReports = [];
  
  // Full users list for management
  List<UserModel> _allUsers = [];
  
  // Analytics data
  Map<String, dynamic> _userAnalytics = {};
  Map<String, dynamic> _platformAnalytics = {};
  Map<String, dynamic> _systemMetrics = {};
  
  // Security settings
  Map<String, dynamic> _securitySettings = {
    'require_2fa': false,
    'session_timeout': 30,
    'max_login_attempts': 5,
    'content_moderation': true,
    'data_encryption': true,
  };

  bool _isLoading = false;
  String? _error;

  // Getters
  int get totalUsers => _totalUsers;
  int get totalReports => _totalReports;
  int get totalEvents => _totalEvents;
  int get activeNGOs => _activeNGOs;
  int get totalSponsors => _totalSponsors;
  int get greenSpacesCount => _greenSpacesCount;
  int get pendingVerifications => _pendingVerifications;
  int get reportedUsers => _reportedUsers;
  int get newRegistrations => _newRegistrations;
  int get pendingReports => _pendingReports;
  int get flaggedContent => _flaggedContent;
  int get spamCount => _spamCount;
  int get totalPlants => _totalPlants;
  int get adoptedPlants => _adoptedPlants;
  String get serverStatus => _serverStatus;
  double get databasePerformance => _databasePerformance;
  int get apiResponseTime => _apiResponseTime;
  double get storageUsage => _storageUsage;
  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  List<UserModel> get pendingVerificationUsers => _pendingVerificationUsers;
  List<ReportModel> get pendingModerationReports => _pendingModerationReports;
  List<UserModel> get reportedUsersList => _reportedUsersList;
  List<ReportModel> get flaggedReports => _flaggedReports;
  List<ReportModel> get spamReports => _spamReports;
  Map<String, dynamic> get userAnalytics => _userAnalytics;
  Map<String, dynamic> get platformAnalytics => _platformAnalytics;
  Map<String, dynamic> get systemMetrics => _systemMetrics;
  List<UserModel> get allUsers => _allUsers;
  Map<String, dynamic> get securitySettings => _securitySettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all dashboard data for admin
  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load all data in parallel
      await Future.wait([
        _loadUserStatistics(),
        _loadContentStatistics(),
        _loadSystemStatistics(),
        _loadRecentActivity(),
        _loadModerationQueues(),
        _loadPlantStatistics(),
        _loadAllUsers(),
        _loadUserAnalytics(),
        _loadPlatformAnalytics(),
        _loadSystemMetrics(),
      ]);

    } catch (e) {
      _error = 'Failed to load admin dashboard data: $e';
      print('Admin Dashboard Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user-related statistics
  Future<void> _loadUserStatistics() async {
    try {
      // Total users count
      final usersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .count()
          .get();
      _totalUsers = usersSnapshot.count ?? 0;

      // Pending verifications (NGOs waiting for approval)
      final pendingNgosSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'ngo')
          .where('verification_status', isEqualTo: 'pending')
          .count()
          .get();
      _pendingVerifications = pendingNgosSnapshot.count ?? 0;

      // Reported users
      final reportedUsersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('is_reported', isEqualTo: true)
          .where('is_suspended', isEqualTo: false)
          .count()
          .get();
      _reportedUsers = reportedUsersSnapshot.count ?? 0;

      // New registrations in last 24 hours
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final newUsersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('created_at', isGreaterThanOrEqualTo: yesterday)
          .count()
          .get();
      _newRegistrations = newUsersSnapshot.count ?? 0;

      // Active NGOs
      final activeNgosSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'ngo')
          .where('verification_status', isEqualTo: 'approved')
          .where('is_active', isEqualTo: true)
          .count()
          .get();
      _activeNGOs = activeNgosSnapshot.count ?? 0;

    } catch (e) {
      throw Exception('Failed to load user statistics: $e');
    }
  }

  /// Load content-related statistics
  Future<void> _loadContentStatistics() async {
    try {
      // Total reports count
      final reportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .count()
          .get();
      _totalReports = reportsSnapshot.count ?? 0;

      // Pending reports for moderation
      final pendingReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      _pendingReports = pendingReportsSnapshot.count ?? 0;

      // Total events count
      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .count()
          .get();
      _totalEvents = eventsSnapshot.count ?? 0;

      // Green spaces count
      final spacesSnapshot = await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .count()
          .get();
      _greenSpacesCount = spacesSnapshot.count ?? 0;

    } catch (e) {
      throw Exception('Failed to load content statistics: $e');
    }
  }

  /// Load plant statistics
  Future<void> _loadPlantStatistics() async {
    try {
      // Total plants count
      final plantsSnapshot = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .count()
          .get();
      _totalPlants = plantsSnapshot.count ?? 0;

      // Adopted plants count
      final adoptedPlantsSnapshot = await _firestore
          .collection(FirestoreConstants.plantsCollection)
          .where('adopted_by', isNotEqualTo: null)
          .count()
          .get();
      _adoptedPlants = adoptedPlantsSnapshot.count ?? 0;

    } catch (e) {
      throw Exception('Failed to load plant statistics: $e');
    }
  }

  /// Load system and moderation statistics
  Future<void> _loadSystemStatistics() async {
    try {
      // Total sponsors count
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.sponsorsCollection)
          .where('is_active', isEqualTo: true)
          .count()
          .get();
      _totalSponsors = sponsorsSnapshot.count ?? 0;

      // Flagged content (reports with multiple flags)
      final flaggedReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('flag_count', isGreaterThan: 2)
          .count()
          .get();
      _flaggedContent = flaggedReportsSnapshot.count ?? 0;

      // Spam detection
      final spamReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('is_spam', isEqualTo: true)
          .count()
          .get();
      _spamCount = spamReportsSnapshot.count ?? 0;

      // Check server status
      _serverStatus = await _checkServerHealth();

    } catch (e) {
      throw Exception('Failed to load system statistics: $e');
    }
  }

  /// Load recent system activity
  Future<void> _loadRecentActivity() async {
    try {
      // Get recent user registrations
      final recentUsers = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .orderBy('created_at', descending: true)
          .limit(15)
          .get();

      // Get recent reports
      final recentReports = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .orderBy('created_at', descending: true)
          .limit(15)
          .get();

      // Get recent events
      final recentEvents = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .orderBy('created_at', descending: true)
          .limit(15)
          .get();

      // Combine and format activity
      _recentActivity = [];

      // Add user registrations
      for (final doc in recentUsers.docs) {
        final userData = doc.data();
        final user = UserModel.fromMap(userData);
        _recentActivity.add({
          'type': 'user_registration',
          'description': 'New user registered: ${user.name}',
          'timestamp': user.createdAt,
          'formatted_time': _formatTimestamp(user.createdAt),
          'user_id': user.userId,
          'data': user.toMap(),
        });
      }

      // Add report submissions
      for (final doc in recentReports.docs) {
        final reportData = doc.data();
        final report = ReportModel.fromMap(reportData);
        _recentActivity.add({
          'type': 'report_submission',
          'description': 'New report submitted: ${report.title}',
          'timestamp': report.createdAt,
          'formatted_time': _formatTimestamp(report.createdAt),
          'report_id': report.reportId,
          'data': report.toMap(),
        });
      }

      // Add event creations
      for (final doc in recentEvents.docs) {
        final eventData = doc.data();
        final event = EventModel.fromMap(eventData);
        _recentActivity.add({
          'type': 'event_creation',
          'description': 'New event created: ${event.title}',
          'timestamp': event.startTime,
          'formatted_time': _formatTimestamp(event.startTime),
          'event_id': event.eventId,
          'data': event.toMap(),
        });
      }

      // Add system activities
      _recentActivity.add({
        'type': 'system_alert',
        'description': 'System maintenance completed',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'formatted_time': _formatTimestamp(DateTime.now().subtract(const Duration(hours: 2))),
      });

      // Sort by timestamp (newest first)
      _recentActivity.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // Limit to 15 most recent activities
      if (_recentActivity.length > 15) {
        _recentActivity = _recentActivity.sublist(0, 15);
      }

    } catch (e) {
      throw Exception('Failed to load recent activity: $e');
    }
  }

  /// Load moderation queue data
  Future<void> _loadModerationQueues() async {
    try {
      // Load pending verification users (NGOs)
      final pendingUsersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'ngo')
          .where('verification_status', isEqualTo: 'pending')
          .orderBy('created_at', descending: true)
          .get();

      _pendingVerificationUsers = pendingUsersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      // Load pending moderation reports
      final pendingReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('created_at', descending: true)
          .get();

      _pendingModerationReports = pendingReportsSnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();

      // Load reported users
      final reportedUsersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('is_reported', isEqualTo: true)
          .where('is_suspended', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();

      _reportedUsersList = reportedUsersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      // Load flagged reports
      final flaggedReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('flag_count', isGreaterThan: 2)
          .orderBy('flag_count', descending: true)
          .get();

      _flaggedReports = flaggedReportsSnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();

      // Load spam reports
      final spamReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('is_spam', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      _spamReports = spamReportsSnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();

    } catch (e) {
      throw Exception('Failed to load moderation queues: $e');
    }
  }

  /// Load all users for management
  Future<void> _loadAllUsers() async {
    try {
      final snapshot = await _firestore.collection(FirestoreConstants.usersCollection).get();
      _allUsers = snapshot.docs.map((d) {
        final data = d.data();
        // Ensure user_id exists for parsing
        final map = Map<String, dynamic>.from(data);
        map['user_id'] = map['user_id'] ?? d.id;
        return UserModel.fromMap(map);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load all users: $e');
    }
  }

  /// Update a user document and refresh local cache
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection(FirestoreConstants.usersCollection).doc(userId).update(updates);

      // Refresh local user entry
      final doc = await _firestore.collection(FirestoreConstants.usersCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['user_id'] = data['user_id'] ?? doc.id;
        final updatedUser = UserModel.fromMap(data);
        final idx = _allUsers.indexWhere((u) => u.userId == userId);
        if (idx != -1) {
          _allUsers[idx] = updatedUser;
        } else {
          _allUsers.insert(0, updatedUser);
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a user and update local caches
  Future<void> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection(FirestoreConstants.usersCollection).doc(userId).delete();

      _allUsers.removeWhere((u) => u.userId == userId);
      _pendingVerificationUsers.removeWhere((u) => u.userId == userId);
      _reportedUsersList.removeWhere((u) => u.userId == userId);

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'user_deleted',
        'description': 'User deleted: $userId',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'user_id': userId,
      });

      if (_recentActivity.length > 15) _recentActivity.removeLast();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user analytics
  Future<void> _loadUserAnalytics() async {
    try {
      final usersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .get();

      final roleCounts = <String, int>{};
      final statusCounts = <String, int>{};
      final dailyRegistrations = <String, int>{};
      final _ = DateTime.now();

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        final role = userData['role'] ?? 'user';
        final status = userData['verification_status'] ?? 'pending';
        final createdAt = (userData['created_at'] as Timestamp).toDate();
        final dateKey = '${createdAt.day}/${createdAt.month}/${createdAt.year}';

        roleCounts[role] = (roleCounts[role] ?? 0) + 1;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        dailyRegistrations[dateKey] = (dailyRegistrations[dateKey] ?? 0) + 1;
      }

      _userAnalytics = {
        'role_distribution': roleCounts,
        'status_distribution': statusCounts,
        'daily_registrations': dailyRegistrations,
        'total_users': _totalUsers,
        'active_users': _activeNGOs + roleCounts['user']!,
      };

    } catch (e) {
      throw Exception('Failed to load user analytics: $e');
    }
  }

  /// Load platform analytics
  Future<void> _loadPlatformAnalytics() async {
    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      // Recent reports
      final recentReports = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('created_at', isGreaterThanOrEqualTo: lastWeek)
          .get();

      // Recent events
      final recentEvents = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('created_at', isGreaterThanOrEqualTo: lastWeek)
          .get();

      // Recent users
      final recentUsers = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('created_at', isGreaterThanOrEqualTo: lastWeek)
          .get();

      _platformAnalytics = {
        'weekly_reports': recentReports.docs.length,
        'weekly_events': recentEvents.docs.length,
        'weekly_users': recentUsers.docs.length,
        'report_approval_rate': _calculateApprovalRate(recentReports.docs),
        'event_completion_rate': _calculateCompletionRate(recentEvents.docs),
        'user_growth_rate': _calculateGrowthRate(_totalUsers, recentUsers.docs.length),
      };

    } catch (e) {
      throw Exception('Failed to load platform analytics: $e');
    }
  }

  /// Load system metrics
  Future<void> _loadSystemMetrics() async {
    try {
      // Simulate system metrics (in real app, these would come from monitoring)
      _systemMetrics = {
        'uptime': '99.95%',
        'error_rate': '0.05%',
        'active_sessions': 245,
        'database_size': '2.4 GB',
        'cache_hit_rate': '94%',
        'queue_length': 12,
      };

    } catch (e) {
      throw Exception('Failed to load system metrics: $e');
    }
  }

  /// Verify a user (typically NGO)
  Future<void> verifyUser(String userId, String userType) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'verification_status': 'approved',
            'verified_at': FieldValue.serverTimestamp(),
            'verified_by': 'admin',
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      _pendingVerifications = _pendingVerifications > 0 ? _pendingVerifications - 1 : 0;
      _pendingVerificationUsers.removeWhere((user) => user.userId == userId);
      
      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'moderation_action',
        'description': 'User $userId verified as $userType',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'user_id': userId,
      });

      // Keep activity list manageable
      if (_recentActivity.length > 15) {
        _recentActivity = _recentActivity.sublist(0, 15);
      }

      notifyListeners();

    } catch (e) {
      _error = 'Failed to verify user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject user verification
  Future<void> rejectUserVerification(String userId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'verification_status': 'rejected',
            'rejection_reason': reason,
            'rejected_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      _pendingVerifications = _pendingVerifications > 0 ? _pendingVerifications - 1 : 0;
      _pendingVerificationUsers.removeWhere((user) => user.userId == userId);

      notifyListeners();

    } catch (e) {
      _error = 'Failed to reject user verification: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Suspend a user
  Future<void> suspendUser(String userId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'is_suspended': true,
            'suspended_at': FieldValue.serverTimestamp(),
            'suspension_reason': reason,
            'suspended_by': 'admin',
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      _reportedUsers = _reportedUsers > 0 ? _reportedUsers - 1 : 0;
      _reportedUsersList.removeWhere((user) => user.userId == userId);
      
      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'moderation_action',
        'description': 'User $userId suspended: $reason',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'user_id': userId,
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to suspend user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Unsuspend a user
  Future<void> unsuspendUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .update({
            'is_suspended': false,
            'unsuspended_at': FieldValue.serverTimestamp(),
            'unsuspended_by': 'admin',
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'moderation_action',
        'description': 'User $userId unsuspended',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'user_id': userId,
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to unsuspend user: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve a report
  Future<void> approveReport(String reportId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .update({
            'status': 'approved',
            'updated_at': FieldValue.serverTimestamp(),
            'approved_by': 'admin',
            'approved_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      _pendingReports = _pendingReports > 0 ? _pendingReports - 1 : 0;
      _pendingModerationReports.removeWhere((report) => report.reportId == reportId);

      notifyListeners();

    } catch (e) {
      _error = 'Failed to approve report: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reject a report
  Future<void> rejectReport(String reportId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .update({
            'status': 'rejected',
            'rejection_reason': reason,
            'updated_at': FieldValue.serverTimestamp(),
            'rejected_by': 'admin',
            'rejected_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      _pendingReports = _pendingReports > 0 ? _pendingReports - 1 : 0;
      _pendingModerationReports.removeWhere((report) => report.reportId == reportId);

      notifyListeners();

    } catch (e) {
      _error = 'Failed to reject report: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark report as spam
  Future<void> markReportAsSpam(String reportId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .doc(reportId)
          .update({
            'is_spam': true,
            'updated_at': FieldValue.serverTimestamp(),
            'marked_spam_by': 'admin',
          });

      // Update local state
      _spamCount = _spamCount > 0 ? _spamCount - 1 : 0;
      _spamReports.removeWhere((report) => report.reportId == reportId);

      notifyListeners();

    } catch (e) {
      _error = 'Failed to mark report as spam: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete inappropriate content
  Future<void> deleteContent(String contentId, String contentType, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String collectionName;
      switch (contentType) {
        case 'report':
          collectionName = FirestoreConstants.reportsCollection;
          break;
        case 'event':
          collectionName = FirestoreConstants.eventsCollection;
          break;
        case 'green_space':
          collectionName = FirestoreConstants.greenSpacesCollection;
          break;
        default:
          throw Exception('Unknown content type: $contentType');
      }

      await _firestore
          .collection(collectionName)
          .doc(contentId)
          .update({
            'is_removed': true,
            'removed_at': FieldValue.serverTimestamp(),
            'removal_reason': reason,
            'removed_by': 'admin',
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update relevant statistics
      if (contentType == 'report') {
        _pendingReports = _pendingReports > 0 ? _pendingReports - 1 : 0;
        _flaggedContent = _flaggedContent > 0 ? _flaggedContent - 1 : 0;
      }

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'moderation_action',
        'description': '$contentType $contentId removed: $reason',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'content_id': contentId,
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to delete content: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send system-wide notification
  Future<void> sendBroadcastNotification(String title, String message, {String? targetAudience}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Determine target users
      Query usersQuery = _firestore.collection(FirestoreConstants.usersCollection);
      
      if (targetAudience != null && targetAudience != 'all') {
        usersQuery = usersQuery.where('role', isEqualTo: targetAudience);
      }

      final usersSnapshot = await usersQuery.get();

      // Create notifications for all target users
      final batch = _firestore.batch();
      for (final doc in usersSnapshot.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'user_id': doc.id,
          'title': title,
          'message': message,
          'type': 'broadcast',
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
          'audience': targetAudience ?? 'all',
          'sent_by': 'admin',
        });
      }

      await batch.commit();

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'system_alert',
        'description': 'Broadcast sent: $title',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
        'audience': targetAudience ?? 'all',
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to send broadcast: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Run system maintenance tasks
  Future<void> runSystemMaintenance() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Example maintenance tasks:
      // 1. Clean up old notifications
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldNotifications = await _firestore
          .collection('notifications')
          .where('created_at', isLessThan: thirtyDaysAgo)
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // 2. Update system statistics cache
      await loadDashboardData();

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'system_alert',
        'description': 'System maintenance completed',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to run system maintenance: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Run system diagnostics
  Future<void> runSystemDiagnostics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate diagnostic checks
      await Future.delayed(const Duration(seconds: 2));

      // Update system health metrics (in real app, these would come from actual diagnostics)
      _databasePerformance = 99.9;
      _apiResponseTime = 42;
      _storageUsage = 65.5;
      _cpuUsage = 45.0;
      _memoryUsage = 60.0;
      _serverStatus = 'optimal';

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'system_alert',
        'description': 'System diagnostics completed - All systems optimal',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to run system diagnostics: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update security settings
  Future<void> updateSecuritySettings(Map<String, dynamic> newSettings) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update security settings in Firestore (if you want to persist them)
      await _firestore
          .collection('system_settings')
          .doc('security')
          .set(newSettings, SetOptions(merge: true));

      _securitySettings = newSettings;

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'system_alert',
        'description': 'Security settings updated',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to update security settings: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get detailed platform analytics
  Future<Map<String, dynamic>> getDetailedPlatformAnalytics({String? timeRange}) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (timeRange) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'quarter':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = now.subtract(const Duration(days: 30)); // Default to month
      }

      // User growth
      final newUsersSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      // Report activity
      final newReportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      // Event activity
      final newEventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      return {
        'time_range': timeRange ?? 'month',
        'new_users': newUsersSnapshot.docs.length,
        'new_reports': newReportsSnapshot.docs.length,
        'new_events': newEventsSnapshot.docs.length,
        'user_growth_rate': _calculateGrowthRate(_totalUsers, newUsersSnapshot.docs.length),
        'report_approval_rate': _calculateApprovalRate(newReportsSnapshot.docs),
        'event_completion_rate': _calculateCompletionRate(newEventsSnapshot.docs),
      };

    } catch (e) {
      throw Exception('Failed to get platform analytics: $e');
    }
  }

  /// Export system data
  Future<void> exportSystemData(String dataType) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate data export
      await Future.delayed(const Duration(seconds: 3));

      // Add to activity log
      _recentActivity.insert(0, {
        'type': 'system_alert',
        'description': 'Data export completed: $dataType',
        'timestamp': DateTime.now(),
        'formatted_time': _formatTimestamp(DateTime.now()),
      });

      notifyListeners();

    } catch (e) {
      _error = 'Failed to export data: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Export users list to file (pdf/csv/json) using PdfExportService
  /// Returns the generated file path for pdf/csv/json, or throws on error.
  Future<String> exportUsers({String format = 'pdf'}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final usersSnapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> rows = usersSnapshot.docs.map((doc) {
        final d = doc.data();
        return {
          'user_id': d['user_id'] ?? doc.id,
          'name': d['name'] ?? '',
          'email': d['email'] ?? '',
          'role': d['role'] ?? '',
          'created_at': d['created_at'] ?? '',
          'is_active': d['is_active'] ?? true,
        };
      }).toList();

      final exporter = PdfExportService();
      final fileName = 'users_export_${DateTime.now().toIso8601String()}';

      if (format == 'csv') {
        final path = await exporter.exportToCSV(data: rows, fileName: fileName);
        return path;
      } else if (format == 'json') {
        final path = await exporter.exportToJSON(data: rows, fileName: fileName);
        return path;
      } else {
        // default PDF
        final path = await exporter.exportToPDF(data: rows, fileName: fileName, title: 'Users Export', subtitle: 'Total ${rows.length} users');
        return path;
      }
    } catch (e) {
      _error = 'Failed to export users: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  Future<String> _checkServerHealth() async {
    // Placeholder for actual server health check
    // In real app, this would ping your backend services
    await Future.delayed(const Duration(milliseconds: 100));
    return 'optimal'; // 'optimal', 'degraded', 'critical'
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  double _calculateGrowthRate(int totalUsers, int newUsers) {
    if (totalUsers == 0) return 0.0;
    return (newUsers / totalUsers * 100);
  }

  double _calculateApprovalRate(List<QueryDocumentSnapshot<Object?>> reports) {
    if (reports.isEmpty) return 0.0;
    final approvedReports = reports.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'approved';
    }).length;
    return (approvedReports / reports.length * 100);
  }

  double _calculateCompletionRate(List<QueryDocumentSnapshot<Object?>> events) {
    if (events.isEmpty) return 0.0;
    final completedEvents = events.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'completed';
    }).length;
    return (completedEvents / events.length * 100);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Dispose provider
  void disposeProvider() {
    // Clean up any resources if needed
  }
}