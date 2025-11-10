// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/admin_dashboard_provider.dart';
import 'package:urban_green_mapper/features/profile/screens/profile_screen.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const AdminDashboardHome(),
    const SystemManagementScreen(),
    const UserManagementScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showAdminNotifications(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              _showSecuritySettings(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _widgetOptions.elementAt(_selectedIndex),
        tablet: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.red[50],
              selectedLabelTextStyle: const TextStyle(color: Colors.red),
              selectedIconTheme: const IconThemeData(color: Colors.red),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('System'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
          ],
        ),
        desktop: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.red[50],
              selectedLabelTextStyle: const TextStyle(color: Colors.red),
              selectedIconTheme: const IconThemeData(color: Colors.red),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('System'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
          ],
        ),
      ),
      bottomNavigationBar: ResponsiveLayout(
        mobile: _buildMobileBottomNavigationBar(),
        tablet: const SizedBox.shrink(),
        desktop: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMobileBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red[700]!,
            Colors.red[600]!,
            Colors.red[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.white),
            activeIcon: Icon(Icons.dashboard, color: Colors.yellow),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            activeIcon: Icon(Icons.settings, color: Colors.yellow),
            label: 'System',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.white),
            activeIcon: Icon(Icons.people, color: Colors.yellow),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            activeIcon: Icon(Icons.person, color: Colors.yellow),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        onTap: _onItemTapped,
      ),
    );
  }

  void _showAdminNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildNotificationItem('System Update', 'New system update available for installation', Icons.system_update, Colors.blue),
              _buildNotificationItem('Security Alert', 'Unusual login activity detected', Icons.security, Colors.orange),
              _buildNotificationItem('Backup Complete', 'Daily backup completed successfully', Icons.backup, Colors.green),
              _buildNotificationItem('Storage Warning', 'Storage usage at 85% capacity', Icons.storage, Colors.red),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 16),
        onPressed: () {},
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
    );
  }
}

