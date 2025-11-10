import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedTimeRange = 'monthly';
  final List<String> _timeRanges = ['weekly', 'monthly', 'quarterly', 'yearly'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NGODashboardProvider>(context, listen: false);
      provider.loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<NGODashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: _selectedTimeRange,
            dropdownColor: Colors.white,
            underline: const SizedBox(),
            items: _timeRanges.map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(
                  range[0].toUpperCase() + range.substring(1),
                  style: const TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTimeRange = value!;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCards(dashboardProvider),
                  const SizedBox(height: 24),
                  _buildEventAnalytics(dashboardProvider),
                  const SizedBox(height: 24),
                  _buildSponsorshipAnalytics(dashboardProvider),
                  const SizedBox(height: 24),
                  _buildCommunityAnalytics(dashboardProvider),
                  const SizedBox(height: 24),
                  _buildPerformanceMetrics(dashboardProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(NGODashboardProvider provider) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      children: [
        _buildSummaryCard(
          'Total Events',
          provider.events.length.toString(),
          Icons.event,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Active Sponsors',
          provider.activeSponsors.toString(),
          Icons.business,
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Funding',
          '\$${provider.totalSponsorshipAmount.toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Community Members',
          provider.communityMembers.toString(),
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventAnalytics(NGODashboardProvider provider) {
    final eventStatusData = [
      {'status': 'Upcoming', 'count': provider.events.where((e) => e.status == 'upcoming').length, 'color': Colors.blue},
      {'status': 'Ongoing', 'count': provider.events.where((e) => e.status == 'ongoing').length, 'color': Colors.green},
      {'status': 'Completed', 'count': provider.events.where((e) => e.status == 'completed').length, 'color': Colors.orange},
      {'status': 'Cancelled', 'count': provider.events.where((e) => e.status == 'cancelled').length, 'color': Colors.red},
    ];

    final totalEvents = provider.events.length;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Analytics',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildCustomPieChart(eventStatusData, totalEvents),
            ),
            const SizedBox(height: 16),
            _buildEventStatusLegend(eventStatusData),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPieChart(List<Map<String, dynamic>> data, int total) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring for total
        CustomPaint(
          size: const Size(160, 160),
          painter: _PieChartPainter(data, total),
        ),
        // Center text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              total.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Total Events',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventStatusLegend(List<Map<String, dynamic>> data) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item['status']} (${item['count']})',
              style: AppTheme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSponsorshipAnalytics(NGODashboardProvider provider) {
    final tierData = [
      {'tier': 'Bronze', 'count': provider.bronzeSponsors, 'color': Colors.brown},
      {'tier': 'Silver', 'count': provider.silverSponsors, 'color': Colors.grey},
      {'tier': 'Gold', 'count': provider.goldSponsors, 'color': Colors.amber},
      {'tier': 'Platinum', 'count': provider.platinumSponsors, 'color': Colors.blue},
    ];

    final totalSponsors = provider.totalSponsors;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sponsorship Analytics',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildCustomBarChart(tierData, totalSponsors),
            ),
            const SizedBox(height: 16),
            _buildSponsorTierLegend(tierData),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBarChart(List<Map<String, dynamic>> data, int total) {
    final maxCount = data.fold(0, (max, item) => item['count'] > max ? item['count'] : max);
    
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: data.map((item) {
              final height = (item['count'] / (maxCount == 0 ? 1 : maxCount)) * 100;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: height,
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        item['count'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['tier'][0],
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Sponsors: $total',
          style: AppTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorTierLegend(List<Map<String, dynamic>> data) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item['tier']} (${item['count']})',
              style: AppTheme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCommunityAnalytics(NGODashboardProvider provider) {
    final communityData = [
      {'metric': 'Members', 'value': provider.communityMembers, 'color': Colors.green},
      {'metric': 'Volunteer Hours', 'value': provider.volunteerHours, 'color': Colors.blue},
      {'metric': 'Active Events', 'value': provider.activeEvents, 'color': Colors.orange},
      {'metric': 'Completed Projects', 'value': provider.completedProjects, 'color': Colors.purple},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Engagement',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCommunityMetrics(communityData),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityMetrics(List<Map<String, dynamic>> data) {
    return Column(
      children: data.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: item['color'].withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item['color'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getMetricIcon(item['metric']),
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['metric'],
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['value'].toString(),
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: item['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceMetrics(NGODashboardProvider provider) {
    final budgetUtilization = provider.totalBudget > 0 
        ? (provider.budgetUtilized / provider.totalBudget * 100).toDouble()
        : 0.0;

    final eventCompletionRate = provider.events.isNotEmpty
        ? (provider.completedProjects / provider.events.length * 100).toDouble()
        : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressMetric(
              'Budget Utilization',
              '${budgetUtilization.toStringAsFixed(1)}%',
              budgetUtilization / 100,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildProgressMetric(
              'Event Completion Rate',
              '${eventCompletionRate.toStringAsFixed(1)}%',
              eventCompletionRate / 100,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildProgressMetric(
              'Sponsorship Success',
              '${provider.activeSponsors}/${provider.totalSponsors} Active',
              provider.totalSponsors > 0 ? provider.activeSponsors / provider.totalSponsors : 0,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  IconData _getMetricIcon(String metric) {
    switch (metric) {
      case 'Members':
        return Icons.people;
      case 'Volunteer Hours':
        return Icons.access_time;
      case 'Active Events':
        return Icons.event;
      case 'Completed Projects':
        return Icons.assignment_turned_in;
      default:
        return Icons.analytics;
    }
  }
}

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final int total;

  _PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -90 * (3.141592653589793 / 180); // Start from top
    
    for (final item in data) {
      final sweepAngle = (item['count'] / total) * 360 * (3.141592653589793 / 180);
      
      final paint = Paint()
        ..color = item['color']
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw outer circle
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius - 10, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}