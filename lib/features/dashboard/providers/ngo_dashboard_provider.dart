import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/constants/firestore_constants.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';
import 'package:urban_green_mapper/core/models/sponsorship_model.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

// Analytics View Enum for mobile navigation
enum AnalyticsView {
  overview,
  performance,
  community,
  financial,
  sponsorship,
  events,
  reports
}

class NGODashboardProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<EventModel> _events = [];
  List<ReportModel> _pendingReports = [];
  List<SponsorModel> _sponsors = [];
  List<SponsorshipModel> _sponsorships = [];
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _analyticsData = [];
  List<Map<String, dynamic>> _sponsorAnalytics = [];
  
  bool _isLoading = false;
  String? _error;
  String? _currentNGOId;

  // Analytics state
  DateTime _selectedAnalyticsPeriod = DateTime.now();
  AnalyticsView _currentAnalyticsView = AnalyticsView.overview;

  // Engagement data
  List<GreenSpaceModel> _topNearbyGreenSpaces = [];
  int _unreadNotificationsCount = 0;

  // Getters
  List<EventModel> get events => _events;
  List<ReportModel> get pendingReports => _pendingReports;
  List<SponsorModel> get sponsors => _sponsors;
  List<SponsorshipModel> get sponsorships => _sponsorships;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get analyticsData => _analyticsData;
  List<Map<String, dynamic>> get sponsorAnalytics => _sponsorAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Engagement getters
  List<GreenSpaceModel> get topNearbyGreenSpaces => _topNearbyGreenSpaces;
  int get unreadNotificationsCount => _unreadNotificationsCount;
  DateTime get selectedAnalyticsPeriod => _selectedAnalyticsPeriod;
  AnalyticsView get currentAnalyticsView => _currentAnalyticsView;

  // Statistics getters
  int get activeEvents => _events.where((event) => event.status == 'upcoming' || event.status == 'ongoing').length;
  int get totalParticipants => _calculateTotalParticipants();
  int get completedProjects => _events.where((event) => event.status == 'completed').length;
  double get totalBudget => _calculateTotalBudget();
  double get budgetUtilized => _calculateBudgetUtilized();
  double get budgetRemaining => totalBudget - budgetUtilized;
  int get communityMembers => _calculateCommunityMembers();
  int get volunteerHours => _calculateVolunteerHours();
  int get partnerSponsors => _sponsors.where((sponsor) => sponsor.isActive).length;
  int get pendingReportsCount => _pendingReports.length;

  // Sponsor-specific statistics
  int get totalSponsors => _sponsors.length;
  int get activeSponsors => _sponsors.where((sponsor) => sponsor.isActive).length;
  double get totalSponsorshipAmount => _calculateTotalSponsorshipAmount();
  int get bronzeSponsors => _sponsors.where((sponsor) => sponsor.tier == 'bronze' && sponsor.isActive).length;
  int get silverSponsors => _sponsors.where((sponsor) => sponsor.tier == 'silver' && sponsor.isActive).length;
  int get goldSponsors => _sponsors.where((sponsor) => sponsor.tier == 'gold' && sponsor.isActive).length;
  int get platinumSponsors => _sponsors.where((sponsor) => sponsor.tier == 'platinum' && sponsor.isActive).length;

  // Analytics-specific getters
  Map<String, dynamic> get analyticsSummary => _generateAnalyticsSummary();
  List<Map<String, dynamic>> get mobileAnalyticsCards => _generateMobileAnalyticsCards();

  /// Initialize provider with NGO ID
  void initialize(String ngoId) {
    _currentNGOId = ngoId;
  }

  /// Set analytics period
  void setAnalyticsPeriod(DateTime period) {
    _selectedAnalyticsPeriod = period;
    notifyListeners();
  }

  /// Set analytics view
  void setAnalyticsView(AnalyticsView view) {
    _currentAnalyticsView = view;
    notifyListeners();
  }

  /// Load all dashboard data for the NGO
  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentNGOId == null) {
        throw Exception('NGO ID not initialized');
      }

      // Load all data in parallel
      await Future.wait([
        _loadEvents(),
        _loadPendingReports(),
        _loadSponsors(),
        _loadSponsorships(),
        _loadAchievements(),
        _loadAnalyticsData(),
        _loadSponsorAnalytics(),
      ]);

    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      print('Dashboard loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load events for the current NGO - FIXED with error handling for index issues
  Future<void> _loadEvents() async {
    try {
      // Try the composite index query first
      final eventsSnapshot = await _firestore
          .collection(FirestoreConstants.eventsCollection)
          .where('ngo_id', isEqualTo: _currentNGOId)
          .orderBy('start_time', descending: true)
          .get();

      _events = eventsSnapshot.docs.map((doc) {
        return EventModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      // Fallback: Try without ordering if index doesn't exist yet
      print('Events query failed with index error, trying fallback: $e');
      try {
        final eventsSnapshot = await _firestore
            .collection(FirestoreConstants.eventsCollection)
            .where('ngo_id', isEqualTo: _currentNGOId)
            .get();

        _events = eventsSnapshot.docs.map((doc) {
          return EventModel.fromMap(doc.data());
        }).toList();

        // Manual sorting in memory
        _events.sort((a, b) => b.startTime.compareTo(a.startTime));

      } catch (fallbackError) {
        print('Events fallback also failed: $fallbackError');
        _events = []; // Set empty events instead of throwing
      }
    }
  }

  /// Load pending reports for moderation - FIXED with robust error handling
  Future<void> _loadPendingReports() async {
    try {
      // Try the composite index query first
      final reportsSnapshot = await _firestore
          .collection(FirestoreConstants.reportsCollection)
          .where('status', isEqualTo: 'pending')
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      _pendingReports = reportsSnapshot.docs.map((doc) {
        return ReportModel.fromMap(doc.data());
      }).toList();

    } catch (e) {
      // Fallback 1: Try without ordering
      print('Reports query failed with index error, trying fallback 1: $e');
      try {
        final reportsSnapshot = await _firestore
            .collection(FirestoreConstants.reportsCollection)
            .where('status', isEqualTo: 'pending')
            .limit(10)
            .get();

        _pendingReports = reportsSnapshot.docs.map((doc) {
          return ReportModel.fromMap(doc.data());
        }).toList();

        // Manual sorting by created_at
        _pendingReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      } catch (fallbackError1) {
        // Fallback 2: Try with just status filter
        print('Reports fallback 1 failed, trying fallback 2: $fallbackError1');
        try {
          final reportsSnapshot = await _firestore
              .collection(FirestoreConstants.reportsCollection)
              .where('status', isEqualTo: 'pending')
              .get();

          _pendingReports = reportsSnapshot.docs.map((doc) {
            return ReportModel.fromMap(doc.data());
          }).toList();

          // Manual sorting and limit
          _pendingReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _pendingReports = _pendingReports.take(10).toList();

        } catch (fallbackError2) {
          // Fallback 3: Get all reports and filter manually
          print('Reports fallback 2 failed, trying fallback 3: $fallbackError2');
          try {
            final reportsSnapshot = await _firestore
                .collection(FirestoreConstants.reportsCollection)
                .get();

            _pendingReports = reportsSnapshot.docs.map((doc) {
              return ReportModel.fromMap(doc.data());
            }).toList();

            // Filter by status and sort manually
            _pendingReports = _pendingReports
                .where((report) => report.status == 'pending')
                .toList();
            _pendingReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            _pendingReports = _pendingReports.take(10).toList();

          } catch (fallbackError3) {
            print('All reports query fallbacks failed: $fallbackError3');
            _pendingReports = []; // Set empty reports instead of throwing
          }
        }
      }
    }
  }

  /// Load sponsors associated with the NGO
  Future<void> _loadSponsors() async {
    try {
      // Simple query without complex filters to avoid index issues
      final sponsorsSnapshot = await _firestore
          .collection(FirestoreConstants.usersCollection)
          .where('role', isEqualTo: 'sponsor')
          .get();

      _sponsors = sponsorsSnapshot.docs.map((doc) {
        final userData = doc.data();
        return SponsorModel(
          sponsorId: doc.id,
          name: userData['organization_name'] ?? userData['name'] ?? 'Unknown Sponsor',
          contactEmail: userData['email'] ?? '',
          tier: userData['sponsor_tier'] ?? 'bronze',
          logoUrl: userData['logo_url'],
          website: userData['website'],
          phoneNumber: userData['phone_number'],
          address: userData['business_address'] ?? userData['address'],
          description: userData['description'],
          totalContribution: (userData['total_contribution'] ?? 0).toDouble(),
          sponsoredEventsCount: (userData['sponsored_events'] as List? ?? []).length,
          joinedAt: _parseTimestamp(userData['sponsor_since']),
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
          createdAt: _parseTimestamp(userData['created_at']),
          updatedAt: _parseTimestamp(userData['updated_at']),
          sponsorSince: _parseTimestampToString(userData['sponsor_since']),
        );
      }).toList();

      // Filter active sponsors and sort by contribution
      _sponsors = _sponsors.where((sponsor) => sponsor.isActive).toList();
      _sponsors.sort((a, b) => b.totalContribution.compareTo(a.totalContribution));

    } catch (e) {
      print('Failed to load sponsors: $e');
      _sponsors = []; // Set empty sponsors instead of throwing
    }
  }

  /// Helper method to parse timestamp safely to DateTime
  DateTime _parseTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        return timestamp;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Helper method to parse timestamp safely to String
  String? _parseTimestampToString(dynamic timestamp) {
    try {
      if (timestamp == null) return null;
      if (timestamp is Timestamp) {
        return timestamp.toDate().toIso8601String();
      } else if (timestamp is String) {
        return timestamp;
      } else if (timestamp is DateTime) {
        return timestamp.toIso8601String();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Load sponsorships for the NGO's events
  Future<void> _loadSponsorships() async {
    try {
      // Get event IDs for the current NGO
      final eventIds = _events.map((event) => event.eventId).toList();
      
      if (eventIds.isEmpty) {
        _sponsorships = [];
        return;
      }

      // Use chunks to avoid Firestore 'in' query limitations
      final List<SponsorshipModel> allSponsorships = [];
      const chunkSize = 10;
      
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk = eventIds.sublist(
          i, 
          i + chunkSize > eventIds.length ? eventIds.length : i + chunkSize
        );
        
        try {
          final sponsorshipsSnapshot = await _firestore
              .collection(FirestoreConstants.sponsorshipsCollection)
              .where('event_id', whereIn: chunk)
              .get();

          allSponsorships.addAll(
            sponsorshipsSnapshot.docs.map((doc) {
              return SponsorshipModel.fromMap(doc.data());
            }).toList()
          );
        } catch (e) {
          print('Error loading sponsorships chunk: $e');
          // Continue with next chunk even if one fails
        }
      }

      _sponsorships = allSponsorships.where((sponsorship) => 
        sponsorship.status == 'approved' || sponsorship.status == 'completed'
      ).toList();

    } catch (e) {
      print('Error loading sponsorships: $e');
      _sponsorships = [];
    }
  }

  /// Load achievements for the NGO
  Future<void> _loadAchievements() async {
    try {
      _achievements = _generateAchievements();
    } catch (e) {
      print('Error loading achievements: $e');
      _achievements = [];
    }
  }

  /// Load analytics data
  Future<void> _loadAnalyticsData() async {
    try {
      _analyticsData = await _generateAnalyticsData();
    } catch (e) {
      print('Error loading analytics data: $e');
      _analyticsData = [];
    }
  }

  /// Load sponsor analytics
  Future<void> _loadSponsorAnalytics() async {
    try {
      _sponsorAnalytics = await _generateSponsorAnalytics();
    } catch (e) {
      print('Error loading sponsor analytics: $e');
      _sponsorAnalytics = [];
    }
  }

  /// Generate achievements based on NGO performance
  List<Map<String, dynamic>> _generateAchievements() {
    final List<Map<String, dynamic>> achievements = [];
    
    // Event-based achievements
    if (_events.isNotEmpty) {
      achievements.add({
        'id': 'first_event',
        'title': 'First Event',
        'description': 'Organized your first environmental event',
        'type': 'events',
        'unlocked': true,
        'icon': 'event',
        'progress': 1.0,
        'target': 1,
        'current': _events.length,
      });
    }

    if (_events.length >= 5) {
      achievements.add({
        'id': 'event_organizer',
        'title': 'Event Organizer',
        'description': 'Organized 5+ environmental events',
        'type': 'events',
        'unlocked': true,
        'icon': 'event_available',
        'progress': 1.0,
        'target': 5,
        'current': _events.length,
      });
    }

    // Community achievements
    if (communityMembers >= 50) {
      achievements.add({
        'id': 'community_builder',
        'title': 'Community Builder',
        'description': 'Built a community of 50+ members',
        'type': 'community',
        'unlocked': true,
        'icon': 'groups',
        'progress': 1.0,
        'target': 50,
        'current': communityMembers,
      });
    }

    // Volunteer achievements
    if (volunteerHours >= 100) {
      achievements.add({
        'id': 'dedicated_volunteer',
        'title': 'Dedicated Volunteer',
        'description': 'Contributed 100+ volunteer hours',
        'type': 'volunteer',
        'unlocked': true,
        'icon': 'volunteer_activism',
        'progress': 1.0,
        'target': 100,
        'current': volunteerHours,
      });
    }

    // Environmental impact achievements
    if (completedProjects >= 3) {
      achievements.add({
        'id': 'green_champion',
        'title': 'Green Champion',
        'description': 'Completed 3+ environmental projects',
        'type': 'environment',
        'unlocked': true,
        'icon': 'eco',
        'progress': 1.0,
        'target': 3,
        'current': completedProjects,
      });
    }

    // Sponsorship achievements
    if (partnerSponsors >= 2) {
      achievements.add({
        'id': 'partnership_builder',
        'title': 'Partnership Builder',
        'description': 'Secured partnerships with 2+ sponsors',
        'type': 'leadership',
        'unlocked': true,
        'icon': 'handshake',
        'progress': 1.0,
        'target': 2,
        'current': partnerSponsors,
      });
    }

    // Sponsor-specific achievements
    if (totalSponsorshipAmount >= 1000) {
      achievements.add({
        'id': 'sponsor_magnet',
        'title': 'Sponsor Magnet',
        'description': 'Raised \$1000+ in sponsorships',
        'type': 'sponsor',
        'unlocked': true,
        'icon': 'attach_money',
        'progress': 1.0,
        'target': 1000,
        'current': totalSponsorshipAmount.toInt(),
      });
    }

    if (platinumSponsors >= 1) {
      achievements.add({
        'id': 'premium_partner',
        'title': 'Premium Partner',
        'description': 'Secured a Platinum level sponsor',
        'type': 'sponsor',
        'unlocked': true,
        'icon': 'workspace_premium',
        'progress': 1.0,
        'target': 1,
        'current': platinumSponsors,
      });
    }

    // Add some locked achievements for motivation
    achievements.addAll([
      {
        'id': 'community_leader',
        'title': 'Community Leader',
        'description': 'Reach 100+ community members',
        'type': 'community',
        'unlocked': communityMembers >= 100,
        'icon': 'leaderboard',
        'progress': communityMembers / 100.0,
        'target': 100,
        'current': communityMembers,
      },
      {
        'id': 'environment_hero',
        'title': 'Environment Hero',
        'description': 'Complete 10+ environmental projects',
        'type': 'environment',
        'unlocked': completedProjects >= 10,
        'icon': 'workspace_premium',
        'progress': completedProjects / 10.0,
        'target': 10,
        'current': completedProjects,
      },
      {
        'id': 'volunteer_champion',
        'title': 'Volunteer Champion',
        'description': 'Reach 500+ volunteer hours',
        'type': 'volunteer',
        'unlocked': volunteerHours >= 500,
        'icon': 'military_tech',
        'progress': volunteerHours / 500.0,
        'target': 500,
        'current': volunteerHours,
      },
      {
        'id': 'sponsor_champion',
        'title': 'Sponsor Champion',
        'description': 'Raise \$5000+ in sponsorships',
        'type': 'sponsor',
        'unlocked': totalSponsorshipAmount >= 5000,
        'icon': 'trending_up',
        'progress': totalSponsorshipAmount / 5000.0,
        'target': 5000,
        'current': totalSponsorshipAmount.toInt(),
      },
    ]);

    return achievements;
  }

  /// Generate analytics data with robust error handling
  Future<List<Map<String, dynamic>>> _generateAnalyticsData() async {
    final List<Map<String, dynamic>> analytics = [];
    
    try {
      // Basic stats that don't require additional queries
      analytics.add({
        'type': 'basic_stats',
        'data': {
          'total_events': _events.length,
          'active_events': activeEvents,
          'completed_events': completedProjects,
          'total_sponsors': totalSponsors,
          'total_participants': totalParticipants,
          'volunteer_hours': volunteerHours,
        }
      });

      // Event participation analytics - limited to avoid performance issues
      for (final event in _events.take(2)) {
        try {
          final stats = await getEventParticipationStats(event.eventId);
          analytics.add({
            'type': 'event_participation',
            'event_id': event.eventId,
            'event_title': event.title.length > 25 ? '${event.title.substring(0, 25)}...' : event.title,
            'data': stats,
          });
        } catch (e) {
          // Skip individual event stats if they fail
          print('Error getting participation stats for event ${event.eventId}: $e');
        }
      }

      // Monthly performance analytics
      final monthlyStats = await _getMonthlyPerformanceSafe();
      analytics.add({
        'type': 'monthly_performance',
        'data': monthlyStats,
      });

      // Sponsor contribution analytics
      final sponsorStats = _getSponsorContributionStats();
      analytics.add({
        'type': 'sponsor_contributions',
        'data': sponsorStats,
      });

    } catch (e) {
      print('Error generating analytics: $e');
      // Return minimal analytics data even if some parts fail
      analytics.add({
        'type': 'minimal_stats',
        'data': {
          'total_events': _events.length,
          'active_events': activeEvents,
          'completed_events': completedProjects,
        }
      });
    }

    return analytics;
  }

  /// Generate sponsor analytics with error handling
  Future<List<Map<String, dynamic>>> _generateSponsorAnalytics() async {
    final List<Map<String, dynamic>> analytics = [];
    
    try {
      // Sponsor tier distribution
      final tierDistribution = {
        'bronze': bronzeSponsors,
        'silver': silverSponsors,
        'gold': goldSponsors,
        'platinum': platinumSponsors,
      };

      analytics.add({
        'type': 'sponsor_tier_distribution',
        'data': tierDistribution,
      });

      // Top sponsors by contribution
      final topSponsors = _sponsors
          .where((sponsor) => sponsor.isActive)
          .take(3)
          .map((sponsor) => {
            'name': sponsor.name.length > 20 ? '${sponsor.name.substring(0, 20)}...' : sponsor.name,
            'tier': sponsor.tier,
            'contribution': sponsor.totalContribution,
            'events_sponsored': sponsor.sponsoredEvents.length,
          })
          .toList();

      analytics.add({
        'type': 'top_sponsors',
        'data': topSponsors,
      });

      // Sponsorship success rate
      final successRate = await _getSponsorshipSuccessRate();
      analytics.add({
        'type': 'sponsorship_success_rate',
        'data': successRate,
      });

    } catch (e) {
      print('Error generating sponsor analytics: $e');
      // Return basic sponsor analytics even if some parts fail
      analytics.add({
        'type': 'basic_sponsor_stats',
        'data': {
          'total_sponsors': totalSponsors,
          'active_sponsors': activeSponsors,
        }
      });
    }

    return analytics;
  }

  /// Generate mobile-optimized analytics cards
  List<Map<String, dynamic>> _generateMobileAnalyticsCards() {
    final List<Map<String, dynamic>> cards = [];
    
    // Performance Card
    cards.add({
      'type': 'performance',
      'title': 'Performance',
      'icon': '📊',
      'data': {
        'events_organized': _events.length,
        'completion_rate': _events.isNotEmpty ? (completedProjects / _events.length * 100) : 0,
        'avg_participants': _events.isNotEmpty ? (totalParticipants / _events.length) : 0,
      },
      'color': 0xFF4CAF50, // Green
    });

    // Community Card
    cards.add({
      'type': 'community',
      'title': 'Community',
      'icon': '👥',
      'data': {
        'total_members': communityMembers,
        'volunteer_hours': volunteerHours,
        'engagement_rate': _calculateEngagementRate(),
      },
      'color': 0xFF2196F3, // Blue
    });

    // Financial Card
    cards.add({
      'type': 'financial',
      'title': 'Financial',
      'icon': '💰',
      'data': {
        'total_budget': totalBudget,
        'utilized_budget': budgetUtilized,
        'utilization_rate': totalBudget > 0 ? (budgetUtilized / totalBudget * 100) : 0,
      },
      'color': 0xFFFF9800, // Orange
    });

    // Sponsorship Card
    cards.add({
      'type': 'sponsorship',
      'title': 'Sponsorship',
      'icon': '🤝',
      'data': {
        'total_sponsors': totalSponsors,
        'active_sponsors': activeSponsors,
        'total_contributions': totalSponsorshipAmount,
      },
      'color': 0xFF9C27B0, // Purple
    });

    return cards;
  }

  /// Generate analytics summary for mobile
  Map<String, dynamic> _generateAnalyticsSummary() {
    return {
      'overview': {
        'total_events': _events.length,
        'active_events': activeEvents,
        'completed_events': completedProjects,
        'success_rate': _events.isNotEmpty ? (completedProjects / _events.length * 100) : 0,
      },
      'community': {
        'total_members': communityMembers,
        'volunteer_hours': volunteerHours,
        'avg_attendance': _events.isNotEmpty ? (totalParticipants / _events.length) : 0,
      },
      'financial': {
        'total_budget': totalBudget,
        'utilized_budget': budgetUtilized,
        'remaining_budget': budgetRemaining,
        'utilization_rate': totalBudget > 0 ? (budgetUtilized / totalBudget * 100) : 0,
      },
      'sponsorship': {
        'total_sponsors': totalSponsors,
        'active_sponsors': activeSponsors,
        'total_contributions': totalSponsorshipAmount,
        'avg_contribution': activeSponsors > 0 ? (totalSponsorshipAmount / activeSponsors) : 0,
      },
    };
  }

  /// Get monthly performance data - SAFE VERSION without complex queries
  Future<Map<String, dynamic>> _getMonthlyPerformanceSafe() async {
    try {
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);

      // Use existing events data instead of new query to avoid index issues
      final recentEvents = _events.where((event) => 
        event.startTime.isAfter(sixMonthsAgo)
      ).toList();

      final monthlyData = <String, Map<String, dynamic>>{};

      for (final event in recentEvents) {
        final monthKey = '${event.startTime.year}-${event.startTime.month}';
        
        if (!monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = {
            'events': 0,
            'participants': 0,
            'completed': 0,
          };
        }

        monthlyData[monthKey]!['events'] = monthlyData[monthKey]!['events'] + 1;
        monthlyData[monthKey]!['participants'] = monthlyData[monthKey]!['participants'] + event.currentParticipants;
        
        if (event.status == 'completed') {
          monthlyData[monthKey]!['completed'] = monthlyData[monthKey]!['completed'] + 1;
        }
      }

      return {'monthly_data': monthlyData};
    } catch (e) {
      print('Error in monthly performance: $e');
      return {'monthly_data': {}};
    }
  }

  /// Get sponsorship success rate
  Future<Map<String, dynamic>> _getSponsorshipSuccessRate() async {
    try {
      final totalSponsorships = _sponsorships.length;
      final approvedSponsorships = _sponsorships.where((s) => s.status == 'approved').length;
      final pendingSponsorships = _sponsorships.where((s) => s.status == 'pending').length;
      final rejectedSponsorships = _sponsorships.where((s) => s.status == 'rejected').length;

      return {
        'total': totalSponsorships,
        'approved': approvedSponsorships,
        'pending': pendingSponsorships,
        'rejected': rejectedSponsorships,
        'success_rate': totalSponsorships > 0 ? (approvedSponsorships / totalSponsorships * 100) : 0,
      };
    } catch (e) {
      print('Error in sponsorship success rate: $e');
      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'success_rate': 0,
      };
    }
  }

  /// Get sponsor contribution statistics
  Map<String, dynamic> _getSponsorContributionStats() {
    try {
      final totalContributions = _sponsorships.fold<double>(0.0, (sum, sponsorship) => sum + sponsorship.amount);
      final averageContribution = _sponsorships.isNotEmpty ? totalContributions / _sponsorships.length : 0;
      
      final contributionByTier = <String, double>{
        'bronze': _sponsorships
            .where((s) => _getSponsorTier(s.sponsorId) == 'bronze')
            .fold(0.0, (sum, s) => sum + s.amount),
        'silver': _sponsorships
            .where((s) => _getSponsorTier(s.sponsorId) == 'silver')
            .fold(0.0, (sum, s) => sum + s.amount),
        'gold': _sponsorships
            .where((s) => _getSponsorTier(s.sponsorId) == 'gold')
            .fold(0.0, (sum, s) => sum + s.amount),
        'platinum': _sponsorships
            .where((s) => _getSponsorTier(s.sponsorId) == 'platinum')
            .fold(0.0, (sum, s) => sum + s.amount),
      };

      return {
        'total_contributions': totalContributions,
        'average_contribution': averageContribution,
        'contribution_by_tier': contributionByTier,
      };
    } catch (e) {
      print('Error in sponsor contribution stats: $e');
      return {
        'total_contributions': 0.0,
        'average_contribution': 0.0,
        'contribution_by_tier': {},
      };
    }
  }

  /// Helper method to get sponsor tier
  String _getSponsorTier(String sponsorId) {
    try {
      final sponsor = _sponsors.firstWhere((s) => s.sponsorId == sponsorId);
      return sponsor.tier;
    } catch (e) {
      return 'unknown';
    }
  }

  double _calculateEngagementRate() {
    final totalCapacity = _events.fold<int>(0, (sum, event) => sum + event.maxParticipants);
    return totalCapacity > 0 ? (totalParticipants / totalCapacity * 100) : 0;
  }

  /// Get recent events (last 5)
  List<EventModel> get recentEvents {
    return _events.take(5).toList();
  }

  /// Get recent sponsors (last 5)
  List<SponsorModel> get recentSponsors {
    return _sponsors
        .where((sponsor) => sponsor.isActive)
        .take(5)
        .toList();
  }

  /// Get pending sponsorships
  List<SponsorshipModel> get pendingSponsorships {
    return _sponsorships
        .where((sponsorship) => sponsorship.status == 'pending')
        .toList();
  }

  /// Create a new event
  Future<void> createEvent(EventModel event) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.createEvent(event);
      
      // Reload relevant data
      await _loadEvents();
      await _loadAchievements();
      await _loadAnalyticsData();

    } catch (e) {
      _error = 'Failed to create event: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    try {
      await _databaseService.updateEventStatus(eventId, status);
      await _loadEvents();
    } catch (e) {
      _error = 'Failed to update event status: $e';
      rethrow;
    }
  }

  /// Approve a report
  Future<void> approveReport(String reportId) async {
    try {
      await _databaseService.updateReportStatus(reportId, 'approved');
      _pendingReports.removeWhere((report) => report.reportId == reportId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to approve report: $e';
      rethrow;
    }
  }

  /// Reject a report
  Future<void> rejectReport(String reportId, String reason) async {
    try {
      await _databaseService.updateReportStatus(reportId, 'rejected');
      _pendingReports.removeWhere((report) => report.reportId == reportId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reject report: $e';
      rethrow;
    }
  }

  /// Create sponsorship request
  Future<void> createSponsorship(SponsorshipModel sponsorship) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.createSponsorship(sponsorship);
      await _loadSponsorships();

    } catch (e) {
      _error = 'Failed to create sponsorship: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      await _databaseService.updateSponsorshipStatus(
        sponsorshipId, 
        status,
        rejectionReason: rejectionReason,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
      );
      await _loadSponsorships();
    } catch (e) {
      _error = 'Failed to update sponsorship status: $e';
      rethrow;
    }
  }

  /// Add new sponsor
  Future<void> addSponsor(SponsorModel sponsor) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.addSponsor(sponsor);
      await _loadSponsors();
      await _loadAchievements();
      await _loadAnalyticsData();
      await _loadSponsorAnalytics();

    } catch (e) {
      _error = 'Failed to add sponsor: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update sponsor information
  Future<void> updateSponsor(SponsorModel sponsor) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.updateSponsor(sponsor.sponsorId, sponsor.toMap());
      await _loadSponsors();
      await _loadAnalyticsData();
      await _loadSponsorAnalytics();

    } catch (e) {
      _error = 'Failed to update sponsor: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate/deactivate sponsor
  Future<void> manageSponsorStatus(String sponsorId, bool isActive) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _databaseService.updateSponsor(sponsorId, {'is_active': isActive});
      await _loadSponsors();
      await _loadAchievements();
      await _loadAnalyticsData();
      await _loadSponsorAnalytics();

    } catch (e) {
      _error = 'Failed to manage sponsor status: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get event participation statistics
  Future<Map<String, dynamic>> getEventParticipationStats(String eventId) async {
    try {
      final participationsSnapshot = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .where('event_id', isEqualTo: eventId)
          .get();

      final totalParticipants = participationsSnapshot.docs.length;
      final attendedParticipants = participationsSnapshot.docs
          .where((doc) => (doc.data())['status'] == 'attended')
          .length;
      final totalHours = participationsSnapshot.docs.fold<int>(0, (sum, doc) {
        final data = doc.data();
        return sum + (data['hours_contributed'] as int? ?? 0);
      });

      return {
        'total_participants': totalParticipants,
        'attended_participants': attendedParticipants,
        'attendance_rate': totalParticipants > 0 ? (attendedParticipants / totalParticipants * 100) : 0,
        'total_hours': totalHours,
        'average_rating': _calculateAverageRating(participationsSnapshot.docs),
      };

    } catch (e) {
      // Return basic stats if detailed query fails
      final event = _events.firstWhere((e) => e.eventId == eventId, orElse: () => EventModel.empty());
      return {
        'total_participants': event.currentParticipants,
        'attended_participants': event.currentParticipants,
        'attendance_rate': 100.0,
        'total_hours': event.currentParticipants * 4, // Estimate
        'average_rating': 4.5, // Default rating
      };
    }
  }

  /// Get NGO analytics
  Future<Map<String, dynamic>> getNGOAnalytics() async {
    try {
      return {
        'total_events': _events.length,
        'completed_events': completedProjects,
        'total_reports': _pendingReports.length,
        'total_sponsorships': _sponsorships.length,
        'total_funding': totalSponsorshipAmount,
        'success_rate': _events.length > 0 ? (completedProjects / _events.length * 100) : 0,
        'total_achievements': _achievements.where((achievement) => achievement['unlocked'] == true).length,
        'total_sponsors': totalSponsors,
        'active_sponsors': activeSponsors,
        'total_sponsorship_amount': totalSponsorshipAmount,
      };

    } catch (e) {
      throw Exception('Failed to get NGO analytics: $e');
    }
  }

  /// Get sponsor analytics
  Future<Map<String, dynamic>> getSponsorAnalyticsSummary() async {
    try {
      final tierDistribution = {
        'bronze': bronzeSponsors,
        'silver': silverSponsors,
        'gold': goldSponsors,
        'platinum': platinumSponsors,
      };

      final topSponsors = _sponsors
          .where((sponsor) => sponsor.isActive)
          .toList()
          .sublist(0, _sponsors.length < 5 ? _sponsors.length : 5)
          .map((sponsor) => {
            'name': sponsor.name.length > 20 ? '${sponsor.name.substring(0, 20)}...' : sponsor.name,
            'tier': sponsor.tier,
            'contribution': sponsor.totalContribution,
            'events_sponsored': sponsor.sponsoredEvents.length,
          })
          .toList();

      final successRate = await _getSponsorshipSuccessRate();

      return {
        'total_sponsors': totalSponsors,
        'active_sponsors': activeSponsors,
        'total_sponsorship_amount': totalSponsorshipAmount,
        'tier_distribution': tierDistribution,
        'top_sponsors': topSponsors,
        'success_rate': successRate,
        'pending_sponsorships': pendingSponsorships.length,
      };

    } catch (e) {
      throw Exception('Failed to get sponsor analytics: $e');
    }
  }

  /// Send notification to event participants
  Future<void> sendEventNotification(String eventId, String title, String message) async {
    try {
      final participationsSnapshot = await _firestore
          .collection(FirestoreConstants.participationsCollection)
          .where('event_id', isEqualTo: eventId)
          .where('status', whereIn: ['registered', 'attended'])
          .get();

      final userIds = participationsSnapshot.docs
          .map((doc) => (doc.data())['user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      for (final userId in userIds) {
        await _firestore.collection('notifications').add({
          'user_id': userId,
          'title': title,
          'message': message,
          'type': 'event_update',
          'event_id': eventId,
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      throw Exception('Failed to send notifications: $e');
    }
  }

  /// Invite volunteers to an event
  Future<void> inviteVolunteers(String eventId, List<String> emailAddresses, String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final event = _events.firstWhere((event) => event.eventId == eventId);
      
      for (final email in emailAddresses) {
        await _firestore.collection('volunteer_invitations').add({
          'event_id': eventId,
          'event_title': event.title,
          'invited_email': email,
          'message': message,
          'status': 'pending',
          'invited_by': _currentNGOId,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      _error = 'Failed to invite volunteers: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate comprehensive report - USED BY ReportGeneratorScreen
  Future<Map<String, dynamic>> generateComprehensiveReport(DateTime startDate, DateTime endDate) async {
    try {
      // Use existing data instead of new queries to avoid index issues
      final eventsInRange = _events.where((event) => 
        event.startTime.isAfter(startDate) && event.startTime.isBefore(endDate)
      ).toList();

      final totalParticipants = eventsInRange.fold<int>(0, (sum, event) => sum + event.currentParticipants);
      final totalFunding = _sponsorships.fold<double>(0.0, (sum, sponsorship) => sum + sponsorship.amount);

      // Get approved reports count
      final approvedReportsCount = _pendingReports.where((report) => 
        report.status == 'approved' && 
        report.createdAt.isAfter(startDate) && 
        report.createdAt.isBefore(endDate)
      ).length;

      return {
        'period': '${startDate.toLocal()} to ${endDate.toLocal()}',
        'total_events': eventsInRange.length,
        'completed_events': eventsInRange.where((event) => event.status == 'completed').length,
        'total_participants': totalParticipants,
        'total_funding': totalFunding,
        'total_reports': _pendingReports.length,
        'approved_reports': approvedReportsCount,
        'events': eventsInRange.map((event) => event.toMap()).toList(),
        'sponsorships': _sponsorships.length,
      };

    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  // Helper methods for statistics calculation
  int _calculateTotalParticipants() {
    return _events.fold(0, (sum, event) => sum + event.currentParticipants);
  }

  double _calculateTotalBudget() {
    return _sponsorships.fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);
  }

  double _calculateBudgetUtilized() {
    return _sponsorships
        .where((sponsorship) => sponsorship.status == 'completed')
        .fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);
  }

  double _calculateTotalSponsorshipAmount() {
    return _sponsorships
        .where((sponsorship) => sponsorship.status == 'approved')
        .fold(0.0, (sum, sponsorship) => sum + sponsorship.amount);
  }

  int _calculateCommunityMembers() {
    // Simple estimation based on event participants
    return _events.fold<int>(0, (sum, event) => sum + event.currentParticipants);
  }

  int _calculateVolunteerHours() {
    // Estimate based on participants and average hours
    return _events.fold(0, (sum, event) => sum + (event.currentParticipants * 4));
  }

  double _calculateAverageRating(List<QueryDocumentSnapshot<Object?>> participations) {
    final ratedParticipations = participations.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['rating'] != null;
    }).toList();
    
    if (ratedParticipations.isEmpty) return 0.0;
    
    final totalRating = ratedParticipations.fold<int>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + (data['rating'] as int);
    });
    
    return totalRating / ratedParticipations.length;
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

  /// Get top 3 nearby green spaces (sorted by health status and biodiversity)
  Future<List<GreenSpaceModel>> getTopNearbyGreenSpaces({int limit = 3}) async {
    try {
      final spacesSnapshot = await _firestore
          .collection(FirestoreConstants.greenSpacesCollection)
          .get();

      List<GreenSpaceModel> allSpaces = spacesSnapshot.docs.map((doc) {
        return GreenSpaceModel.fromMap(doc.data());
      }).toList();

      // Sort by: healthy status first, then by biodiversity index, then by area
      allSpaces.sort((a, b) {
        // Health priority: healthy > restored > degraded > critical
        final healthScoreA = _getHealthScore(a.status);
        final healthScoreB = _getHealthScore(b.status);
        if (healthScoreA != healthScoreB) return healthScoreB.compareTo(healthScoreA);

        // Then by biodiversity
        if (a.biodiversityIndex != b.biodiversityIndex) {
          return b.biodiversityIndex.compareTo(a.biodiversityIndex);
        }

        // Then by area
        return b.area.compareTo(a.area);
      });

      _topNearbyGreenSpaces = allSpaces.take(limit).toList();
      notifyListeners();
      return _topNearbyGreenSpaces;
    } catch (e) {
      print('❌ Error fetching top nearby green spaces: $e');
      return [];
    }
  }

  /// Helper to score health status for sorting
  int _getHealthScore(String status) {
    switch (status) {
      case 'healthy':
        return 4;
      case 'restored':
        return 3;
      case 'degraded':
        return 2;
      case 'critical':
        return 1;
      default:
        return 0;
    }
  }

  /// Get unread notifications count for the current user
  Future<int> getUnreadNotificationsCount() async {
    try {
      if (_currentNGOId == null) return 0;

      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: _currentNGOId)
          .where('is_read', isEqualTo: false)
          .get();

      _unreadNotificationsCount = notificationsSnapshot.size;
      notifyListeners();
      return _unreadNotificationsCount;
    } catch (e) {
      print('⚠️  Error fetching unread notifications count: $e');
      return 0;
    }
  }

  /// Stream of real-time unread notifications count (for live badge updates)
  Stream<int> getUnreadNotificationsStream() {
    if (_currentNGOId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: _currentNGOId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Dispose provider
  void disposeProvider() {
    _currentNGOId = null;
  }
}