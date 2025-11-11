import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/core/models/plant_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

class DashboardProvider with ChangeNotifier {
  List<GreenSpaceModel> _nearbySpaces = [];
  List<EventModel> _upcomingEvents = [];
  List<PlantModel> _adoptedPlants = [];
  int _attendedEvents = 0;
  int _greenPoints = 0;
  bool _isLoading = false;
  String? _error;
  
  // Impact Statistics
  Map<String, dynamic> _impactStats = {};
  Map<String, dynamic> _systemStats = {};
  int _totalVolunteerHours = 0;
  int _totalReportsSubmitted = 0;
  int _approvedReports = 0;
  double _reportApprovalRate = 0.0;
  double _eventAttendanceRate = 0.0;

  // Database service
  final DatabaseService _databaseService = DatabaseService();

  List<GreenSpaceModel> get nearbySpaces => _nearbySpaces;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<PlantModel> get adoptedPlants => _adoptedPlants;
  int get attendedEvents => _attendedEvents;
  int get greenPoints => _greenPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get impactStats => _impactStats;
  Map<String, dynamic> get systemStats => _systemStats;
  int get totalVolunteerHours => _totalVolunteerHours;
  int get totalReportsSubmitted => _totalReportsSubmitted;
  int get approvedReports => _approvedReports;
  double get reportApprovalRate => _reportApprovalRate;
  double get eventAttendanceRate => _eventAttendanceRate;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Loading dashboard data from Firebase...');

      // Load all data in parallel
      await Future.wait([
        _loadNearbySpaces(),
        _loadUpcomingEvents(),
        _loadAdoptedPlants(),
        _loadImpactStatistics(),
        _loadSystemStatistics(),
      ]);

      print('✅ Dashboard data loaded successfully');
      print('📊 Nearby spaces: ${_nearbySpaces.length}');
      print('📅 Upcoming events: ${_upcomingEvents.length}');
      print('🌿 Adopted plants: ${_adoptedPlants.length}');
      print('🎯 Impact stats: $_impactStats');

    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      print('❌ Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNearbySpaces() async {
    try {
      print('📍 Loading nearby green spaces...');
      final snapshot = await _databaseService.getGreenSpaces().first;
      _nearbySpaces = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return GreenSpaceModel.fromMap(data);
          })
          .toList();
      
