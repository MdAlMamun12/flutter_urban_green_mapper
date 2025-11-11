import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/dashboard/providers/dashboard_provider.dart';
import 'package:urban_green_mapper/features/adoption/providers/adoption_provider.dart';
import 'package:urban_green_mapper/features/mapping/screens/map_screen.dart';
import 'package:urban_green_mapper/features/events/screens/events_list.dart';
import 'package:urban_green_mapper/features/adoption/screens/adoption_screen.dart';
import 'package:urban_green_mapper/features/profile/screens/profile_screen.dart';
import 'package:urban_green_mapper/features/auth/screens/sponsor_registration_screen.dart';
// Import the models
import 'package:urban_green_mapper/core/models/green_space_model.dart';
import 'package:urban_green_mapper/core/models/event_model.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardHome(),
    const EventsList(),
    const AdoptionScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // When navigating to Adopt tab, refresh available plants to ensure UI shows latest data
    if (index == 2) {
      try {
        context.read<AdoptionProvider>().loadPlants();
      } catch (_) {
        // ignore: avoid_print
        debugPrint('AdoptionProvider not available when switching tabs');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Green Mapper'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showNotifications();
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
              backgroundColor: Colors.green[50],
              selectedLabelTextStyle: const TextStyle(color: Colors.green),
              selectedIconTheme: const IconThemeData(color: Colors.green),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.nature),
                  label: Text('Adopt'),
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
              backgroundColor: Colors.green[50],
              selectedLabelTextStyle: const TextStyle(color: Colors.green),
              selectedIconTheme: const IconThemeData(color: Colors.green),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.nature),
                  label: Text('Adopt'),
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
            Colors.green[700]!,
            Colors.green[600]!,
            Colors.green[500]!,
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
            icon: Icon(Icons.home, color: Colors.white),
            activeIcon: Icon(Icons.home, color: Colors.yellow),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.white),
            activeIcon: Icon(Icons.event, color: Colors.yellow),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature, color: Colors.white),
            activeIcon: Icon(Icons.nature, color: Colors.yellow),
            label: 'Adopt',
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

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('Your notifications will appear here'),
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

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashboardProvider = Provider.of<DashboardProvider>(context);

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

  Widget _buildMobileLayout(dynamic user, DashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user, dashboardProvider),
        const SizedBox(height: 20),
        _buildImpactProgressSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildStatsSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 16),
        _buildBecomeSponsorSection(),
        const SizedBox(height: 16),
        _buildNearbySpacesSection(dashboardProvider),
        const SizedBox(height: 16),
        _buildUpcomingEventsSection(dashboardProvider),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabletLayout(dynamic user, DashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user, dashboardProvider),
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
            _buildImpactProgressSection(dashboardProvider),
            _buildStatsSection(dashboardProvider),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickActions(),
        const SizedBox(height: 16),
        _buildBecomeSponsorSection(),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          children: [
            _buildNearbySpacesSection(dashboardProvider),
            _buildUpcomingEventsSection(dashboardProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(dynamic user, DashboardProvider dashboardProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(user, dashboardProvider),
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
            _buildImpactProgressSection(dashboardProvider),
            _buildStatsSection(dashboardProvider),
            _buildQuickActions(),
          ],
        ),
        const SizedBox(height: 16),
        _buildBecomeSponsorSection(),
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
            _buildNearbySpacesSection(dashboardProvider),
            _buildUpcomingEventsSection(dashboardProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(dynamic user, DashboardProvider dashboardProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? 'Green Warrior'}!',
                        style: AppTheme.textTheme.headlineSmall?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s make our city greener together',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getLevelColor(dashboardProvider.userLevel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dashboardProvider.userLevelName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (dashboardProvider.pointsToNextLevel > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: dashboardProvider.levelProgress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${dashboardProvider.pointsToNextLevel} points to ${dashboardProvider.nextLevelName}',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImpactProgressSection(DashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Impact Progress',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressCircle(
                        currentValue: dashboardProvider.greenPoints.toDouble(),
                        maxValue: 1000,
                        label: 'Points',
                        color: Colors.green,
                      ),
                      _buildProgressCircle(
                        currentValue: dashboardProvider.totalVolunteerHours.toDouble(),
                        maxValue: 50,
                        label: 'Hours',
                        color: Colors.blue,
                      ),
                      _buildProgressCircle(
                        currentValue: dashboardProvider.approvedReports.toDouble(),
                        maxValue: 20,
                        label: 'Reports',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3,
                    children: [
                      _buildProgressStat(
                        'Event Attendance',
                        '${dashboardProvider.attendedEvents} events',
                        dashboardProvider.eventAttendanceRate / 100,
                        Colors.blue,
                      ),
                      _buildProgressStat(
                        'Report Approval',
                        '${dashboardProvider.approvedReports}/${dashboardProvider.totalReportsSubmitted} approved',
                        dashboardProvider.reportApprovalRate / 100,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle({
    required double currentValue,
    required double maxValue,
    required String label,
    required Color color,
  }) {
    final progress = currentValue / maxValue;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress > 1 ? 1.0 : progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              currentValue.toInt().toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildProgressStat(String title, String subtitle, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildStatsSection(DashboardProvider dashboardProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Your Impact Stats',
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
                    crossAxisCount: isSmall ? 2 : 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: isSmall ? 0.8 : 1.2,
                    children: [
                      _buildStatItem(
                        value: dashboardProvider.adoptedPlants.length.toString(),
                        label: 'Plants Adopted',
                        icon: Icons.nature,
                        color: Colors.green,
                      ),
                      _buildStatItem(
                        value: dashboardProvider.attendedEvents.toString(),
                        label: 'Events Attended',
                        icon: Icons.event,
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        value: dashboardProvider.totalReportsSubmitted.toString(),
                        label: 'Reports Submitted',
                        icon: Icons.report,
                        color: Colors.orange,
                      ),
                      _buildStatItem(
                        value: '${dashboardProvider.totalVolunteerHours}h',
                        label: 'Volunteer Hours',
                        icon: Icons.access_time,
                        color: Colors.purple,
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

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 300;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(
                      icon: Icons.add,
                      label: 'Report Issue',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      },
                      color: Colors.blue,
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.event,
                      label: 'Join Event',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventsList()),
                        );
                      },
                      color: Colors.orange,
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.nature,
                      label: 'Adopt Plant',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdoptionScreen()),
                        );
                      },
                      color: Colors.green,
                      isSmall: isSmall,
                    ),
                    if (!isSmall) _buildActionButton(
                      icon: Icons.share,
                      label: 'Invite Friends',
                      onPressed: () {
                        _inviteFriends();
                      },
                      color: Colors.purple,
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

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed, required Color color, bool isSmall = false}) {
    return SizedBox(
      width: isSmall ? 120 : 140,
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

  Widget _buildBecomeSponsorSection() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Only show this section if user is not already a sponsor
    if (authProvider.isSponsor) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Become a Sponsor',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.upgrade, color: Colors.green),
              ),
              title: Text(
                'Upgrade to Sponsor',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Support environmental initiatives and get exclusive benefits',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'UPGRADE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                _navigateToSponsorRegistration();
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSponsorBenefit('🌱', 'Support community green projects'),
                  _buildSponsorBenefit('🏆', 'Get featured on our platform'),
                  _buildSponsorBenefit('📊', 'Access detailed impact analytics'),
                  _buildSponsorBenefit('🤝', 'Network with other eco-conscious organizations'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSponsorRegistration() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) {
      // Show login required message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to become a sponsor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SponsorRegistrationScreen(
          isUpgradeFromCitizen: true,
          // Removed the currentUser parameter as it's not defined in SponsorRegistrationScreen
        ),
      ),
    );
  }

  Widget _buildSponsorBenefit(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySpacesSection(DashboardProvider dashboardProvider) {
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
                Row(
                  children: [
                    Icon(Icons.park, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Nearby Green Spaces',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardProvider.nearbySpaces.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No green spaces nearby',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: dashboardProvider.nearbySpaces
                    .take(3)
                    .map((space) => _buildSpaceListItem(space))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceListItem(GreenSpaceModel space) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _getStatusColor(space.status).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getSpaceIcon(space.type),
          color: _getStatusColor(space.status),
          size: 18,
        ),
      ),
      title: Text(
        space.name,
        style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${space.type} • ${_getDistanceText(space)}',
        style: AppTheme.textTheme.bodySmall?.copyWith(fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      visualDensity: VisualDensity.compact,
      onTap: () {
        _showSpaceDetails(space);
      },
    );
  }

  Widget _buildUpcomingEventsSection(DashboardProvider dashboardProvider) {
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
                Row(
                  children: [
                    Icon(Icons.event, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming Events',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventsList()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboardProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dashboardProvider.upcomingEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No upcoming events',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: dashboardProvider.upcomingEvents
                    .take(3)
                    .map((event) => _buildEventListItem(event))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventListItem(EventModel event) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.event,
          color: Colors.blue,
          size: 18,
        ),
      ),
      title: Text(
        event.title,
        style: AppTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatDate(event.startTime)} • ${_getParticipantsText(event)}',
        style: AppTheme.textTheme.bodySmall?.copyWith(fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      visualDensity: VisualDensity.compact,
      onTap: () {
        _showEventDetails(event);
      },
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 4: return Colors.purple;
      case 3: return Colors.orange;
      case 2: return Colors.blue;
      default: return Colors.green;
    }
  }

  IconData _getSpaceIcon(String type) {
    switch (type) {
      case 'park':
        return Icons.park;
      case 'garden':
        return Icons.local_florist;
      case 'forest':
        return Icons.forest;
      default:
        return Icons.nature;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'healthy':
        return Colors.green;
      case 'degraded':
        return Colors.orange;
      case 'restored':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDistanceText(GreenSpaceModel space) {
    // In a real app, this would calculate actual distance
    return '${(5 + space.spaceId.hashCode % 10).toString()} km away';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getParticipantsText(EventModel event) {
    return '${event.currentParticipants}/${event.maxParticipants} participants';
  }

  void _inviteFriends() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: const Text('Share the app with your friends and help grow our green community!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSpaceDetails(GreenSpaceModel space) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(space.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(space.description),
            const SizedBox(height: 8),
            Text('Type: ${space.type}'),
            Text('Status: ${space.status}'),
            Text('Location: ${space.location}'),
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

  void _showEventDetails(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(event.startTime)}'),
            Text('Location: ${event.location}'),
            Text('Participants: ${event.currentParticipants}/${event.maxParticipants}'),
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