import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';
import 'package:urban_green_mapper/core/models/sponsorship_model.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/create_event_dialog.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/report_generator_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/sponsors_management_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/volunteer_invitation_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/analytics_dashboard.dart';

// Color utility class to handle nullable colors permanently
class DashboardColors {
  // Constant colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryWhite = Colors.white;
  static const Color primaryGrey = Colors.grey;
  static const Color primaryRed = Colors.red;
  static const Color primaryBlue = Colors.blue;
  static const Color primaryOrange = Colors.orange;
  static const Color primaryPurple = Colors.purple;
  static const Color primaryTeal = Colors.teal;
  static const Color primaryIndigo = Colors.indigo;
  static const Color primaryAmber = Colors.amber;
  
  // Status colors
  static const Color statusUpcoming = Colors.blue;
  static const Color statusOngoing = Colors.green;
  static const Color statusCompleted = Colors.grey;
  static const Color statusCancelled = Colors.red;
  
  // Tier colors
  static const Color tierPlatinum = Colors.blueGrey;
  static const Color tierGold = Colors.amber;
  static const Color tierSilver = Colors.grey;
  static const Color tierBronze = Colors.orange;
  
  // Safe color getters that never return null
  static Color safeGrey(int shade) {
    final color = Colors.grey[shade];
    return color ?? Colors.grey;
  }
  
  static Color safeGreen(int shade) {
    final color = Colors.green[shade];
    return color ?? Colors.green;
  }
  
  static Color safeBlue(int shade) {
    final color = Colors.blue[shade];
    return color ?? Colors.blue;
  }
  
  static Color safeOrange(int shade) {
    final color = Colors.orange[shade];
    return color ?? Colors.orange;
  }
  
  static Color safeRed(int shade) {
    final color = Colors.red[shade];
    return color ?? Colors.red;
  }
  
  static Color safePurple(int shade) {
    final color = Colors.purple[shade];
    return color ?? Colors.purple;
  }
  
  // Helper method to ensure non-null color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Helper to safely convert num to double for progress values
  static double safeDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }
}

// Add the NGODashboard Screen Widget here
class NGODashboard extends StatefulWidget {
  const NGODashboard({super.key});

