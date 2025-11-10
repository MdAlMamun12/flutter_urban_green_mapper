import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/core/models/report_model.dart';

class ReportsManagementBottomSheet extends StatefulWidget {
  const ReportsManagementBottomSheet({super.key});

  @override
  State<ReportsManagementBottomSheet> createState() => _ReportsManagementBottomSheetState();
}

class _ReportsManagementBottomSheetState extends State<ReportsManagementBottomSheet> {
  final _searchController = TextEditingController();
  String _filterStatus = 'pending';
  final List<String> _statuses = ['pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NGODashboardProvider>(context, listen: false);
      if (provider.pendingReports.isEmpty) {
        provider.loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<NGODashboardProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports Management',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: dashboardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportsList(dashboardProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search reports',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _filterReports();
              },
            ),
          ),
          onChanged: (value) => _filterReports(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _statuses.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: _filterStatus == status ? Colors.white : _getStatusColor(status),
                    ),
                  ),
                  selected: _filterStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = selected ? status : 'pending';
                    });
                    _filterReports();
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: _getStatusColor(status),
                  checkmarkColor: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsList(NGODashboardProvider provider) {
    final filteredReports = _getFilteredReports(provider.pendingReports);

    if (filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return _buildReportCard(report, provider);
      },
    );
  }

  Widget _buildReportCard(ReportModel report, NGODashboardProvider provider) {
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getReportIcon(report.type),
                    size: 16,
                    color: _getStatusColor(report.status),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.displayTitle,
                    style: AppTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(report.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              style: AppTheme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.displayLocation,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report.createdAt),
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (report.userName != null && report.userName!.isNotEmpty)
                  Text(
                    'By: ${report.userName!}',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (report.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _approveReport(report.reportId, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectReport(report.reportId, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'pending' 
                ? 'All pending reports have been reviewed'
                : 'No ${_filterStatus} reports available',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'maintenance':
        return Icons.build;
      case 'vandalism':
        return Icons.warning;
      case 'safety':
        return Icons.security;
      case 'suggestion':
        return Icons.lightbulb;
      default:
        return Icons.assignment;
    }
  }

  List<ReportModel> _getFilteredReports(List<ReportModel> reports) {
    var filtered = reports.where((report) => report.status == _filterStatus).toList();

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered = filtered.where((report) {
        return report.description.toLowerCase().contains(searchQuery) ||
            (report.title?.toLowerCase().contains(searchQuery) ?? false) ||
            (report.spaceName?.toLowerCase().contains(searchQuery) ?? false) ||
            (report.userName?.toLowerCase().contains(searchQuery) ?? false) ||
            (report.location?.toLowerCase().contains(searchQuery) ?? false) ||
            report.typeDisplay.toLowerCase().contains(searchQuery) ||
            report.statusDisplay.toLowerCase().contains(searchQuery);
      }).toList();
    }

    return filtered;
  }

  void _filterReports() {
    setState(() {});
  }

  void _approveReport(String reportId, NGODashboardProvider provider) async {
    try {
      await provider.approveReport(reportId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectReport(String reportId, NGODashboardProvider provider) async {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
                hintText: 'Enter the reason for rejecting this report...',
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
              if (reasonController.text.trim().isNotEmpty) {
                try {
                  await provider.rejectReport(reportId, reasonController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report rejected successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reject report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}