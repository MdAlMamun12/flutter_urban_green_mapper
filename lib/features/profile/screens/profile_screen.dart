import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/models/user_model.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/responsive_layout.dart';
import 'package:urban_green_mapper/features/auth/providers/auth_provider.dart';
import 'package:urban_green_mapper/features/profile/providers/profile_provider.dart';
import 'package:urban_green_mapper/features/profile/widgets/edit_profile_dialog.dart';
import 'package:urban_green_mapper/features/profile/widgets/change_password_dialog.dart';
import 'package:urban_green_mapper/features/profile/widgets/activity_history_dialog.dart';
import 'package:urban_green_mapper/features/profile/widgets/delete_account_dialog.dart';
import 'package:urban_green_mapper/features/profile/widgets/export_data_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        profileProvider.loadUserProfile(authProvider.user!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (user != null) {
                profileProvider.refreshUserData();
              }
            },
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(user, profileProvider),
              tablet: _buildTabletLayout(user, profileProvider),
              desktop: _buildDesktopLayout(user, profileProvider),
            ),
    );
  }

  Widget _buildMobileLayout(UserModel? user, ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(user, profileProvider),
          const SizedBox(height: 20),
          _buildStatsGrid(profileProvider),
          const SizedBox(height: 20),
          _buildImpactProgress(profileProvider),
          const SizedBox(height: 20),
          _buildQuickActions(profileProvider),
          const SizedBox(height: 20),
          _buildRecentActivity(profileProvider),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(UserModel? user, ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProfileHeader(user, profileProvider),
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
              _buildStatsGrid(profileProvider),
              _buildImpactProgress(profileProvider),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuickActions(profileProvider),
          const SizedBox(height: 24),
          _buildRecentActivity(profileProvider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(UserModel? user, ProfileProvider profileProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildProfileHeader(user, profileProvider),
          const SizedBox(height: 32),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            children: [
              _buildStatsGrid(profileProvider),
              _buildImpactProgress(profileProvider),
              _buildBadgesSection(profileProvider),
            ],
          ),
          const SizedBox(height: 32),
          _buildQuickActions(profileProvider),
          const SizedBox(height: 32),
          _buildRecentActivity(profileProvider),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user, ProfileProvider profileProvider) {
    final name = user?.name ?? 'User';
    final email = user?.email ?? 'No email';
    final memberSince = user?.createdAt ?? DateTime.now();
    final profilePicUrl = user?.profilePicture;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFE8F5E8),
                  backgroundImage: profilePicUrl != null && profilePicUrl.isNotEmpty
                      ? NetworkImage(profilePicUrl) as ImageProvider
                      : null,
                  child: profilePicUrl == null || profilePicUrl.isEmpty
                      ? Text(
                          user?.initials ?? 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    onPressed: () {
                      _showImagePickerDialog(profileProvider);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(
                    user?.roleDisplay ?? 'User',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    'Member since ${memberSince.year}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user?.userLevel ?? 'Green Beginner',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProfileProvider profileProvider) {
    final stats = profileProvider.userStatistics;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Color(0xFF2E7D32)),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard(
                  icon: Icons.nature,
                  value: stats['adopted_plants_count']?.toString() ?? '0',
                  label: 'Plants Adopted',
                  color: const Color(0xFF2E7D32),
                ),
                _buildStatCard(
                  icon: Icons.event,
                  value: stats['attended_events']?.toString() ?? '0',
                  label: 'Events Attended',
                  color: const Color(0xFF1976D2),
                ),
                _buildStatCard(
                  icon: Icons.assignment,
                  value: stats['total_reports']?.toString() ?? '0',
                  label: 'Reports Submitted',
                  color: const Color(0xFFF57C00),
                ),
                _buildStatCard(
                  icon: Icons.access_time,
                  value: stats['total_volunteer_hours']?.toString() ?? '0',
                  label: 'Volunteer Hours',
                  color: const Color(0xFF7B1FA2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withOpacity(0.1), Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.alphaBlend(color.withOpacity(0.3), Colors.white)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactProgress(ProfileProvider profileProvider) {
    final impactScore = profileProvider.user?.impactScore ?? 0;
    final progressValue = profileProvider.user?.levelProgress ?? 0.0;
    final level = profileProvider.user?.userLevel ?? 'Green Beginner';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF2E7D32)),
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
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            impactScore.toString(),
                            style: AppTheme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          Text(
                            'Points',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      level,
                      style: AppTheme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profileProvider.user?.nextLevelRequirements ?? 'Start earning points!',
                    style: AppTheme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(ProfileProvider profileProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  'Your Achievements',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: profileProvider.getUserAchievements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final achievements = snapshot.data ?? [];
                final earnedAchievements = achievements.where((a) => a['unlocked'] == true).toList();
                
                return earnedAchievements.isEmpty
                    ? Column(
                        children: [
                          Icon(Icons.emoji_events, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            'No achievements yet',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete activities to earn badges!',
                            style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: earnedAchievements
                            .take(4)
                            .map((achievement) => _buildAchievementBadge(achievement))
                            .toList(),
                      );
              },
            ),
            if (profileProvider.userStatistics['adopted_plants_count'] == 0 ||
                profileProvider.userStatistics['attended_events'] == 0)
              const SizedBox(height: 16),
            if (profileProvider.userStatistics['adopted_plants_count'] == 0)
              _buildAchievementHint(
                icon: Icons.nature,
                text: 'Adopt your first plant to earn the Plant Parent badge!',
                color: const Color(0xFF2E7D32),
              ),
            if (profileProvider.userStatistics['attended_events'] == 0)
              _buildAchievementHint(
                icon: Icons.event,
                text: 'Join an event to earn the Event Participant badge!',
                color: const Color(0xFF1976D2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isUnlocked ? const Color(0xFFFFD740) : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              achievement['icon'] ?? '🏆',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            achievement['title'] ?? 'Achievement',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isUnlocked ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementHint({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withOpacity(0.1), Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.alphaBlend(color.withOpacity(0.3), Colors.white)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ProfileProvider profileProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Management',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 300;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit Profile',
                      onPressed: () => _showEditProfileDialog(profileProvider),
                      color: const Color(0xFF2E7D32),
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.lock,
                      label: 'Change Password',
                      onPressed: () => _showChangePasswordDialog(profileProvider),
                      color: const Color(0xFF1976D2),
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.history,
                      label: 'Activity History',
                      onPressed: () => _showActivityHistory(profileProvider),
                      color: const Color(0xFFF57C00),
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.download,
                      label: 'Export Data',
                      onPressed: () => _exportUserData(profileProvider),
                      color: const Color(0xFF7B1FA2),
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'Delete Account',
                      onPressed: () => _showDeleteAccountDialog(profileProvider),
                      color: const Color(0xFFD32F2F),
                      isSmall: isSmall,
                    ),
                    _buildActionButton(
                      icon: Icons.logout,
                      label: 'Logout',
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false).logout();
                      },
                      color: const Color(0xFF757575),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isSmall = false,
  }) {
    return SizedBox(
      width: isSmall ? 120 : 140,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ProfileProvider profileProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: profileProvider.getUserActivityHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final activities = snapshot.data ?? [];
                
                return activities.isEmpty
                    ? Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            'No recent activity',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your activities will appear here',
                            style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      )
                    : Column(
                        children: activities
                            .take(5)
                            .map((activity) => _buildActivityItem(activity))
                            .toList(),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final title = activity['title'] as String;
    final description = activity['description'] as String;
    final timestamp = activity['timestamp'] as DateTime;
    final status = activity['status'] as String;

    IconData icon;
    Color color;
    
    switch (type) {
      case 'report':
        icon = Icons.assignment;
        color = const Color(0xFFF57C00);
        break;
      case 'participation':
        icon = Icons.event;
        color = const Color(0xFF1976D2);
        break;
      case 'adoption':
        icon = Icons.nature;
        color = const Color(0xFF2E7D32);
        break;
      default:
        icon = Icons.history;
        color = const Color(0xFF757575);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.alphaBlend(color.withOpacity(0.1), Colors.white),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        status.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getStatusColor(status),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(timestamp),
                      style: AppTheme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'attended':
      case 'completed':
        return const Color(0xFFE8F5E8);
      case 'pending':
      case 'registered':
        return const Color(0xFFFFF3E0);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey[100]!;
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Dialog Methods
  void _showImagePickerDialog(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile Picture'),
        content: const Text('Profile picture upload feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: profileProvider.user,
        onUpdate: (name, phoneNumber, location) async {
          try {
            await profileProvider.updateUserProfile(
              name: name,
              phoneNumber: phoneNumber,
              location: location,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update profile: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showChangePasswordDialog(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onPasswordChange: (currentPassword, newPassword) async {
          try {
            await profileProvider.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            );
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to change password: $e')),
              );
            }
          }
        },
        onPasswordReset: (email, phoneNumber, otp, newPassword) async {
          try {
            if (phoneNumber != null && otp != null && newPassword != null) {
              await profileProvider.verifyOtpAndResetPassword(otp, newPassword);
            } else if (email != null) {
              await profileProvider.resetPasswordWithEmail(email);
            }
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset instructions sent')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to reset password: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showActivityHistory(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => ActivityHistoryDialog(
        profileProvider: profileProvider,
      ),
    );
  }

  void _exportUserData(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => ExportDataDialog(
        profileProvider: profileProvider,
      ),
    );
  }

  void _showDeleteAccountDialog(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onDelete: (confirmationText) async {
          try {
            await profileProvider.deleteAccount(confirmationText);
            if (mounted) {
              Navigator.pop(context);
              // User will be automatically logged out after account deletion
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete account: $e')),
              );
            }
          }
        },
      ),
    );
  }
}