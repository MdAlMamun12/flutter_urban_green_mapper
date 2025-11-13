import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/core/widgets/custom_button.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:urban_green_mapper/features/dashboard/utils/dashboard_colors.dart';

class ReportGeneratorScreen extends StatefulWidget {
  const ReportGeneratorScreen({super.key});

  @override
  State<ReportGeneratorScreen> createState() => _ReportGeneratorScreenState();
}

class _ReportGeneratorScreenState extends State<ReportGeneratorScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _reportType = 'comprehensive';
  final List<String> _reportTypes = [
    'comprehensive',
    'events',
    'sponsorships',
    'financial',
    'community'
  ];

  @override
  void initState() {
    super.initState();
    // Set default date range to last 30 days
    _endDate = DateTime.now();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<NGODashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
        backgroundColor: DashboardColors.safeGreen(700),
        foregroundColor: DashboardColors.primaryWhite,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Configuration',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            _buildReportTypeSelector(),
            const SizedBox(height: 32),
            _buildGenerateButton(dashboardProvider),
            const SizedBox(height: 24),
            if (_startDate != null && _endDate != null) 
              _buildPreviewSection(dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSelectedDateRange(),
            const SizedBox(height: 16),
            _buildDateRangeButtons(),
            const SizedBox(height: 16),
            _buildCustomDatePickers(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateRange() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.safeGreen(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_startDate != null ? _formatDate(_startDate!) : 'Not selected'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'End Date:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_endDate != null ? _formatDate(_endDate!) : 'Not selected'),
            ],
          ),
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Duration: ${_calculateDuration()} days',
              style: TextStyle(
                color: DashboardColors.safeGreen(700),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeButtons() {
    final now = DateTime.now();
    final predefinedRanges = [
      {
        'label': 'Last 7 Days',
        'start': now.subtract(const Duration(days: 7)),
        'end': now,
      },
      {
        'label': 'Last 30 Days',
        'start': now.subtract(const Duration(days: 30)),
        'end': now,
      },
      {
        'label': 'Last 90 Days',
        'start': now.subtract(const Duration(days: 90)),
        'end': now,
      },
      {
        'label': 'This Month',
        'start': DateTime(now.year, now.month, 1),
        'end': now,
      },
      {
        'label': 'Last Month',
        'start': DateTime(now.year, now.month - 1, 1),
        'end': DateTime(now.year, now.month, 0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Select:',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: predefinedRanges.map((range) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _startDate = range['start'] as DateTime;
                  _endDate = range['end'] as DateTime;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.safeGreen(50),
                foregroundColor: DashboardColors.safeGreen(700),
                elevation: 0,
              ),
              child: Text(range['label'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Range:',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date'),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () => _selectStartDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashboardColors.primaryWhite,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startDate != null ? _formatDate(_startDate!) : 'Select Start Date'),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Date'),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () => _selectEndDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashboardColors.primaryWhite,
                      foregroundColor: Colors.black87,
                      elevation: 1,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_endDate != null ? _formatDate(_endDate!) : 'Select End Date'),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Type',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reportTypes.map((type) {
                return FilterChip(
                  label: Text(_getReportTypeDisplayName(type)),
                  selected: _reportType == type,
                  onSelected: (selected) {
                    setState(() {
                      _reportType = type;
                    });
                  },
                  selectedColor: DashboardColors.safeGreen(100),
                  checkmarkColor: DashboardColors.primaryGreen,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DashboardColors.safeGrey(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getReportTypeDescription(_reportType),
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: DashboardColors.safeGrey(600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(NGODashboardProvider provider) {
    final isEnabled = _startDate != null && _endDate != null;

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: isEnabled ? () => _generateReport(provider) : null,
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.primaryWhite),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Generate Report'),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewSection(NGODashboardProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Preview',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPreviewItem('Report Type', _getReportTypeDisplayName(_reportType)),
            _buildPreviewItem('Date Range', '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'),
            _buildPreviewItem('Total Events', provider.events.length.toString()),
            _buildPreviewItem('Active Sponsors', provider.activeSponsors.toString()),
            _buildPreviewItem('Community Members', provider.communityMembers.toString()),
            _buildPreviewItem('Total Budget', '\$${provider.totalBudget.toStringAsFixed(2)}'),
            _buildPreviewItem('Budget Utilized', '\$${provider.budgetUtilized.toStringAsFixed(2)}'),
            _buildPreviewItem('Volunteer Hours', provider.volunteerHours.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Ensure end date is not before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _getReportTypeDisplayName(String type) {
    switch (type) {
      case 'comprehensive':
        return 'Comprehensive Report';
      case 'events':
        return 'Events Report';
      case 'sponsorships':
        return 'Sponsorships Report';
      case 'financial':
        return 'Financial Report';
      case 'community':
        return 'Community Report';
      default:
        return type;
    }
  }

  String _getReportTypeDescription(String type) {
    switch (type) {
      case 'comprehensive':
        return 'Complete overview including events, sponsorships, finances, and community engagement';
      case 'events':
        return 'Detailed analysis of events, participation, and outcomes';
      case 'sponsorships':
        return 'Sponsorship performance, contributions, and partner relationships';
      case 'financial':
        return 'Budget utilization, expenses, and financial health';
      case 'community':
        return 'Community engagement, volunteer hours, and member growth';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDuration() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _generateReport(NGODashboardProvider provider) async {
    try {
      final report = await provider.generateComprehensiveReport(_startDate!, _endDate!);
      if (!mounted) return;

      // Show success dialog with report summary
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Generated Successfully'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReportSummaryItem('Period', report['period']?.toString() ?? ''),
                _buildReportSummaryItem('Total Events', report['total_events']?.toString() ?? '0'),
                _buildReportSummaryItem('Completed Events', report['completed_events']?.toString() ?? '0'),
                _buildReportSummaryItem('Total Participants', report['total_participants']?.toString() ?? '0'),
                _buildReportSummaryItem('Total Reports', report['total_reports']?.toString() ?? '0'),
                _buildReportSummaryItem('Approved Reports', report['approved_reports']?.toString() ?? '0'),
                _buildReportSummaryItem('Total Funding', '\$${report['total_funding']?.toStringAsFixed(2) ?? '0.00'}'),
                _buildReportSummaryItem('Sponsorships', report['sponsorships']?.toString() ?? '0'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Export the report
                _exportReport(provider, report);
              },
              child: const Text('Export'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: DashboardColors.primaryRed,
        ),
      );
    }
  }

  Widget _buildReportSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _exportReport(NGODashboardProvider provider, Map<String, dynamic> report) {
    // Implementation for exporting the report
    // This would integrate with your PDF export service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report export functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}