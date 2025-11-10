import 'package:flutter/material.dart';
import 'package:urban_green_mapper/features/profile/providers/profile_provider.dart';

class ActivityHistoryDialog extends StatefulWidget {
  final ProfileProvider profileProvider;

  const ActivityHistoryDialog({
    super.key,
    required this.profileProvider,
  });

  @override
  State<ActivityHistoryDialog> createState() => _ActivityHistoryDialogState();
}

class _ActivityHistoryDialogState extends State<ActivityHistoryDialog> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final activities = await widget.profileProvider.getUserActivityHistory();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load activities: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Activity History'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
                ? const Center(
                    child: Text('No activities found'),
                  )
                : ListView.builder(
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
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
        color = Colors.orange;
        break;
      case 'participation':
        icon = Icons.event;
        color = Colors.blue;
        break;
      case 'adoption':
        icon = Icons.nature;
        color = Colors.green;
        break;
      default:
        icon = Icons.history;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeAgo(timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'attended':
      case 'completed':
        return Colors.green[100]!;
      case 'pending':
      case 'registered':
        return Colors.orange[100]!;
      case 'rejected':
      case 'cancelled':
        return Colors.red[100]!;
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
}