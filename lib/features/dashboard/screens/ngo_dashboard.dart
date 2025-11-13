import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';
import 'package:urban_green_mapper/core/models/sponsor_model.dart';
import 'package:urban_green_mapper/core/models/sponsorship_model.dart';
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/create_event_dialog.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/report_generator_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/sponsors_management_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/volunteer_invitation_screen.dart';
import 'package:urban_green_mapper/features/dashboard/widgets/analytics_dashboard.dart';
import 'package:urban_green_mapper/features/dashboard/utils/dashboard_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_green_mapper/core/services/database_service.dart';

// Dashboard color constants moved to `utils/dashboard_colors.dart`

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
          // Notifications quick access
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
          // User menu: profile, security, logout
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showProfileEditor();
                  break;
                case 'notifications':
                  _showNotifications();
                  break;
                case 'security':
                  _showSecuritySettings();
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(children: [const Icon(Icons.person, size: 18), const SizedBox(width: 8), Expanded(child: Text('Profile'))]),
                ),
                const PopupMenuItem<String>(
                  value: 'notifications',
                  child: Row(children: [Icon(Icons.notifications, size: 18), SizedBox(width: 8), Text('Notifications')]),
                ),
                const PopupMenuItem<String>(
                  value: 'security',
                  child: Row(children: [Icon(Icons.lock, size: 18), SizedBox(width: 8), Text('Security')]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Logout')]),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: DashboardColors.safeGreen(700),
                child: Text(
                  Provider.of<AuthProvider>(context, listen: false).user?.name.trim().isNotEmpty == true
                      ? Provider.of<AuthProvider>(context, listen: false).user!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
        content: StatefulBuilder(
          builder: (context, setState) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final ngoId = authProvider.user?.userId ?? '';
            bool enableNotifications = false;
            bool autoApproveSponsors = false;
            String theme = 'system';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('dashboard_settings').doc(ngoId).get(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                }

                if (snap.hasData && snap.data != null && snap.data!.exists) {
                  final data = snap.data!.data() as Map<String, dynamic>;
                  enableNotifications = data['enableNotifications'] ?? false;
                  autoApproveSponsors = data['autoApproveSponsors'] ?? false;
                  theme = data['theme'] ?? 'system';
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Enable notifications'),
                      value: enableNotifications,
                      onChanged: (v) => setState(() => enableNotifications = v),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-approve sponsors'),
                      value: autoApproveSponsors,
                      onChanged: (v) => setState(() => autoApproveSponsors = v),
                    ),
                    ListTile(
                      title: const Text('Theme'),
                      trailing: DropdownButton<String>(
                        value: theme,
                        items: const [
                          DropdownMenuItem(value: 'system', child: Text('System')),
                          DropdownMenuItem(value: 'light', child: Text('Light')),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        ],
                        onChanged: (v) => setState(() { if (v != null) theme = v; }),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance.collection('dashboard_settings').doc(ngoId).set({
                            'enableNotifications': enableNotifications,
                            'autoApproveSponsors': autoApproveSponsors,
                            'theme': theme,
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                          if (mounted) Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings: $e')));
                        }
                      },
                      child: const Text('Save'),
                    )
                  ],
                );
              },
            );
          },
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

        return RefreshIndicator(
          onRefresh: () => provider.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsOverview(provider),
                const SizedBox(height: 12),
                _buildQuickStatsGrid(provider),
                const SizedBox(height: 12),
                _buildEngagementCards(provider),
                const SizedBox(height: 12),
                _buildRecentActivity(provider),
                const SizedBox(height: 12),
                _buildUpcomingEvents(provider),
                const SizedBox(height: 12),
                _buildPendingActions(provider),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsOverview(NGODashboardProvider provider) {
    // Responsive statistics overview: adjusts column count based on available width
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int columns = 1;
            if (width > 900) columns = 3;
            else if (width > 600) columns = 2;

            final items = [
              {'title': 'Active Events', 'value': provider.activeEvents.toString(), 'icon': Icons.event, 'color': DashboardColors.primaryBlue},
              {'title': 'Participants', 'value': provider.totalParticipants.toString(), 'icon': Icons.people, 'color': DashboardColors.primaryGreen},
              {'title': 'Completed', 'value': provider.completedProjects.toString(), 'icon': Icons.check_circle, 'color': DashboardColors.primaryOrange},
              {'title': 'Community', 'value': provider.communityMembers.toString(), 'icon': Icons.group, 'color': DashboardColors.primaryPurple},
              {'title': 'Volunteer Hrs', 'value': provider.volunteerHours.toString(), 'icon': Icons.access_time, 'color': DashboardColors.primaryTeal},
              {'title': 'Sponsors', 'value': provider.partnerSponsors.toString(), 'icon': Icons.handshake, 'color': DashboardColors.primaryIndigo},
              {'title': 'Pending', 'value': provider.pendingReportsCount.toString(), 'icon': Icons.report, 'color': DashboardColors.primaryRed},
              {'title': 'Budget', 'value': '\$${provider.totalBudget.toStringAsFixed(0)}', 'icon': Icons.attach_money, 'color': DashboardColors.primaryGreen},
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DashboardColors.safeGreen(800),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: items.map((it) {
                    final w = (width - (12 * (columns - 1))) / columns;
                    return SizedBox(
                      width: w.clamp(220.0, width),
                      child: _buildStatCard(it['title'] as String, it['value'] as String, it['icon'] as IconData, it['color'] as Color),
                    );
                  }).toList(),
                ),
              ],
            );
          },
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

  Widget _buildEngagementCards(NGODashboardProvider provider) {
    return Column(
      children: [
        // Top Green Spaces Card
        FutureBuilder<List<GreenSpaceModel>>(
          future: provider.getTopNearbyGreenSpaces(limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              );
            }

            final greenSpaces = snapshot.data ?? [];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco, color: DashboardColors.primaryGreen, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Top Green Spaces',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (greenSpaces.isEmpty)
                      _buildEmptyState('No green spaces found', Icons.landscape)
                    else
                      Column(
                        children: greenSpaces.map((space) {
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
                                    color: DashboardColors.withOpacity(DashboardColors.primaryGreen, 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    _getGreenSpaceIcon(space.type),
                                    color: DashboardColors.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        space.name,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${space.type} • ${space.statusText}',
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
                                    color: DashboardColors.withOpacity(_getHealthColor(space.status), 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${space.biodiversityIndex.toStringAsFixed(1)}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _getHealthColor(space.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Notifications Card
        StreamBuilder<int>(
          stream: provider.getUnreadNotificationsStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: DashboardColors.withOpacity(DashboardColors.primaryOrange, 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: DashboardColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: DashboardColors.primaryRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unreadCount == 0
                                ? 'All caught up!'
                                : 'You have $unreadCount unread message${unreadCount != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: DashboardColors.safeGrey(600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: DashboardColors.safeGrey(400),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getGreenSpaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'park':
        return Icons.park;
      case 'garden':
        return Icons.grass;
      case 'forest':
        return Icons.forest;
      case 'wetland':
        return Icons.water;
      default:
        return Icons.eco;
    }
  }

  Color _getHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return DashboardColors.primaryGreen;
      case 'restored':
        return DashboardColors.primaryTeal;
      case 'degraded':
        return DashboardColors.primaryOrange;
      case 'critical':
        return DashboardColors.primaryRed;
      default:
        return DashboardColors.safeGrey(500);
    }
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
              // Mobile Analytics Cards (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int columns = 1;
                  if (width > 1000) columns = 3;
                  else if (width > 700) columns = 2;
                  final gap = 12.0;
                  final cardWidth = (width - (gap * (columns - 1))) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: mobileCards.map((card) {
                      return SizedBox(
                        width: cardWidth.clamp(240.0, 480.0),
                        child: _buildAnalyticsCard(card),
                      );
                    }).toList(),
                  );
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
    
    // Colorful card with soft gradient for better mobile visuals
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboard()));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [DashboardColors.withOpacity(color, 0.12), DashboardColors.withOpacity(color, 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DashboardColors.withOpacity(color, 0.18)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DashboardColors.withOpacity(color, 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.pie_chart, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card['title'] as String,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...data.entries.map((entry) => _buildAnalyticsCardItem(entry.key, entry.value.toString())),
            const SizedBox(height: 8),
            // Small visual summary (mini-chart)
            Row(
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: _buildMiniChart(data.cast<String, dynamic>()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: DashboardColors.withOpacity(color, 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${entrySummary(data)}', style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              ],
            ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final title = _capitalize(data['type'] as String? ?? 'Analytics');
            // Prefer an explicit metrics map if present
            final metrics = (data['metrics'] as Map<String, dynamic>?) ?? (data['values'] as Map<String, dynamic>?) ?? data;

            Widget metricsList() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: metrics.entries.take(8).map((entry) {
                      return _buildSummaryItem(entry.key, entry.value);
                    }).toList(),
                  ),
                ],
              );
            }

            Widget rightPanel() {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DashboardColors.safeGrey(50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DashboardColors.safeGrey(200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: isWide ? 220 : 160,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          entrySummary(metrics),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: DashboardColors.safeGrey(600)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: metrics list
                  Expanded(child: metricsList()),
                  const SizedBox(width: 16),
                  // Right: compact chart/overview
                  SizedBox(width: 340, child: rightPanel()),
                ],
              );
            }

            // Narrow screens: stack vertically
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                metricsList(),
                const SizedBox(height: 12),
                rightPanel(),
              ],
            );
          },
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

  // Small helper to create a compact summary for analytics card placeholder
  String entrySummary(Map<String, dynamic> data) {
    try {
      final nums = data.values.where((v) => v is num).cast<num>().toList();
      if (nums.isNotEmpty) {
        final sum = nums.fold<num>(0, (a, b) => a + b);
        return 'Total: ${sum.toString()}';
      }
      return '${data.length} metrics';
    } catch (_) {
      return '';
    }
  }

  /// Build a small mini-chart (pie or bar) for compact analytics previews
  Widget _buildMiniChart(Map<String, dynamic> metrics) {
    // Simple heuristic: if keys are status-like, show pie; if tier-like, show bars
    final keys = metrics.keys.map((k) => k.toString().toLowerCase()).toSet();
    final statusKeys = {'upcoming', 'ongoing', 'completed', 'cancelled', 'in_progress'};
    final tierKeys = {'bronze', 'silver', 'gold', 'platinum'};

    if (keys.intersection(statusKeys).isNotEmpty) {
      final sections = <PieChartSectionData>[];
      metrics.forEach((k, v) {
        final count = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
        if (count <= 0) return;
        Color color;
        switch (k.toLowerCase()) {
          case 'upcoming':
            color = DashboardColors.statusUpcoming;
            break;
          case 'ongoing':
            color = DashboardColors.statusOngoing;
            break;
          case 'completed':
            color = DashboardColors.statusCompleted;
            break;
          case 'cancelled':
            color = DashboardColors.statusCancelled;
            break;
          default:
            color = DashboardColors.safeGrey(400);
        }
        sections.add(PieChartSectionData(value: count, color: color, radius: 12, showTitle: false));
      });

      if (sections.isEmpty) return const SizedBox.shrink();
      return PieChart(PieChartData(sections: sections, centerSpaceRadius: 6, sectionsSpace: 2));
    }

    if (keys.intersection(tierKeys).isNotEmpty) {
      return _buildMiniBar(metrics);
    }

    // Default: small pie from first 3 numeric entries
    final sections = <PieChartSectionData>[];
    for (final e in metrics.entries.take(3)) {
      final count = (e.value is num) ? (e.value as num).toDouble() : double.tryParse(e.value.toString()) ?? 0.0;
      if (count <= 0) continue;
      sections.add(PieChartSectionData(value: count, color: DashboardColors.primaryBlue, radius: 12, showTitle: false));
    }
    if (sections.isEmpty) return const SizedBox.shrink();
    return PieChart(PieChartData(sections: sections, centerSpaceRadius: 6, sectionsSpace: 2));
  }

  Widget _buildMiniBar(Map<String, dynamic> metrics) {
    final entries = metrics.entries.where((e) => (e.value is num) || double.tryParse(e.value.toString()) != null).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final value = (e.value is num) ? (e.value as num).toDouble() : double.tryParse(e.value.toString()) ?? 0.0;
      barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: value, color: _miniBarColor(e.key), width: 6)]));
    }

    return SizedBox(
      height: 48,
      width: 48.0 * entries.length.clamp(1, 4),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          barGroups: barGroups,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Color _miniBarColor(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('gold')) return DashboardColors.tierGold;
    if (lower.contains('silver')) return DashboardColors.tierSilver;
    if (lower.contains('bronze')) return DashboardColors.tierBronze;
    if (lower.contains('platinum')) return DashboardColors.tierPlatinum;
    return DashboardColors.primaryTeal;
  }

  // Action methods for upcoming features
  void _showPendingItemsManagement() {
    final provider = Provider.of<NGODashboardProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (context, ctl) => Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Pending Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    const Text('Pending Reports', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (provider.pendingReports.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text('No pending reports')),
                    for (final r in provider.pendingReports)
                      Card(
                        child: ListTile(
                          title: Text(r.title ?? r.typeDisplay),
                          subtitle: Text('By ${r.userName ?? r.userId} • ${_formatDate(r.createdAt)}'),
                          trailing: Wrap(spacing: 8, children: [
                            ElevatedButton(onPressed: () async { await provider.approveReport(r.reportId); }, child: const Text('Approve')),
                            OutlinedButton(onPressed: () async { await provider.rejectReport(r.reportId, 'Rejected'); }, child: const Text('Reject')),
                          ]),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text('Pending Sponsorships', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (provider.pendingSponsorships.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text('No pending sponsorships')),
                    for (final s in provider.pendingSponsorships)
                      Card(
                        child: ListTile(
                          title: Text('${s.sponsorId} sponsorship'),
                          subtitle: Text('Event: ${s.eventId} • Amount: ${s.amount}'),
                          trailing: Wrap(spacing: 8, children: [
                            ElevatedButton(onPressed: () async { await provider.updateSponsorshipStatus(s.sponsorshipId, 'approved'); }, child: const Text('Approve')),
                            OutlinedButton(onPressed: () async { await provider.updateSponsorshipStatus(s.sponsorshipId, 'rejected', rejectionReason: 'Not suitable'); }, child: const Text('Reject')),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    final locationController = TextEditingController(text: event.location);
    final maxController = TextEditingController(text: event.maxParticipants.toString());
    DateTime selectedDate = event.startTime;
    String status = event.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                TextField(controller: maxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Participants')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Start: ${_formatDate(selectedDate)} ${_formatTime(selectedDate)}')),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                        if (d != null) {
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDate));
                          if (t != null) {
                            setState(() => selectedDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                          }
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() { if (v != null) status = v; }),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final db = DatabaseService();
                  final data = {
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'location': locationController.text.trim(),
                    'startTime': Timestamp.fromDate(selectedDate),
                    'maxParticipants': int.tryParse(maxController.text) ?? event.maxParticipants,
                    'status': status,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  await db.updateEvent(event.eventId, data);
                  final provider = Provider.of<NGODashboardProvider>(context, listen: false);
                  await provider.refreshData();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update event: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
    final nameController = TextEditingController(text: sponsor.name);
    final tierController = TextEditingController(text: sponsor.tier);
  final emailController = TextEditingController(text: sponsor.contactEmail);
    bool isActive = sponsor.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Sponsor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: tierController, decoration: const InputDecoration(labelText: 'Tier')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Contact Email')),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final db = DatabaseService();
                  final data = {
                    'name': nameController.text.trim(),
                    'tier': tierController.text.trim(),
                    'contactEmail': emailController.text.trim(),
                    'isActive': isActive,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  await db.updateSponsor(sponsor.sponsorId, data);
                  final provider = Provider.of<NGODashboardProvider>(context, listen: false);
                  await provider.refreshData();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update sponsor: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
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

  // --- Account / Notifications / Security UI ---
  void _showNotifications() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.userId;

    if (userId == null || userId.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notifications'),
          content: const Text('Not signed in'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('user_id', isEqualTo: userId)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Padding(padding: EdgeInsets.all(8.0), child: Text('No notifications'));
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snap.data!.docs[index];
                  final map = doc.data() as Map<String, dynamic>;
                  final title = map['title'] ?? '';
                  final message = map['message'] ?? '';
                  final isRead = map['is_read'] ?? false;
                  final ts = map['created_at'] as Timestamp?;
                  final time = ts != null ? _formatDate(ts.toDate()) : '';

                  return ListTile(
                    leading: Icon(isRead ? Icons.mark_email_read : Icons.mark_email_unread, color: isRead ? Colors.green : Colors.orange),
                    title: Text(title),
                    subtitle: Text('$message\n$time'),
                    isThreeLine: true,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('notifications').doc(doc.id).delete();
                          },
                        ),
                        IconButton(
                          icon: Icon(isRead ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('notifications').doc(doc.id).set({'is_read': !isRead}, SetOptions(merge: true));
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showProfileEditor() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final nameController = TextEditingController(text: user?.name ?? '');
  final photoController = TextEditingController(text: user?.profilePicture ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Display name')),
                TextField(controller: photoController, decoration: const InputDecoration(labelText: 'Photo URL')),
                const SizedBox(height: 8),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email (requires reauth)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final displayName = nameController.text.trim();
                  final photo = photoController.text.trim();
                  final newEmail = emailController.text.trim();

                  await authProvider.updateUserProfile(displayName: displayName.isEmpty ? null : displayName, photoURL: photo.isEmpty ? null : photo);
                  if (newEmail.isNotEmpty && newEmail != user?.email) {
                    await authProvider.updateEmail(newEmail);
                  }
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecuritySettings() {
  final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Security'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final newPass = newPasswordController.text.trim();
                    if (newPass.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
                      return;
                    }
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final ok = await authProvider.updatePassword(newPass);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated')));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update password')));
                    }
                  },
                  child: const Text('Change Password'),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete account'),
                        content: const Text('This will permanently delete your account and data. Are you sure?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.white))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      final ok = await authProvider.deleteAccount();
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
                        if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
                      }
                    }
                  },
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      ),
    );
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ok = await authProvider.logout();
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to logout')));
    }
  }
}

// Custom painter removed in favor of fl_chart components