  @override
  State<NGODashboard> createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _initializeDashboard();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _initializeDashboard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ngoProvider = Provider.of<NGODashboardProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        ngoProvider.initialize(authProvider.user!.userId);
        ngoProvider.loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.safeGrey(50),
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        backgroundColor: DashboardColors.primaryGreen,
        foregroundColor: DashboardColors.primaryWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NGODashboardProvider>().refreshData();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuSelection(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 8),
                    Text('Advanced Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Dashboard Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: DashboardColors.primaryWhite,
          unselectedLabelColor: DashboardColors.withOpacity(DashboardColors.primaryWhite, 0.7),
          indicatorColor: DashboardColors.primaryWhite,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.business), text: 'Sponsors'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildEventsTab(),
          _buildSponsorsTab(),
          _buildAnalyticsTab(),
          _buildAchievementsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'analytics':
        _navigateToAdvancedAnalytics();
        break;
      case 'export':
        _navigateToDataExport();
        break;
      case 'settings':
        _showDashboardSettings();
        break;
    }
  }

  Widget _buildFloatingActionButton() {
    switch (_currentTabIndex) {
      case 0: // Overview
        return FloatingActionButton(
          onPressed: () => _showQuickActionMenu(context),
          backgroundColor: DashboardColors.primaryGreen,
          foregroundColor: DashboardColors.primaryWhite,
          child: const Icon(Icons.add),
        );
      case 1: // Events
        return FloatingActionButton(
          onPressed: () => _showCreateEventDialog(),
          backgroundColor: DashboardColors.primaryBlue,
          foregroundColor: DashboardColors.primaryWhite,
          child: const Icon(Icons.event),
        );
      case 2: // Sponsors
        return FloatingActionButton(
          onPressed: () => _navigateToSponsorManagement(),
          backgroundColor: DashboardColors.primaryOrange,
          foregroundColor: DashboardColors.primaryWhite,
          child: const Icon(Icons.business),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DashboardColors.safeGreen(800),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                childAspectRatio: 2.5,
                children: [
                  _buildQuickActionItem(
                    context,
                    'Create Event',
                    Icons.event,
                    DashboardColors.primaryBlue,
                    () => _showCreateEventDialog(),
                  ),
                  _buildQuickActionItem(
                    context,
                    'Add Sponsor',
                    Icons.business,
                    DashboardColors.primaryOrange,
                    () => _navigateToSponsorManagement(),
                  ),
                  _buildQuickActionItem(
                    context,
                    'Generate Report',
                    Icons.assessment,
                    DashboardColors.primaryPurple,
                    () => _navigateToReportGenerator(),
                  ),
                  _buildQuickActionItem(
                    context,
                    'Invite Volunteers',
                    Icons.people,
                    DashboardColors.primaryTeal,
                    () => _navigateToVolunteerInvitation(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.withOpacity(color, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods for upcoming features
  void _navigateToAdvancedAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsDashboard()),
    );
  }

  void _navigateToDataExport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportGeneratorScreen()),
    );
  }

  void _navigateToSponsorManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SponsorsManagementScreen()),
    );
  }

  void _navigateToReportGenerator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportGeneratorScreen()),
    );
  }

  void _navigateToVolunteerInvitation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerInvitationScreen()),
    );
  }

  void _showCreateEventDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateEventDialog(
        onEventCreated: (event) {
          final provider = Provider.of<NGODashboardProvider>(context, listen: false);
          provider.createEvent(event);
        },
      ),
    );
  }

  void _showDashboardSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dashboard Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard customization settings would appear here.'),
            SizedBox(height: 16),
            Text('Features include:'),
            Text('• Theme preferences'),
            Text('• Notification settings'),
            Text('• Data refresh intervals'),
            Text('• Export preferences'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Overview Tab
  Widget _buildOverviewTab() {
    return Consumer<NGODashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Overview
              _buildStatisticsOverview(provider),
              const SizedBox(height: 20),
              
              // Quick Stats Grid
              _buildQuickStatsGrid(provider),
              const SizedBox(height: 20),
              
              // Recent Activity
              _buildRecentActivity(provider),
              const SizedBox(height: 20),
              
              // Upcoming Events
              _buildUpcomingEvents(provider),
              const SizedBox(height: 20),
              
              // Pending Actions
              _buildPendingActions(provider),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsOverview(NGODashboardProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: DashboardColors.safeGreen(800),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  'Active Events',
                  provider.activeEvents.toString(),
                  Icons.event,
                  DashboardColors.primaryBlue,
                ),
                _buildStatCard(
                  'Total Participants',
                  provider.totalParticipants.toString(),
                  Icons.people,
                  DashboardColors.primaryGreen,
                ),
                _buildStatCard(
                  'Completed Projects',
                  provider.completedProjects.toString(),
                  Icons.check_circle,
                  DashboardColors.primaryOrange,
                ),
                _buildStatCard(
                  'Community Members',
                  provider.communityMembers.toString(),
                  Icons.group,
                  DashboardColors.primaryPurple,
                ),
                _buildStatCard(
                  'Volunteer Hours',
                  provider.volunteerHours.toString(),
                  Icons.access_time,
                  DashboardColors.primaryTeal,
                ),
                _buildStatCard(
                  'Partner Sponsors',
                  provider.partnerSponsors.toString(),
                  Icons.handshake,
                  DashboardColors.primaryIndigo,
                ),
                _buildStatCard(
                  'Pending Reports',
                  provider.pendingReportsCount.toString(),
                  Icons.report,
                  DashboardColors.primaryRed,
                ),
                _buildStatCard(
                  'Total Budget',
                  '\$${provider.totalBudget.toStringAsFixed(0)}',
                  Icons.attach_money,
                  DashboardColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.withOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.withOpacity(color, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DashboardColors.safeGrey(700),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(NGODashboardProvider provider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildQuickStatItem(
          'Budget Utilized',
          '\$${provider.budgetUtilized.toStringAsFixed(0)}',
          '${provider.totalBudget > 0 ? (provider.budgetUtilized / provider.totalBudget * 100).toStringAsFixed(1) : '0'}%',
          DashboardColors.primaryGreen,
        ),
        _buildQuickStatItem(
          'Budget Remaining',
          '\$${provider.budgetRemaining.toStringAsFixed(0)}',
          '${provider.totalBudget > 0 ? (provider.budgetRemaining / provider.totalBudget * 100).toStringAsFixed(1) : '0'}%',
          DashboardColors.primaryBlue,
        ),
        _buildQuickStatItem(
          'Success Rate',
          '${provider.events.isNotEmpty ? (provider.completedProjects / provider.events.length * 100).toStringAsFixed(1) : '0'}%',
          '${provider.completedProjects}/${provider.events.length} events',
          DashboardColors.primaryOrange,
        ),
        _buildQuickStatItem(
          'Engagement Rate',
          '${_calculateEngagementRate(provider).toStringAsFixed(1)}%',
          '${provider.totalParticipants} participants',
          DashboardColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildQuickStatItem(String title, String value, String subtitle, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DashboardColors.safeGrey(500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(NGODashboardProvider provider) {
    final recentEvents = provider.recentEvents;
    final recentSponsors = provider.recentSponsors.take(3).toList();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: DashboardColors.safeGreen(800),
              ),
            ),
            const SizedBox(height: 16),
            
            // Recent Events
            if (recentEvents.isNotEmpty) ...[
              _buildSectionHeader('Recent Events', Icons.event),
              ...recentEvents.take(2).map((event) => _buildEventListItem(event)),
              const SizedBox(height: 16),
            ],
            
            // Recent Sponsors
            if (recentSponsors.isNotEmpty) ...[
              _buildSectionHeader('New Sponsors', Icons.business),
              ...recentSponsors.map((sponsor) => _buildSponsorListItem(sponsor)),
            ],
            
            if (recentEvents.isEmpty && recentSponsors.isEmpty)
              _buildEmptyState('No recent activity', Icons.history),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DashboardColors.safeGrey(600)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safeGrey(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safeGrey(200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.withOpacity(_getStatusColor(event.status), 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event,
              color: _getStatusColor(event.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.currentParticipants} participants • ${_formatDate(event.startTime)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DashboardColors.safeGrey(600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DashboardColors.withOpacity(_getStatusColor(event.status), 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.status.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getStatusColor(event.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorListItem(SponsorModel sponsor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safeGrey(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safeGrey(200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.withOpacity(_getTierColor(sponsor.tier), 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                sponsor.name[0].toUpperCase(),
                style: TextStyle(
                  color: _getTierColor(sponsor.tier),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sponsor.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${sponsor.tier} • \$${sponsor.totalContribution.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DashboardColors.safeGrey(600),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified,
            color: sponsor.isActive ? DashboardColors.primaryGreen : DashboardColors.primaryGrey,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(NGODashboardProvider provider) {
    final upcomingEvents = provider.events
        .where((event) => event.status == 'upcoming' && event.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.safeGreen(800),
                  ),
                ),
                const Spacer(),
                if (upcomingEvents.isNotEmpty)
                  Text(
                    '${upcomingEvents.length} events',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DashboardColors.safeGrey(600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (upcomingEvents.isEmpty)
              _buildEmptyState('No upcoming events', Icons.event),
            
            ...upcomingEvents.take(3).map((event) => _buildUpcomingEventItem(event)),
            
            if (upcomingEvents.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: () {
                    _tabController.animateTo(1); // Switch to Events tab
                  },
                  child: const Text('View All Events'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventItem(EventModel event) {
    final daysUntil = event.startTime.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safeBlue(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safeBlue(100)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DashboardColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${event.startTime.day}',
                style: const TextStyle(
                  color: DashboardColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.location} • ${_formatTime(event.startTime)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DashboardColors.safeGrey(600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: daysUntil <= 7 ? DashboardColors.safeOrange(100) : DashboardColors.safeGreen(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              daysUntil == 0 ? 'Today' : '$daysUntil days',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: daysUntil <= 7 ? DashboardColors.safeOrange(800) : DashboardColors.safeGreen(800),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(NGODashboardProvider provider) {
    final pendingReports = provider.pendingReports;
    final pendingSponsorships = provider.pendingSponsorships;
    
    final totalPending = pendingReports.length + pendingSponsorships.length;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pending Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.safeGreen(800),
                  ),
                ),
                const Spacer(),
                if (totalPending > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DashboardColors.withOpacity(DashboardColors.primaryRed, 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalPending pending',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DashboardColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (totalPending == 0)
              _buildEmptyState('No pending actions', Icons.check_circle),
            
            // Pending Reports
            if (pendingReports.isNotEmpty) ...[
              _buildSectionHeader('Reports to Review', Icons.report),
              ...pendingReports.take(2).map((report) => _buildPendingReportItem(report)),
            ],
            
            // Pending Sponsorships
            if (pendingSponsorships.isNotEmpty) ...[
              _buildSectionHeader('Sponsorship Requests', Icons.request_quote),
              ...pendingSponsorships.take(2).map((sponsorship) => _buildPendingSponsorshipItem(sponsorship)),
            ],
            
            if (totalPending > 2)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: () {
                    // Navigate to pending items screen
                    _showPendingItemsManagement();
                  },
                  child: const Text('View All Pending Items'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReportItem(ReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safeOrange(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safeOrange(200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.safeOrange(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.report, color: DashboardColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title ?? report.typeDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'By: ${report.userName ?? report.userId} • ${_formatDate(report.createdAt)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DashboardColors.safeGrey(600),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility, size: 20),
            onPressed: () => _showReportReview(report),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSponsorshipItem(SponsorshipModel sponsorship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardColors.safePurple(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.safePurple(200)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DashboardColors.safePurple(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.request_quote, color: DashboardColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sponsorship Request',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${sponsorship.amount.toStringAsFixed(0)} • ${_formatDate(sponsorship.proposedAt)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: DashboardColors.safeGrey(600),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.thumb_up, size: 20),
            onPressed: () => _approveSponsorship(sponsorship),
          ),
        ],
      ),
    );
  }

  // Events Tab
  Widget _buildEventsTab() {
    return Consumer<NGODashboardProvider>(
      builder: (context, provider, child) {
        final events = provider.events;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        // Implement search functionality
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('All'),
                    selected: true,
                    onSelected: (selected) {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _buildEmptyState('No events created yet', Icons.event)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DashboardColors.withOpacity(_getStatusColor(event.status), 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(event.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEventDetail(Icons.calendar_today, _formatDate(event.startTime)),
                _buildEventDetail(Icons.location_on, event.location),
                _buildEventDetail(Icons.people, '${event.currentParticipants}/${event.maxParticipants}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editEvent(event),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _manageEvent(event),
                    child: const Text('Manage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetail(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: DashboardColors.safeGrey(600)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Sponsors Tab
  Widget _buildSponsorsTab() {
    return Consumer<NGODashboardProvider>(
      builder: (context, provider, child) {
        final sponsors = provider.sponsors;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search sponsors...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    onSelected: (tier) {
                      // Implement tier filtering
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'all', child: Text('All Tiers')),
                      const PopupMenuItem(value: 'platinum', child: Text('Platinum')),
                      const PopupMenuItem(value: 'gold', child: Text('Gold')),
                      const PopupMenuItem(value: 'silver', child: Text('Silver')),
                      const PopupMenuItem(value: 'bronze', child: Text('Bronze')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: DashboardColors.safeGrey(300)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Text('Filter'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sponsors.isEmpty
                  ? _buildEmptyState('No sponsors yet', Icons.business)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sponsors.length,
                      itemBuilder: (context, index) {
                        final sponsor = sponsors[index];
                        return _buildSponsorCard(sponsor);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSponsorCard(SponsorModel sponsor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: DashboardColors.withOpacity(_getTierColor(sponsor.tier), 0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: _getTierColor(sponsor.tier)),
                  ),
                  child: Center(
                    child: Text(
                      sponsor.name[0].toUpperCase(),
                      style: TextStyle(
                        color: _getTierColor(sponsor.tier),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sponsor.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: DashboardColors.withOpacity(_getTierColor(sponsor.tier), 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sponsor.tier.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _getTierColor(sponsor.tier),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: sponsor.isActive ? DashboardColors.primaryGreen : DashboardColors.primaryGrey,
                            size: 16,
                          ),
                          Text(
                            sponsor.isActive ? 'Active' : 'Inactive',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: sponsor.isActive ? DashboardColors.primaryGreen : DashboardColors.primaryGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSponsorDetail('Total Contribution', '\$${sponsor.totalContribution.toStringAsFixed(0)}'),
                _buildSponsorDetail('Events Sponsored', sponsor.sponsoredEventsCount.toString()),
                _buildSponsorDetail('Joined', _formatDate(sponsor.joinedAt)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editSponsor(sponsor),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewSponsorDetails(sponsor),
                    child: const Text('View'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardColors.safeGrey(600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Analytics Tab
  Widget _buildAnalyticsTab() {
    return Consumer<NGODashboardProvider>(
      builder: (context, provider, child) {
        final analyticsData = provider.analyticsData;
        final sponsorAnalytics = provider.sponsorAnalytics;
        final mobileCards = provider.mobileAnalyticsCards;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Mobile Analytics Cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: mobileCards.length,
                itemBuilder: (context, index) {
                  final card = mobileCards[index];
                  return _buildAnalyticsCard(card);
                },
              ),
              const SizedBox(height: 20),
              
              // Analytics Summary
              _buildAnalyticsSummary(provider.analyticsSummary),
              const SizedBox(height: 20),
              
              // Additional Analytics Sections
              if (analyticsData.isNotEmpty)
                ...analyticsData.map((data) => _buildAnalyticsSection(data)),
              
              if (sponsorAnalytics.isNotEmpty)
                ...sponsorAnalytics.map((data) => _buildSponsorAnalyticsSection(data)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(Map<String, dynamic> card) {
    final color = Color(card['color'] as int);
    final data = card['data'] as Map<String, dynamic>;
    
    return Card(
      elevation: 2,
      color: DashboardColors.withOpacity(color, 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DashboardColors.withOpacity(color, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card['icon'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              card['title'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...data.entries.map((entry) => _buildAnalyticsCardItem(entry.key, entry.value.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCardItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummary(Map<String, dynamic> summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...summary.entries.map((section) => _buildAnalyticsSummarySection(section.key, section.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummarySection(String section, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(section),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.entries.map((entry) => _buildSummaryItem(entry.key, entry.value)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DashboardColors.safeGrey(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatLabel(label),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: DashboardColors.safeGrey(600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value is double ? value.toStringAsFixed(1) : value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _capitalize(data['type'] as String),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // You can add specific visualization for each analytics type here
            Text(
              'Analytics data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSponsorAnalyticsSection(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sponsor ${_capitalize(data['type'] as String)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sponsor analytics data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Achievements Tab
  Widget _buildAchievementsTab() {
    return Consumer<NGODashboardProvider>(
      builder: (context, provider, child) {
        final achievements = provider.achievements;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Achievement Stats
              _buildAchievementStats(achievements),
              const SizedBox(height: 20),
              
              // Achievements Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _buildAchievementCard(achievement);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementStats(List<Map<String, dynamic>> achievements) {
    final unlocked = achievements.where((a) => a['unlocked'] == true).length;
    final total = achievements.length;
    final progress = total > 0 ? (unlocked / total) : 0.0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement Progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlocked/$total achievements unlocked',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DashboardColors.safeGrey(600),
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: DashboardColors.safeGrey(300),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: DashboardColors.safeGrey(300),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final unlocked = achievement['unlocked'] as bool;
    final progress = DashboardColors.safeDouble(achievement['progress']);
    
    return Card(
      elevation: 2,
      color: unlocked ? DashboardColors.safeGreen(50) : DashboardColors.safeGrey(50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: unlocked ? DashboardColors.primaryGreen : DashboardColors.primaryGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getAchievementIcon(achievement['icon'] as String),
                    color: DashboardColors.primaryWhite,
                    size: 16,
                  ),
                ),
                const Spacer(),
                if (unlocked)
                  const Icon(Icons.verified, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement['title'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              achievement['description'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: DashboardColors.safeGrey(600),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (!unlocked) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: DashboardColors.safeGrey(300),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}% complete',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: DashboardColors.safeGrey(600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper Methods
  Widget _buildErrorWidget(NGODashboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DashboardColors.safeRed(300),
            ),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DashboardColors.safeGrey(700),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.refreshData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: DashboardColors.safeGrey(400),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DashboardColors.safeGrey(500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return DashboardColors.statusUpcoming;
      case 'ongoing':
        return DashboardColors.statusOngoing;
      case 'completed':
        return DashboardColors.statusCompleted;
      case 'cancelled':
        return DashboardColors.statusCancelled;
      default:
        return DashboardColors.primaryGrey;
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return DashboardColors.tierPlatinum;
      case 'gold':
        return DashboardColors.tierGold;
      case 'silver':
        return DashboardColors.tierSilver;
      case 'bronze':
        return DashboardColors.tierBronze;
      default:
        return DashboardColors.primaryGrey;
    }
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'event':
        return Icons.event;
      case 'event_available':
        return Icons.event_available;
      case 'groups':
        return Icons.groups;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'eco':
        return Icons.eco;
      case 'handshake':
        return Icons.handshake;
      case 'attach_money':
        return Icons.attach_money;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'leaderboard':
        return Icons.leaderboard;
      case 'military_tech':
        return Icons.military_tech;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatLabel(String label) {
    return label.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  double _calculateEngagementRate(NGODashboardProvider provider) {
    final totalCapacity = provider.events.fold<int>(0, (sum, event) => sum + event.maxParticipants);
    return totalCapacity > 0 ? (provider.totalParticipants / totalCapacity * 100) : 0.0;
  }

  // Action methods for upcoming features
  void _showPendingItemsManagement() {
    // Implementation for pending items management
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Items Management'),
        content: const Text('Full pending items management interface would appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportReview(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${report.title ?? report.typeDisplay}'),
            const SizedBox(height: 8),
            Text('Description: ${report.description}'),
            const SizedBox(height: 8),
            Text('Location: ${report.displayLocation}'),
            const SizedBox(height: 8),
            Text('Submitted: ${_formatDate(report.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<NGODashboardProvider>(context, listen: false);
              provider.approveReport(report.reportId);
              Navigator.pop(context);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _approveSponsorship(SponsorshipModel sponsorship) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Sponsorship'),
        content: Text('Approve sponsorship of \$${sponsorship.amount} from ${sponsorship.sponsorId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<NGODashboardProvider>(context, listen: false);
              provider.updateSponsorshipStatus(sponsorship.sponsorshipId, 'approved');
              Navigator.pop(context);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _editEvent(EventModel event) {
    // Implementation for event editing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: const Text('Event editing interface would appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _manageEvent(EventModel event) {
    // Implementation for event management
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Event'),
        content: const Text('Event management interface would appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editSponsor(SponsorModel sponsor) {
    // Implementation for sponsor editing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Sponsor'),
        content: const Text('Sponsor editing interface would appear here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewSponsorDetails(SponsorModel sponsor) {
    // Implementation for sponsor details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sponsor Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${sponsor.name}'),
            const SizedBox(height: 8),
            Text('Email: ${sponsor.contactEmail}'),
            const SizedBox(height: 8),
            Text('Tier: ${sponsor.tier}'),
            const SizedBox(height: 8),
            Text('Contribution: \$${sponsor.totalContribution.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}