      print('✅ Loaded ${_nearbySpaces.length} green spaces');
    } catch (e) {
      // Handle Firestore permission errors gracefully
      if (e is FirebaseException && e.code == 'permission-denied') {
        _error = 'Insufficient permissions to load nearby green spaces.';
      } else {
        _error = 'Failed to load green spaces: $e';
      }
      print('❌ Error loading nearby spaces: $e');
      _nearbySpaces = []; // Clear any previous data
    }
  }

  Future<void> _loadUpcomingEvents() async {
    try {
      print('📅 Loading upcoming events...');
      final snapshot = await _databaseService.getUpcomingEvents().first;
      _upcomingEvents = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return EventModel.fromMap(data);
          })
          .toList();
      
      print('✅ Loaded ${_upcomingEvents.length} upcoming events');
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        _error = 'Insufficient permissions to load upcoming events.';
      } else {
        _error = 'Failed to load upcoming events: $e';
      }
      print('❌ Error loading upcoming events: $e');
      _upcomingEvents = []; // Clear any previous data
    }
  }

  Future<void> _loadAdoptedPlants() async {
    try {
      print('🌿 Loading adopted plants...');
      final currentUser = await _databaseService.getCurrentUser();
      final snapshot = await _databaseService.getAdoptedPlantsByUser(currentUser.userId).first;
      _adoptedPlants = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return PlantModel.fromMap(data);
          })
          .toList();
      
      print('✅ Loaded ${_adoptedPlants.length} adopted plants');
    } catch (e) {
      _error = 'Failed to load adopted plants: $e';
      print('❌ Error loading adopted plants: $e');
      _adoptedPlants = []; // Clear any previous data
    }
  }

  Future<void> _loadImpactStatistics() async {
    try {
      print('📈 Loading impact statistics...');
      final currentUser = await _databaseService.getCurrentUser();
      _impactStats = await _databaseService.getUserImpactStatistics(currentUser.userId);
      
      // Extract individual stats for easy access with null safety
      _totalReportsSubmitted = (_impactStats['total_reports'] as int?) ?? 0;
      _approvedReports = (_impactStats['approved_reports'] as int?) ?? 0;
      _attendedEvents = (_impactStats['attended_events'] as int?) ?? 0;
      _totalVolunteerHours = (_impactStats['total_volunteer_hours'] as int?) ?? 0;
      _reportApprovalRate = (_impactStats['report_approval_rate'] as double?) ?? 0.0;
      _eventAttendanceRate = (_impactStats['event_attendance_rate'] as double?) ?? 0.0;
      
      // Get current user to get actual impact score from Firestore
      final user = await _databaseService.getCurrentUser();
      _greenPoints = user.impactScore;
      
      print('✅ Loaded impact statistics:');
      print('   - Reports: $_totalReportsSubmitted ($_approvedReports approved)');
      print('   - Events: $_attendedEvents attended');
      print('   - Volunteer Hours: $_totalVolunteerHours');
      print('   - Green Points: $_greenPoints');
      
    } catch (e) {
      _error = 'Failed to load impact statistics: $e';
      print('❌ Error loading impact statistics: $e');
      _resetImpactStats();
    }
  }

  Future<void> _loadSystemStatistics() async {
    try {
      print('🌐 Loading system statistics...');
      _systemStats = await _databaseService.getSystemStatistics();
      print('✅ Loaded system statistics: $_systemStats');
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        _error = 'Insufficient permissions to load platform statistics.';
      } else {
        _error = 'Failed to load system statistics: $e';
      }
      print('❌ Error loading system statistics: $e');
      _systemStats = {};
    }
  }

  void _resetImpactStats() {
    _impactStats = {};
    _totalReportsSubmitted = 0;
    _approvedReports = 0;
    _attendedEvents = 0;
    _totalVolunteerHours = 0;
    _reportApprovalRate = 0.0;
    _eventAttendanceRate = 0.0;
    _greenPoints = 0;
  }

  // Impact progress calculations
  int get userLevel {
    if (_greenPoints >= 1000) return 4; // Eco Champion
    if (_greenPoints >= 500) return 3; // Eco Enthusiast
    if (_greenPoints >= 200) return 2; // Green Guardian
    return 1; // Green Beginner
  }

  String get userLevelName {
    switch (userLevel) {
      case 4: return 'Eco Champion';
      case 3: return 'Eco Enthusiast';
      case 2: return 'Green Guardian';
      default: return 'Green Beginner';
    }
  }

  int get pointsToNextLevel {
    final pointsNeeded = switch (userLevel) {
      1 => 200 - _greenPoints,
      2 => 500 - _greenPoints,
      3 => 1000 - _greenPoints,
      _ => 0,
    };
    return pointsNeeded > 0 ? pointsNeeded : 0;
  }

  double get levelProgress {
    return switch (userLevel) {
      1 => _greenPoints / 200,
      2 => (_greenPoints - 200) / 300,
      3 => (_greenPoints - 500) / 500,
      _ => 1.0,
    };
  }

  String get nextLevelName {
    return switch (userLevel) {
      1 => 'Green Guardian',
      2 => 'Eco Enthusiast',
      3 => 'Eco Champion',
      _ => 'Max Level',
    };
  }

  // Refresh methods
  Future<void> refreshEvents() async {
    try {
      print('🔄 Refreshing events...');
      await _loadUpcomingEvents();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh events: $e';
      notifyListeners();
    }
  }

  Future<void> refreshGreenSpaces() async {
    try {
      print('🔄 Refreshing green spaces...');
      await _loadNearbySpaces();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh green spaces: $e';
      notifyListeners();
    }
  }

  Future<void> refreshPlants() async {
    try {
      print('🔄 Refreshing plants...');
      await _loadAdoptedPlants();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh plants: $e';
      notifyListeners();
    }
  }

  Future<void> refreshImpactStats() async {
    try {
      print('🔄 Refreshing impact statistics...');
      await _loadImpactStatistics();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh impact stats: $e';
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Statistics getters
  int get totalGreenSpaces => _nearbySpaces.length;
  int get totalUpcomingEvents => _upcomingEvents.length;
  int get totalAdoptedPlants => _adoptedPlants.length;

  double get averageSpaceHealth {
    if (_nearbySpaces.isEmpty) return 0.0;
    
    final healthScores = {
      'healthy': 100,
      'restored': 80,
      'degraded': 40,
      'critical': 20,
    };
    
    final totalScore = _nearbySpaces.fold(0, (sum, space) {
      return sum + (healthScores[space.status] ?? 50);
    });
    
    return totalScore / _nearbySpaces.length;
  }

  // Get events by status
  List<EventModel> getEventsByStatus(String status) {
    return _upcomingEvents.where((event) => event.status == status).toList();
  }

  // Get spaces by type
  List<GreenSpaceModel> getSpacesByType(String type) {
    return _nearbySpaces.where((space) => space.type == type).toList();
  }

  // Get user's upcoming participations
  Future<List<EventModel>> getUserUpcomingParticipations() async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      final participationsSnapshot = await _databaseService.getUserParticipations(currentUser.userId).first;
      
      final userEventIds = participationsSnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String?;
            return status == 'registered' || status == 'attended';
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return data['event_id'] as String? ?? '';
          })
          .where((eventId) => eventId.isNotEmpty)
          .toList();

      return _upcomingEvents.where((event) => userEventIds.contains(event.eventId)).toList();
    } catch (e) {
      print('❌ Error getting user participations: $e');
      return [];
    }
  }

  // Join an event
  Future<void> joinEvent(String eventId) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      await _databaseService.joinEvent(eventId, currentUser.userId);
      
      // Refresh data to reflect changes
      await refreshImpactStats();
      await refreshEvents();
      
      print('✅ Successfully joined event: $eventId');
    } catch (e) {
      _error = 'Failed to join event: $e';
      print('❌ Error joining event: $e');
      notifyListeners();
    }
  }

  // Adopt a plant
  Future<void> adoptPlant(String plantId) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      await _databaseService.adoptPlant(plantId, currentUser.userId);
      
      // Refresh data to reflect changes
      await refreshPlants();
      await refreshImpactStats();
      
      print('✅ Successfully adopted plant: $plantId');
    } catch (e) {
      _error = 'Failed to adopt plant: $e';
      print('❌ Error adopting plant: $e');
      notifyListeners();
    }
  }

  // Submit a report
  Future<void> submitReport(ReportModel report) async {
    try {
      await _databaseService.submitReport(report);
      
      // Refresh impact stats to reflect new report
      await refreshImpactStats();
      
      print('✅ Successfully submitted report: ${report.reportId}');
    } catch (e) {
      _error = 'Failed to submit report: $e';
      print('❌ Error submitting report: $e');
      notifyListeners();
    }
  }

  // Check if user is participating in an event
  Future<bool> isUserParticipating(String eventId) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      return await _databaseService.isUserParticipating(eventId, currentUser.userId);
    } catch (e) {
      print('❌ Error checking participation: $e');
      return false;
    }
  }

  // Get user's total impact contribution
  Map<String, dynamic> getUserImpactBreakdown() {
    return {
      'reports_approved': _approvedReports,
      'events_attended': _attendedEvents,
      'volunteer_hours': _totalVolunteerHours,
      'plants_adopted': _adoptedPlants.length,
      'total_points': _greenPoints,
      'report_approval_rate': _reportApprovalRate,
      'event_attendance_rate': _eventAttendanceRate,
    };
  }

  // Get progress towards next milestone
  Map<String, dynamic> getNextMilestone() {
    const milestones = [
      {'points': 100, 'title': 'First 100 Points', 'reward': 'Green Beginner Badge'},
      {'points': 200, 'title': 'Level Up to Guardian', 'reward': 'Green Guardian Status'},
      {'points': 500, 'title': 'Eco Enthusiast', 'reward': 'Eco Enthusiast Status'},
      {'points': 1000, 'title': 'Eco Champion', 'reward': 'Eco Champion Status'},
    ];

    for (final milestone in milestones) {
      final targetPoints = milestone['points'] as int;
      if (_greenPoints < targetPoints) {
        return {
          'target_points': targetPoints,
          'current_points': _greenPoints,
          'points_needed': targetPoints - _greenPoints,
          'title': milestone['title'] as String,
          'reward': milestone['reward'] as String,
          'progress': _greenPoints / targetPoints,
        };
      }
    }

    return {
      'target_points': 1000,
      'current_points': _greenPoints,
      'points_needed': 0,
      'title': 'Max Level Achieved!',
      'reward': 'Eco Champion',
      'progress': 1.0,
    };
  }

  // Get recent activity summary
  Map<String, dynamic> getRecentActivitySummary() {
    return {
      'recent_reports': _totalReportsSubmitted,
      'recent_events': _attendedEvents,
      'recent_plants': _adoptedPlants.length,
      'recent_hours': _totalVolunteerHours,
      'level_progress': levelProgress,
      'next_level': nextLevelName,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset all data
  void reset() {
    _nearbySpaces.clear();
    _upcomingEvents.clear();
    _adoptedPlants.clear();
    _resetImpactStats();
    _systemStats.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Dispose method to clean up resources
  @override
  void dispose() {
    // Clean up any listeners or resources if needed
    super.dispose();
  }
}