class AdminDashboardHome extends StatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  State<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends State<AdminDashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return RefreshIndicator(
      onRefresh: () => dashboardProvider.refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(user, dashboardProvider),
          tablet: _buildTabletLayout(user, dashboardProvider),
          desktop: _buildDesktopLayout(user, dashboardProvider),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(dynamic user, AdminDashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user),
        const SizedBox(height: 20),
        _buildSystemStatsSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildUserManagementSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildModerationSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildQuickActions(context),
        const SizedBox(height: 16),
        _buildRecentActivitySection(dashboardProvider),
        const SizedBox(height: 16),
        _buildSystemHealthSection(dashboardProvider),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabletLayout(dynamic user, AdminDashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user),
        const SizedBox(height: 24),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          children: [
            _buildSystemStatsSection(dashboardProvider),
            _buildUserManagementSection(dashboardProvider),
          ],
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
          ),
          children: [
            _buildModerationSection(dashboardProvider),
            _buildSystemHealthSection(dashboardProvider),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickActions(context),
        const SizedBox(height: 16),
        _buildRecentActivitySection(dashboardProvider),
      ],
    );
  }

  Widget _buildDesktopLayout(dynamic user, AdminDashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user),
        const SizedBox(height: 24),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          children: [
            _buildSystemStatsSection(dashboardProvider),
            _buildUserManagementSection(dashboardProvider),
            _buildModerationSection(dashboardProvider),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickActions(context),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          children: [
            _buildRecentActivitySection(dashboardProvider),
            _buildSystemHealthSection(dashboardProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(dynamic user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Administration',
              style: AppTheme.textTheme.headlineSmall?.copyWith(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome, ${user?.name ?? 'Administrator'}. Monitor and manage the Urban Green Mapper platform.',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Last updated: ${_formatTime(DateTime.now())}',
                  style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatsSection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Platform Statistics',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 200;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isSmall ? 2 : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: isSmall ? 0.8 : 1.2,
                    children: [
                      _buildStatItem(
                        value: dashboardProvider.totalUsers.toString(),
                        label: 'Total Users',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        value: dashboardProvider.totalReports.toString(),
                        label: 'Reports',
                        icon: Icons.assignment,
                        color: Colors.orange,
                      ),
                      _buildStatItem(
                        value: dashboardProvider.totalEvents.toString(),
                        label: 'Events',
                        icon: Icons.event,
                        color: Colors.green,
                      ),
                      if (!isSmall) _buildStatItem(
                        value: dashboardProvider.activeNGOs.toString(),
                        label: 'NGOs',
                        icon: Icons.business,
                        color: Colors.purple,
                      ),
                      if (!isSmall) _buildStatItem(
                        value: dashboardProvider.totalSponsors.toString(),
                        label: 'Sponsors',
                        icon: Icons.attach_money,
                        color: Colors.teal,
                      ),
                      if (!isSmall) _buildStatItem(
                        value: dashboardProvider.greenSpacesCount.toString(),
                        label: 'Green Spaces',
                        icon: Icons.park,
                        color: Colors.green,
                      ),
                      if (!isSmall) _buildStatItem(
                        value: dashboardProvider.totalPlants.toString(),
                        label: 'Total Plants',
                        icon: Icons.eco,
                        color: Colors.lightGreen,
                      ),
                      if (!isSmall) _buildStatItem(
                        value: dashboardProvider.adoptedPlants.toString(),
                        label: 'Adopted Plants',
                        icon: Icons.favorite,
                        color: Colors.pink,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementSection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'User Management',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildUserManagementItem(
                    label: 'Pending Verifications',
                    value: dashboardProvider.pendingVerifications.toString(),
                    color: Colors.orange,
                    onTap: () => _showPendingVerifications(context, dashboardProvider),
                  ),
                  _buildUserManagementItem(
                    label: 'Reported Users',
                    value: dashboardProvider.reportedUsers.toString(),
                    color: Colors.red,
                    onTap: () => _showReportedUsers(context, dashboardProvider),
                  ),
                  _buildUserManagementItem(
                    label: 'New Registrations (24h)',
                    value: dashboardProvider.newRegistrations.toString(),
                    color: Colors.blue,
                    onTap: () => _showRecentRegistrations(context, dashboardProvider),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationSection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  'Content Moderation',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildModerationItem(
                    label: 'Pending Reports',
                    value: dashboardProvider.pendingReports.toString(),
                    color: Colors.orange,
                    onTap: () => _showPendingReports(context, dashboardProvider),
                  ),
                  _buildModerationItem(
                    label: 'Flagged Content',
                    value: dashboardProvider.flaggedContent.toString(),
                    color: Colors.red,
                    onTap: () => _showFlaggedContent(context, dashboardProvider),
                  ),
                  _buildModerationItem(
                    label: 'Spam Detected',
                    value: dashboardProvider.spamCount.toString(),
                    color: Colors.purple,
                    onTap: () => _showSpamContent(context, dashboardProvider),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required IconData icon, required Color color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildUserManagementItem({required String label, required String value, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        label,
        style: AppTheme.textTheme.bodyMedium,
      ),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildModerationItem({required String label, required String value, required Color color, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_red_eye, size: 18, color: color),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administrative Actions',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 300;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAdminActionButton(
                      icon: Icons.verified_user,
                      label: 'User Verification',
                      onPressed: () => _showUserVerification(context),
                      color: Colors.blue,
                      isSmall: isSmall,
                    ),
                    _buildAdminActionButton(
                      icon: Icons.report_problem,
                      label: 'Content Moderation',
                      onPressed: () => _showContentModeration(context),
                      color: Colors.orange,
                      isSmall: isSmall,
                    ),
                    _buildAdminActionButton(
                      icon: Icons.settings,
                      label: 'System Settings',
                      onPressed: () => _showSystemSettings(context),
                      color: Colors.green,
                      isSmall: isSmall,
                    ),
                    _buildAdminActionButton(
                      icon: Icons.backup,
                      label: 'Database Backup',
                      onPressed: () => _performBackup(context),
                      color: Colors.purple,
                      isSmall: isSmall,
                    ),
                    if (!isSmall) _buildAdminActionButton(
                      icon: Icons.analytics,
                      label: 'Platform Analytics',
                      onPressed: () => _showPlatformAnalytics(context),
                      color: Colors.teal,
                      isSmall: isSmall,
                    ),
                    if (!isSmall) _buildAdminActionButton(
                      icon: Icons.security,
                      label: 'Security Audit',
                      onPressed: () => _runSecurityAudit(context),
                      color: Colors.red,
                      isSmall: isSmall,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color, bool isSmall = false}) {
    return SizedBox(
      width: isSmall ? 140 : 160,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: isSmall ? 11 : 12,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent System Activity',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).loadDashboardData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardProvider.recentActivity.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: dashboardProvider.recentActivity
                    .take(5)
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              ),
            if (dashboardProvider.recentActivity.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showAllActivities(context, dashboardProvider);
                    },
                    child: const Text('View All Activities'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getActivityColor(activity['type']).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getActivityIcon(activity['type']),
          color: _getActivityColor(activity['type']),
          size: 16,
        ),
      ),
      title: Text(
        activity['description'] ?? 'Unknown activity',
        style: AppTheme.textTheme.bodyMedium?.copyWith(fontSize: 13),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        activity['formatted_time'] ?? 'Unknown time',
        style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, size: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      visualDensity: VisualDensity.compact,
      onTap: () {
        _showActivityDetails(context, activity);
      },
    );
  }

  Widget _buildSystemHealthSection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  _buildHealthIndicator(
                    label: 'Server Status',
                    status: dashboardProvider.serverStatus,
                    value: '${dashboardProvider.databasePerformance}%',
                  ),
                  _buildHealthIndicator(
                    label: 'Database Performance',
                    status: 'optimal',
                    value: '${dashboardProvider.databasePerformance}%',
                  ),
                  _buildHealthIndicator(
                    label: 'API Response Time',
                    status: _getApiStatus(dashboardProvider.apiResponseTime),
                    value: '${dashboardProvider.apiResponseTime}ms',
                  ),
                  _buildHealthIndicator(
                    label: 'Storage Usage',
                    status: _getStorageStatus(dashboardProvider.storageUsage),
                    value: '${dashboardProvider.storageUsage}%',
                  ),
                  _buildHealthIndicator(
                    label: 'CPU Usage',
                    status: _getCpuStatus(dashboardProvider.cpuUsage),
                    value: '${dashboardProvider.cpuUsage}%',
                  ),
                  _buildHealthIndicator(
                    label: 'Memory Usage',
                    status: _getMemoryStatus(dashboardProvider.memoryUsage),
                    value: '${dashboardProvider.memoryUsage}%',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () {
                        Provider.of<AdminDashboardProvider>(context, listen: false).runSystemDiagnostics();
                      },
                      child: const Text('Run System Diagnostics'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator({required String label, required String status, required String value}) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    
    switch (status) {
      case 'optimal':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'good':
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for activity items
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_registration':
        return Icons.person_add;
      case 'report_submission':
        return Icons.assignment;
      case 'event_creation':
        return Icons.event;
      case 'system_alert':
        return Icons.warning;
      case 'moderation_action':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_registration':
        return Colors.blue;
      case 'report_submission':
        return Colors.orange;
      case 'event_creation':
        return Colors.green;
      case 'system_alert':
        return Colors.red;
      case 'moderation_action':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getApiStatus(int responseTime) {
    if (responseTime < 50) return 'optimal';
    if (responseTime < 100) return 'good';
    if (responseTime < 200) return 'warning';
    return 'critical';
  }

  String _getStorageStatus(double usage) {
    if (usage < 70) return 'optimal';
    if (usage < 85) return 'warning';
    return 'critical';
  }

  String _getCpuStatus(double usage) {
    if (usage < 60) return 'optimal';
    if (usage < 80) return 'warning';
    return 'critical';
  }

  String _getMemoryStatus(double usage) {
    if (usage < 70) return 'optimal';
    if (usage < 85) return 'warning';
    return 'critical';
  }

  // Administrative action methods
  void _showUserVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserVerificationScreen(),
      ),
    );
  }

  void _showContentModeration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContentModerationScreen(),
      ),
    );
  }

  void _showSystemSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SystemSettingsScreen()),
    );
  }

  void _performBackup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Backup'),
        content: const Text('Create a backup of the system database? This may take several minutes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false)
                    .exportSystemData('full_backup');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup initiated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Start Backup'),
          ),
        ],
      ),
    );
  }

  void _showPlatformAnalytics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlatformAnalyticsScreen()),
    );
  }

  void _runSecurityAudit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Audit'),
        content: const Text('Run comprehensive security audit and vulnerability assessment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security audit initiated')),
              );
            },
            child: const Text('Run Audit'),
          ),
        ],
      ),
    );
  }

  void _showPendingVerifications(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserVerificationScreen(),
      ),
    );
  }

  void _showReportedUsers(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportedUsersScreen(),
      ),
    );
  }

  void _showRecentRegistrations(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecentRegistrationsScreen()),
    );
  }

  void _showPendingReports(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContentModerationScreen(),
      ),
    );
  }

  void _showFlaggedContent(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FlaggedContentScreen()),
    );
  }

  void _showSpamContent(BuildContext context, AdminDashboardProvider dashboardProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SpamContentScreen()),
    );
  }

  void _showActivityDetails(BuildContext context, Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${activity['formatted_time']}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (activity['user_id'] != null)
              Text(
                'User ID: ${activity['user_id']}',
                style: const TextStyle(color: Colors.grey),
              ),
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

  void _showAllActivities(BuildContext context, AdminDashboardProvider dashboardProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All System Activities'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dashboardProvider.recentActivity.length,
            itemBuilder: (context, index) {
              final activity = dashboardProvider.recentActivity[index];
              return _buildActivityItem(activity);
            },
          ),
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

// System Management Screen
class SystemManagementScreen extends StatelessWidget {
  const SystemManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemMetricsSection(dashboardProvider),
            const SizedBox(height: 20),
            _buildMaintenanceActions(context),
            const SizedBox(height: 20),
            _buildDatabaseManagement(context),
            const SizedBox(height: 20),
            _buildSystemLogs(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetricsSection(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Metrics',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildMetricItem('Uptime', dashboardProvider.systemMetrics['uptime'] ?? 'N/A', Icons.timer, Colors.green),
                  _buildMetricItem('Error Rate', dashboardProvider.systemMetrics['error_rate'] ?? 'N/A', Icons.error, Colors.orange),
                  _buildMetricItem('Active Sessions', dashboardProvider.systemMetrics['active_sessions']?.toString() ?? 'N/A', Icons.people, Colors.blue),
                  _buildMetricItem('Database Size', dashboardProvider.systemMetrics['database_size'] ?? 'N/A', Icons.storage, Colors.purple),
                  _buildMetricItem('Cache Hit Rate', dashboardProvider.systemMetrics['cache_hit_rate'] ?? 'N/A', Icons.cached, Colors.teal),
                  _buildMetricItem('Queue Length', dashboardProvider.systemMetrics['queue_length']?.toString() ?? 'N/A', Icons.queue, Colors.red),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Actions',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildMaintenanceButton(
                  'Run Diagnostics',
                  Icons.medical_services,
                  Colors.blue,
                      () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).runSystemDiagnostics();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System diagnostics started')),
                    );
                  },
                ),
                _buildMaintenanceButton(
                  'System Maintenance',
                  Icons.build,
                  Colors.orange,
                      () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).runSystemMaintenance();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System maintenance started')),
                    );
                  },
                ),
                _buildMaintenanceButton(
                  'Clear Cache',
                  Icons.cached,
                  Colors.purple,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared successfully')),
                    );
                  },
                ),
                _buildMaintenanceButton(
                  'Update System',
                  Icons.system_update,
                  Colors.green,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('System update check started')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        ),
      ),
    );
  }

  Widget _buildDatabaseManagement(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Management',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildDatabaseAction(
                  'Export User Data',
                  'Export all user data to CSV',
                  Icons.import_export,
                  Colors.blue,
                      () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).exportSystemData('user_data');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User data export started')),
                    );
                  },
                ),
                _buildDatabaseAction(
                  'Export Report Data',
                  'Export all report data to CSV',
                  Icons.assignment,
                  Colors.orange,
                      () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).exportSystemData('report_data');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report data export started')),
                    );
                  },
                ),
                _buildDatabaseAction(
                  'Backup Database',
                  'Create full database backup',
                  Icons.backup,
                  Colors.green,
                      () {
                    Provider.of<AdminDashboardProvider>(context, listen: false).exportSystemData('full_backup');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database backup started')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseAction(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSystemLogs(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Logs',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs refreshed')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent system logs will appear here. Logs include system events, errors, and important notifications.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildLogItem('INFO', 'System startup completed', '2 minutes ago'),
            _buildLogItem('WARN', 'High memory usage detected', '5 minutes ago'),
            _buildLogItem('INFO', 'Database backup completed', '1 hour ago'),
            _buildLogItem('ERROR', 'Failed to send notification', '2 hours ago'),
            _buildLogItem('INFO', 'User session cleanup', '3 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String level, String message, String time) {
    Color levelColor = Colors.grey;
    switch (level) {
      case 'INFO':
        levelColor = Colors.blue;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      case 'ERROR':
        levelColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: levelColor),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: levelColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTheme.textTheme.bodyMedium,
                ),
                Text(
                  time,
                  style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// User Management Screen
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          backgroundColor: Colors.purple[700],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Users'),
              Tab(text: 'NGOs'),
              Tab(text: 'Reported'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllUsersTab(context, dashboardProvider),
            _buildNGOsTab(context, dashboardProvider),
            _buildReportedUsersTab(context, dashboardProvider),
            _buildUserAnalyticsTab(context, dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAllUsersTab(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserStats(dashboardProvider),
          const SizedBox(height: 20),
          _buildUserSearch(context),
          const SizedBox(height: 20),
          _buildUsersList(context, dashboardProvider),
        ],
      ),
    );
  }

  Widget _buildUserStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUserStatItem('Total Users', dashboardProvider.totalUsers.toString(), Icons.people, Colors.blue),
            _buildUserStatItem('Active NGOs', dashboardProvider.activeNGOs.toString(), Icons.business, Colors.green),
            _buildUserStatItem('New Today', dashboardProvider.newRegistrations.toString(), Icons.person_add, Colors.orange),
            _buildUserStatItem('Suspended', '12', Icons.block, Colors.red), // Example data
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserSearch(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search users by name, email, or ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showUserFilters(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Users',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    try {
                      final path = await dashboardProvider.exportUsers(format: value);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to: $path')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
                    PopupMenuItem(value: 'csv', child: Text('Export CSV')),
                    PopupMenuItem(value: 'json', child: Text('Export JSON')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [Icon(Icons.download, size: 16), SizedBox(width: 8), Text('Export')],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardProvider.allUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text('No users found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: dashboardProvider.allUsers.map((u) => _buildUserListItem(context, u)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, UserModel user) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    if (user.isSuspended) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
    } else if (user.isPendingVerification) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Text(user.initials),
        ),
        title: Text(user.name.isNotEmpty ? user.name : user.displayName),
        subtitle: Text('${user.email} • ${user.role} • ${user.accountStatus}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 18),
              onPressed: () => _showUserActions(context, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNGOsTab(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNGOStats(dashboardProvider),
          const SizedBox(height: 20),
          ...dashboardProvider.pendingVerificationUsers.map((user) => _buildNGOListItem(context, user)),
        ],
      ),
    );
  }

  Widget _buildNGOStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNGOStatItem('Total NGOs', dashboardProvider.activeNGOs.toString(), Icons.business, Colors.green),
            _buildNGOStatItem('Pending', dashboardProvider.pendingVerifications.toString(), Icons.pending, Colors.orange),
            _buildNGOStatItem('Verified', (dashboardProvider.activeNGOs - dashboardProvider.pendingVerifications).toString(), Icons.verified, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildNGOStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNGOListItem(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.business, color: Colors.orange[700]),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('Registered: ${_formatDate(user.createdAt)}'),
            if (user.verificationStatus == 'pending')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Pending Verification',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                // Handle verification
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                // Handle rejection
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportedUsersTab(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportedStats(dashboardProvider),
          const SizedBox(height: 20),
          ...dashboardProvider.reportedUsersList.map((user) => _buildReportedUserListItem(context, user)),
        ],
      ),
    );
  }

  Widget _buildReportedStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildReportedStatItem('Reported Users', dashboardProvider.reportedUsers.toString(), Icons.warning, Colors.orange),
            _buildReportedStatItem('Under Review', '8', Icons.visibility, Colors.blue), // Example data
            _buildReportedStatItem('Suspended', '4', Icons.block, Colors.red), // Example data
          ],
        ),
      ),
    );
  }

  Widget _buildReportedStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReportedUserListItem(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(Icons.warning, color: Colors.red[700]),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('Role: ${user.role}'),
            Text('Reports: 3'), // Example data
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () {
            _showUserDetails(context, user);
          },
        ),
      ),
    );
  }

  Widget _buildUserAnalyticsTab(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalyticsOverview(dashboardProvider),
          const SizedBox(height: 20),
          _buildUserDistribution(dashboardProvider),
          const SizedBox(height: 20),
          _buildRegistrationTrends(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Analytics Overview',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildAnalyticItem('Total Users', dashboardProvider.totalUsers.toString(), Icons.people, Colors.blue),
                _buildAnalyticItem('Active Users', dashboardProvider.userAnalytics['active_users']?.toString() ?? 'N/A', Icons.person, Colors.green),
                _buildAnalyticItem('Growth Rate', '${dashboardProvider.platformAnalytics['user_growth_rate']?.toStringAsFixed(1) ?? '0'}%', Icons.trending_up, Colors.orange),
                _buildAnalyticItem('Avg. Session', '12.4 min', Icons.timer, Colors.purple), // Example data
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDistribution(AdminDashboardProvider dashboardProvider) {
    final roleDistribution = dashboardProvider.userAnalytics['role_distribution'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Role Distribution',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...roleDistribution.entries.map((entry) => _buildDistributionItem(entry.key, entry.value.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionItem(String role, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              role.toUpperCase(),
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Text(
            count,
            style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationTrends() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registration Trends (Last 7 Days)',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User registration trends chart would be displayed here in a real implementation.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart: Daily User Registrations\n\n'
                      'Mon: 15 users\n'
                      'Tue: 22 users\n'
                      'Wed: 18 users\n'
                      'Thu: 25 users\n'
                      'Fri: 20 users\n'
                      'Sat: 12 users\n'
                      'Sun: 8 users',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserFilters(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Role', ['All', 'User', 'NGO', 'Admin']),
              _buildFilterOption('Status', ['All', 'Active', 'Pending', 'Suspended']),
              _buildFilterOption('Registration Date', ['All Time', 'Last 7 Days', 'Last 30 Days', 'Last Year']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((option) => FilterChip(
              label: Text(option),
              selected: option == 'All',
              onSelected: (bool) {},
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showUserActions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 320,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _showUserDetails(context, user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit User'),
              onTap: () {
                Navigator.pop(context);
                _showEditUserDialog(context, user);
              },
            ),
            if (!user.isSuspended)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Suspend User'),
                onTap: () {
                  Navigator.pop(context);
                  _showSuspendUserDialog(context, user.userId);
                },
              ),
            if (user.isSuspended)
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Unsuspend User'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<AdminDashboardProvider>(context, listen: false).unsuspendUser(user.userId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unsuspended successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete User'),
                    content: const Text('Are you sure you want to permanently delete this user? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await Provider.of<AdminDashboardProvider>(context, listen: false).deleteUser(user.userId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // Handle send message
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['citizen', 'ngo', 'sponsor', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (v) { if (v != null) selectedRole = v; },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email cannot be empty')));
                return;
              }
              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false).updateUser(user.userId, {
                  'name': name,
                  'email': email,
                  'role': selectedRole,
                  'updated_at': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated successfully')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserDetailItem('Name', user.name),
              _buildUserDetailItem('Email', user.email),
              _buildUserDetailItem('Role', user.role),
              _buildUserDetailItem('Status', user.verificationStatus ?? 'active'),
              _buildUserDetailItem('Registered', _formatDate(user.createdAt)),
              if (user.isSuspended)
                _buildUserDetailItem('Suspended', 'Yes (${user.suspensionReason ?? "No reason provided"})'),
            ],
          ),
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

  Widget _buildUserDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSuspendUserDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter reason for suspension:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Suspension reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false)
                    .suspendUser(userId, reasonController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User suspended successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }
}

// Additional Admin Screens
class UserVerificationScreen extends StatelessWidget {
  const UserVerificationScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Verification'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.pendingVerificationUsers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No pending verifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dashboardProvider.pendingVerificationUsers.length,
                  itemBuilder: (context, index) {
                    final user = dashboardProvider.pendingVerificationUsers[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Icon(Icons.person, color: Colors.orange[700]),
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Role: ${user.role}'),
                            Text('Registered: ${_formatDate(user.createdAt)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _showVerificationDialog(context, user.userId, 'approve');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _showVerificationDialog(context, user.userId, 'reject');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showVerificationDialog(BuildContext context, String userId, String action) {
    final reasonController = TextEditingController();
    final isReject = action == 'reject';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isReject ? 'Reject' : 'Approve'} User Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ${isReject ? 'reject' : 'approve'} this user verification?'),
            if (isReject) ...[
              const SizedBox(height: 16),
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Rejection reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isReject && reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason for rejection')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                if (isReject) {
                  await Provider.of<AdminDashboardProvider>(context, listen: false)
                      .rejectUserVerification(userId, reasonController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User verification rejected')),
                  );
                } else {
                  await Provider.of<AdminDashboardProvider>(context, listen: false)
                      .verifyUser(userId, 'NGO');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User verified successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isReject ? Colors.red : Colors.green,
            ),
            child: Text(isReject ? 'Reject' : 'Approve'),
          ),
        ],
      ),
    );
  }
}

class ContentModerationScreen extends StatelessWidget {
  const ContentModerationScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Moderation'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.pendingModerationReports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No pending reports for moderation',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dashboardProvider.pendingModerationReports.length,
                  itemBuilder: (context, index) {
                    final report = dashboardProvider.pendingModerationReports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.assignment, color: Colors.blue[700]),
                        ),
                        title: Text(report.displayTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.shortDescription,
                            ),
                            Text('Type: ${report.typeDisplay}'),
                            Text('Submitted: ${_formatDate(report.createdAt)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _showReportActionDialog(context, report.reportId, 'approve');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _showReportActionDialog(context, report.reportId, 'reject');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showReportActionDialog(BuildContext context, String reportId, String action) {
    final reasonController = TextEditingController();
    final isReject = action == 'reject';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${isReject ? 'Reject' : 'Approve'} Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ${isReject ? 'reject' : 'approve'} this report?'),
            if (isReject) ...[
              const SizedBox(height: 16),
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Rejection reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isReject && reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason for rejection')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                if (isReject) {
                  await Provider.of<AdminDashboardProvider>(context, listen: false)
                      .rejectReport(reportId, reasonController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report rejected')),
                  );
                } else {
                  await Provider.of<AdminDashboardProvider>(context, listen: false)
                      .approveReport(reportId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report approved successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isReject ? Colors.red : Colors.green,
            ),
            child: Text(isReject ? 'Reject' : 'Approve'),
          ),
        ],
      ),
    );
  }
}

class ReportedUsersScreen extends StatelessWidget {
  const ReportedUsersScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Users'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.reportedUsersList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No reported users',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dashboardProvider.reportedUsersList.length,
                  itemBuilder: (context, index) {
                    final user = dashboardProvider.reportedUsersList[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Icon(Icons.warning, color: Colors.red[700]),
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Role: ${user.role}'),
                            Text('Registered: ${_formatDate(user.createdAt)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () {
                            _showUserActionDialog(context, user.userId);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showUserActionDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Actions'),
        content: const Text('Choose an action for this reported user'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showUserDetails(context, userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('View Details'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showSuspendUserDialog(context, userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend User'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: const Text('Detailed user information and report history would be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSuspendUserDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter reason for suspension:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Suspension reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false)
                    .suspendUser(userId, reasonController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User suspended successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }
}

// New Screens for Additional Features
class RecentRegistrationsScreen extends StatelessWidget {
  const RecentRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Registrations'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRegistrationStats(dashboardProvider),
            const SizedBox(height: 20),
            _buildRecentUsersList(dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRegistrationStatItem('Last 24h', dashboardProvider.newRegistrations.toString(), Icons.today, Colors.blue),
            _buildRegistrationStatItem('Last 7 Days', '45', Icons.calendar_view_week, Colors.green), // Example data
            _buildRegistrationStatItem('Last 30 Days', '189', Icons.calendar_month, Colors.orange), // Example data
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationStatItem(String period, String count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          period,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRecentUsersList(AdminDashboardProvider dashboardProvider) {
    // In a real app, you would fetch recent users from the provider
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent User Registrations',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(8, (index) => _buildRecentUserItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUserItem(int index) {
    final users = [
      {'name': 'John Doe', 'email': 'john@example.com', 'time': '2 hours ago', 'role': 'user'},
      {'name': 'Green NGO', 'email': 'contact@green-ngo.org', 'time': '3 hours ago', 'role': 'ngo'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'time': '5 hours ago', 'role': 'user'},
      {'name': 'Eco Warriors', 'email': 'info@ecowarriors.org', 'time': '1 day ago', 'role': 'ngo'},
      {'name': 'Mike Johnson', 'email': 'mike@example.com', 'time': '1 day ago', 'role': 'user'},
      {'name': 'Nature Lovers', 'email': 'hello@naturelovers.org', 'time': '2 days ago', 'role': 'ngo'},
      {'name': 'Sarah Wilson', 'email': 'sarah@example.com', 'time': '2 days ago', 'role': 'user'},
      {'name': 'Climate Action', 'email': 'info@climateaction.org', 'time': '3 days ago', 'role': 'ngo'},
    ];

    final user = users[index];
    final isNGO = user['role'] == 'ngo';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isNGO ? Colors.green[100] : Colors.blue[100],
        child: Icon(
          isNGO ? Icons.business : Icons.person,
          color: isNGO ? Colors.green[700] : Colors.blue[700],
        ),
      ),
      title: Text(user['name']!),
      subtitle: Text('${user['email']} • ${user['time']}'),
      trailing: Chip(
        label: Text(
          user['role']!.toUpperCase(),
          style: TextStyle(
            color: isNGO ? Colors.green[700] : Colors.blue[700],
            fontSize: 10,
          ),
        ),
        backgroundColor: isNGO ? Colors.green[50] : Colors.blue[50],
      ),
    );
  }
}

class FlaggedContentScreen extends StatelessWidget {
  const FlaggedContentScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flagged Content'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.flaggedReports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No flagged content',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dashboardProvider.flaggedReports.length,
                  itemBuilder: (context, index) {
                    final report = dashboardProvider.flaggedReports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[100],
                          child: Icon(Icons.flag, color: Colors.orange[700]),
                        ),
                        title: Text(report.displayTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.shortDescription),
                            Text('Type: ${report.typeDisplay}'),
                            Text('Priority: ${report.priorityDisplay}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                _showReportDetails(context, report);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteContentDialog(context, report.reportId, 'report');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${report.displayTitle}'),
              const SizedBox(height: 8),
              Text('Description: ${report.description}'),
              const SizedBox(height: 8),
              Text('Type: ${report.typeDisplay}'),
              const SizedBox(height: 8),
              Text('Priority: ${report.priorityDisplay}'),
              const SizedBox(height: 8),
              Text('Status: ${report.statusDisplay}'),
              const SizedBox(height: 8),
              Text('Submitted: ${_formatDate(report.createdAt)}'),
              const SizedBox(height: 8),
              Text('User: ${report.displayName}'),
            ],
          ),
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

  void _showDeleteContentDialog(BuildContext context, String contentId, String contentType) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete this content?'),
            const SizedBox(height: 16),
            const Text('Please provide a reason:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Deletion reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false)
                    .deleteContent(contentId, contentType, reasonController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class SpamContentScreen extends StatelessWidget {
  const SpamContentScreen({super.key});

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spam Content'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardProvider.spamReports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.report_gmailerrorred, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No spam content detected',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: dashboardProvider.spamReports.length,
                  itemBuilder: (context, index) {
                    final report = dashboardProvider.spamReports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: Icon(Icons.report_gmailerrorred, color: Colors.purple[700]),
                        ),
                        title: Text(report.displayTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.shortDescription),
                            Text('Type: ${report.typeDisplay}'),
                            Text('Detected: ${_formatDate(report.createdAt)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _showNotSpamDialog(context, report.reportId);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteContentDialog(context, report.reportId, 'report');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showNotSpamDialog(BuildContext context, String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Not Spam'),
        content: const Text('Are you sure this content is not spam? It will be restored and available to users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // In a real app, you would have a method to mark content as not spam
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content marked as not spam')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Mark as Not Spam'),
          ),
        ],
      ),
    );
  }

  void _showDeleteContentDialog(BuildContext context, String contentId, String contentType) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spam Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete this spam content?'),
            const SizedBox(height: 16),
            const Text('Please provide a reason:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Deletion reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }

              Navigator.pop(context);
              try {
                await Provider.of<AdminDashboardProvider>(context, listen: false)
                    .deleteContent(contentId, contentType, reasonController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Spam content deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 20),
            _buildNotificationSettings(),
            const SizedBox(height: 20),
            _buildFeatureSettings(),
            const SizedBox(height: 20),
            _buildMaintenanceSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              'Allow User Registration',
              'Enable new user registration on the platform',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Enable Email Verification',
              'Require email verification for new users',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Maintenance Mode',
              'Put the platform in maintenance mode',
              false,
                  (value) {},
            ),
            _buildSettingInput(
              'Session Timeout (minutes)',
              'Auto-logout after inactivity',
              '30',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              'Email Notifications',
              'Send email notifications to users',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Push Notifications',
              'Send push notifications to mobile apps',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Admin Alerts',
              'Send system alerts to administrators',
              true,
                  (value) {},
            ),
            _buildSettingInput(
              'Alert Threshold',
              'System usage percentage for alerts',
              '80',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Settings',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingSwitch(
              'Plant Adoption',
              'Enable plant adoption feature',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Event Creation',
              'Allow users to create events',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'Report System',
              'Enable user reporting system',
              true,
                  (value) {},
            ),
            _buildSettingSwitch(
              'NGO Verification',
              'Require verification for NGOs',
              true,
                  (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSettings(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance & Updates',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<AdminDashboardProvider>(context, listen: false).runSystemMaintenance();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('System maintenance started')),
                  );
                },
                icon: const Icon(Icons.build),
                label: const Text('Run System Maintenance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Provider.of<AdminDashboardProvider>(context, listen: false).runSystemDiagnostics();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('System diagnostics started')),
                  );
                },
                icon: const Icon(Icons.medical_services),
                label: const Text('Run System Diagnostics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSystemUpdateDialog(context);
                },
                icon: const Icon(Icons.system_update),
                label: const Text('Check for Updates'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSettingInput(String label, String hint, String initialValue) {
    final controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSystemUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Update'),
        content: const Text('Your system is up to date with the latest version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PlatformAnalyticsScreen extends StatelessWidget {
  const PlatformAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Platform Analytics'),
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'User Analytics'),
              Tab(text: 'Content Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnalyticsOverview(dashboardProvider),
            _buildUserAnalyticsTab(dashboardProvider),
            _buildContentAnalyticsTab(dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverview(AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewStats(dashboardProvider),
          const SizedBox(height: 20),
          _buildPerformanceMetrics(dashboardProvider),
          const SizedBox(height: 20),
          _buildGrowthCharts(),
        ],
      ),
    );
  }

  Widget _buildOverviewStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Overview',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildOverviewStatItem('Total Users', dashboardProvider.totalUsers.toString(), Icons.people, Colors.blue),
                _buildOverviewStatItem('Active Reports', dashboardProvider.totalReports.toString(), Icons.assignment, Colors.orange),
                _buildOverviewStatItem('Platform Events', dashboardProvider.totalEvents.toString(), Icons.event, Colors.green),
                _buildOverviewStatItem('Green Spaces', dashboardProvider.greenSpacesCount.toString(), Icons.park, Colors.teal),
                _buildOverviewStatItem('Total Plants', dashboardProvider.totalPlants.toString(), Icons.eco, Colors.lightGreen),
                _buildOverviewStatItem('Adopted Plants', dashboardProvider.adoptedPlants.toString(), Icons.favorite, Colors.pink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem('User Growth Rate', '${dashboardProvider.platformAnalytics['user_growth_rate']?.toStringAsFixed(1) ?? '0'}%', Colors.green),
            _buildPerformanceItem('Report Approval Rate', '${dashboardProvider.platformAnalytics['report_approval_rate']?.toStringAsFixed(1) ?? '0'}%', Colors.blue),
            _buildPerformanceItem('Event Completion Rate', '${dashboardProvider.platformAnalytics['event_completion_rate']?.toStringAsFixed(1) ?? '0'}%', Colors.orange),
            _buildPerformanceItem('Platform Uptime', dashboardProvider.systemMetrics['uptime'] ?? 'N/A', Colors.teal),
            _buildPerformanceItem('Error Rate', dashboardProvider.systemMetrics['error_rate'] ?? 'N/A', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCharts() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Trends',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User registration and platform usage trends would be displayed here with interactive charts.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Interactive Charts Area\n\n'
                      '• User Growth Over Time\n'
                      '• Content Submission Trends\n'
                      '• Platform Engagement Metrics',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAnalyticsTab(AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserDemographics(dashboardProvider),
          const SizedBox(height: 20),
          _buildUserEngagement(),
          const SizedBox(height: 20),
          _buildUserRetention(),
        ],
      ),
    );
  }

  Widget _buildUserDemographics(AdminDashboardProvider dashboardProvider) {
    final roleDistribution = dashboardProvider.userAnalytics['role_distribution'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Demographics',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...roleDistribution.entries.map((entry) => _buildDemographicItem(entry.key, entry.value.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicItem(String role, String count) {
    final percentage = (int.tryParse(count) ?? 0) / 100; // Simplified calculation
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                role.toUpperCase(),
                style: AppTheme.textTheme.bodyMedium,
              ),
              Text(
                '$count users',
                style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getRoleColor(role)),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'ngo':
        return Colors.green;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUserEngagement() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Engagement',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEngagementItem('Daily Active Users', '1,245', '+12%', Colors.green),
            _buildEngagementItem('Weekly Active Users', '8,762', '+8%', Colors.blue),
            _buildEngagementItem('Monthly Active Users', '23,451', '+15%', Colors.orange),
            _buildEngagementItem('Avg. Session Duration', '12.4 min', '+2%', Colors.purple),
            _buildEngagementItem('User Retention Rate', '68%', '+5%', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementItem(String metric, String value, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRetention() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Retention',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User retention metrics and cohort analysis would be displayed here.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Retention Charts\n\n'
                      'Week 1: 85%\n'
                      'Week 2: 72%\n'
                      'Week 3: 64%\n'
                      'Week 4: 58%',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentAnalyticsTab(AdminDashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildContentStats(dashboardProvider),
          const SizedBox(height: 20),
          _buildContentPerformance(),
          const SizedBox(height: 20),
          _buildModerationAnalytics(dashboardProvider),
        ],
      ),
    );
  }

  Widget _buildContentStats(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Statistics',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildContentStatItem('Total Reports', dashboardProvider.totalReports.toString(), Icons.assignment, Colors.blue),
                _buildContentStatItem('Pending Moderation', dashboardProvider.pendingReports.toString(), Icons.pending, Colors.orange),
                _buildContentStatItem('Flagged Content', dashboardProvider.flaggedContent.toString(), Icons.flag, Colors.red),
                _buildContentStatItem('Spam Detected', dashboardProvider.spamCount.toString(), Icons.report_gmailerrorred, Colors.purple),
                _buildContentStatItem('Approval Rate', '${dashboardProvider.platformAnalytics['report_approval_rate']?.toStringAsFixed(1) ?? '0'}%', Icons.thumb_up, Colors.green),
                _buildContentStatItem('Avg. Response Time', '2.4 hours', Icons.timer, Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPerformance() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Performance',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceMetric('Report Submission Rate', '245/day', '+15%', Colors.green),
            _buildPerformanceMetric('Event Creation Rate', '34/day', '+8%', Colors.blue),
            _buildPerformanceMetric('Content Engagement', '1.2k interactions/day', '+22%', Colors.orange),
            _buildPerformanceMetric('User Generated Content', '89% of total', '+5%', Colors.purple),
            _buildPerformanceMetric('Content Quality Score', '4.2/5.0', '+0.3', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(String metric, String value, String change, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModerationAnalytics(AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moderation Analytics',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildModerationMetric('Moderation Queue', dashboardProvider.pendingReports.toString(), Colors.orange),
            _buildModerationMetric('Avg. Moderation Time', '1.2 hours', Colors.blue),
            _buildModerationMetric('Content Approval Rate', '${dashboardProvider.platformAnalytics['report_approval_rate']?.toStringAsFixed(1) ?? '0'}%', Colors.green),
            _buildModerationMetric('Appeal Success Rate', '23%', Colors.red),
            _buildModerationMetric('Moderator Efficiency', '89%', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationMetric(String metric, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric,
              style: AppTheme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityOverview(),
            const SizedBox(height: 20),
            _buildAuthenticationSettings(context, dashboardProvider),
            const SizedBox(height: 20),
            _buildAccessControl(),
            const SizedBox(height: 20),
            _buildSecurityActions(context),
            const SizedBox(height: 20),
            _buildAuditLog(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Overview',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSecurityMetric('Security Score', '92%', Icons.security, Colors.green),
                _buildSecurityMetric('Last Audit', '3 days ago', Icons.assessment, Colors.orange),
                _buildSecurityMetric('Threats Blocked', '1,245', Icons.block, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAuthenticationSettings(BuildContext context, AdminDashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Authentication & Access',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSecuritySwitch(
              'Require Two-Factor Authentication',
              'Enforce 2FA for all admin accounts',
              dashboardProvider.securitySettings['require_2fa'] ?? false,
                  (value) {
                final newSettings = Map<String, dynamic>.from(dashboardProvider.securitySettings);
                newSettings['require_2fa'] = value;
                dashboardProvider.updateSecuritySettings(newSettings);
              },
            ),
            _buildSecuritySwitch(
              'Content Moderation',
              'Automatically flag suspicious content',
              dashboardProvider.securitySettings['content_moderation'] ?? true,
                  (value) {
                final newSettings = Map<String, dynamic>.from(dashboardProvider.securitySettings);
                newSettings['content_moderation'] = value;
                dashboardProvider.updateSecuritySettings(newSettings);
              },
            ),
            _buildSecuritySwitch(
              'Data Encryption',
              'Encrypt sensitive user data',
              dashboardProvider.securitySettings['data_encryption'] ?? true,
                  (value) {
                final newSettings = Map<String, dynamic>.from(dashboardProvider.securitySettings);
                newSettings['data_encryption'] = value;
                dashboardProvider.updateSecuritySettings(newSettings);
              },
            ),
            _buildSecurityInput(
              'Session Timeout (minutes)',
              'Auto-logout after inactivity',
              dashboardProvider.securitySettings['session_timeout']?.toString() ?? '30',
                  (value) {
                final newSettings = Map<String, dynamic>.from(dashboardProvider.securitySettings);
                newSettings['session_timeout'] = int.tryParse(value) ?? 30;
                dashboardProvider.updateSecuritySettings(newSettings);
              },
            ),
            _buildSecurityInput(
              'Max Login Attempts',
              'Maximum failed login attempts before lockout',
              dashboardProvider.securitySettings['max_login_attempts']?.toString() ?? '5',
                  (value) {
                final newSettings = Map<String, dynamic>.from(dashboardProvider.securitySettings);
                newSettings['max_login_attempts'] = int.tryParse(value) ?? 5;
                dashboardProvider.updateSecuritySettings(newSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSecurityInput(String label, String hint, String initialValue, Function(String) onChanged) {
    final controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessControl() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access Control',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAccessItem('Admin Panel Access', 'Restrict access to authorized personnel only', Icons.admin_panel_settings, Colors.blue),
            _buildAccessItem('API Rate Limiting', 'Limit API requests to prevent abuse', Icons.speed, Colors.orange),
            _buildAccessItem('IP Whitelisting', 'Restrict access to specific IP addresses', Icons.network_check, Colors.green),
            _buildAccessItem('Role-Based Access', 'Control features based on user roles', Icons.people_alt, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: true,
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildSecurityActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Actions',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _runSecurityScan(context);
                },
                icon: const Icon(Icons.security),
                label: const Text('Run Security Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _viewSecurityLogs(context);
                },
                icon: const Icon(Icons.assignment),
                label: const Text('View Security Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _exportSecurityReport(context);
                },
                icon: const Icon(Icons.import_export),
                label: const Text('Export Security Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLog() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Security Audit Log',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Refresh audit log
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAuditLogItem('INFO', 'Security scan completed', 'Admin User', '2 minutes ago'),
            _buildAuditLogItem('WARN', 'Multiple failed login attempts', '192.168.1.100', '15 minutes ago'),
            _buildAuditLogItem('INFO', 'User role permissions updated', 'Admin User', '1 hour ago'),
            _buildAuditLogItem('ERROR', 'Failed to update security settings', 'System', '2 hours ago'),
            _buildAuditLogItem('INFO', 'Database backup completed', 'System', '3 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogItem(String level, String action, String user, String time) {
    Color levelColor = Colors.grey;
    switch (level) {
      case 'INFO':
        levelColor = Colors.blue;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      case 'ERROR':
        levelColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: levelColor),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: levelColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: AppTheme.textTheme.bodyMedium,
                ),
                Text(
                  'By: $user • $time',
                  style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _runSecurityScan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Scan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Running comprehensive security scan...'),
          ],
        ),
      ),
    );

    // Simulate scan completion
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Security scan completed successfully')),
      );
    });
  }

  void _viewSecurityLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Logs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildSecurityLogItem('Login successful', 'Admin User', '2 minutes ago'),
                    _buildSecurityLogItem('Failed login attempt', '192.168.1.100', '15 minutes ago'),
                    _buildSecurityLogItem('Password changed', 'User: john@example.com', '1 hour ago'),
                    _buildSecurityLogItem('Security settings updated', 'Admin User', '2 hours ago'),
                    _buildSecurityLogItem('User suspended', 'Admin User', '3 hours ago'),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildSecurityLogItem(String action, String user, String time) {
    return ListTile(
      leading: const Icon(Icons.security, size: 16),
      title: Text(action),
      subtitle: Text('By: $user • $time'),
      dense: true,
    );
  }

  void _exportSecurityReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Security Report'),
        content: const Text('Security report will be generated and downloaded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security report exported successfully')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}