import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_green_mapper/core/utils/theme.dart';
import 'package:urban_green_mapper/features/dashboard/providers/ngo_dashboard_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:urban_green_mapper/features/dashboard/utils/dashboard_colors.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedTimeRange = 'monthly';
  final List<String> _timeRanges = ['weekly', 'monthly', 'quarterly', 'yearly'];
  // Interaction state for charts
  int? _touchedEventPieIndex;
  int? _touchedSponsorBarIndex;

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
        backgroundColor: DashboardColors.safeGreen(700),
        foregroundColor: DashboardColors.primaryWhite,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => dashboardProvider.loadDashboardData(),
          ),
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
          : RefreshIndicator(
              onRefresh: () => dashboardProvider.loadDashboardData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCards(dashboardProvider),
                    const SizedBox(height: 16),
                    _buildEventAnalytics(dashboardProvider),
                    const SizedBox(height: 16),
                    _buildSponsorshipAnalytics(dashboardProvider),
                    const SizedBox(height: 16),
                    _buildCommunityAnalytics(dashboardProvider),
                    const SizedBox(height: 16),
                    _buildPerformanceMetrics(dashboardProvider),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards(NGODashboardProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 1;
        if (width > 1000) columns = 4;
        else if (width > 700) columns = 2;
        final gap = 16.0;
        final cardWidth = (width - ((columns - 1) * gap)) / columns;

        final items = [
          _buildSummaryCard('Total Events', provider.events.length.toString(), Icons.event, DashboardColors.primaryBlue),
          _buildSummaryCard('Active Sponsors', provider.activeSponsors.toString(), Icons.business, DashboardColors.primaryGreen),
          _buildSummaryCard('Total Funding', '\$${provider.totalSponsorshipAmount.toStringAsFixed(2)}', Icons.attach_money, DashboardColors.primaryOrange),
          _buildSummaryCard('Community Members', provider.communityMembers.toString(), Icons.people, DashboardColors.primaryPurple),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((w) => SizedBox(width: cardWidth.clamp(220.0, 420.0), child: w)).toList(),
        );
      },
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
                color: _applyOpacity(color, 0.1),
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
                color: DashboardColors.safeGrey(600),
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
      {'status': 'Upcoming', 'count': provider.events.where((e) => e.status == 'upcoming').length, 'color': DashboardColors.statusUpcoming},
      {'status': 'Ongoing', 'count': provider.events.where((e) => e.status == 'ongoing').length, 'color': DashboardColors.statusOngoing},
      {'status': 'Completed', 'count': provider.events.where((e) => e.status == 'completed').length, 'color': DashboardColors.statusCompleted},
      {'status': 'Cancelled', 'count': provider.events.where((e) => e.status == 'cancelled').length, 'color': DashboardColors.statusCancelled},
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
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final value = (item['count'] as num).toDouble();
      final isTouched = _touchedEventPieIndex == i;
      sections.add(PieChartSectionData(
        value: value,
        color: item['color'] as Color,
        radius: isTouched ? 54 : 46,
        title: isTouched ? '${((value / (total == 0 ? 1 : total)) * 100).toStringAsFixed(0)}%' : '',
        titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        showTitle: isTouched,
      ));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 44,
              sectionsSpace: 4,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (response == null || response.touchedSection == null) {
                    setState(() => _touchedEventPieIndex = null);
                    return;
                  }
                  setState(() => _touchedEventPieIndex = response.touchedSection!.touchedSectionIndex);
                },
              ),
            ),
          ),
        ),
        // Center text (summary / tooltip)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _touchedEventPieIndex != null ? data[_touchedEventPieIndex!]['count'].toString() : total.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: DashboardColors.primaryGreen),
            ),
            Text(
              _touchedEventPieIndex != null ? data[_touchedEventPieIndex!]['status'] : 'Total Events',
              style: AppTheme.textTheme.bodySmall?.copyWith(color: DashboardColors.safeGrey(600)),
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
      {'tier': 'Bronze', 'count': provider.bronzeSponsors, 'color': DashboardColors.tierBronze},
      {'tier': 'Silver', 'count': provider.silverSponsors, 'color': DashboardColors.tierSilver},
      {'tier': 'Gold', 'count': provider.goldSponsors, 'color': DashboardColors.tierGold},
      {'tier': 'Platinum', 'count': provider.platinumSponsors, 'color': DashboardColors.tierPlatinum},
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
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final value = (item['count'] as num).toDouble();
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: value, color: item['color'] as Color, width: 22, borderRadius: BorderRadius.circular(6))],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: bars,
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return SideTitleWidget(axisSide: meta.axisSide, child: Text(data[idx]['tier'].toString(), style: AppTheme.textTheme.bodySmall));
                }, reservedSize: 36)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (response == null || response.spot == null) {
                    setState(() => _touchedSponsorBarIndex = null);
                    return;
                  }
                  setState(() => _touchedSponsorBarIndex = response.spot!.touchedBarGroupIndex);
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final tier = data[group.x.toInt()]['tier'];
                    return BarTooltipItem('$tier\n${rod.toY.toInt()}', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Total Sponsors: $total', style: AppTheme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: DashboardColors.safeGreen(700))),
        if (_touchedSponsorBarIndex != null && _touchedSponsorBarIndex! >= 0)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              '${data[_touchedSponsorBarIndex!]['tier']}: ${data[_touchedSponsorBarIndex!]['count']}',
              style: AppTheme.textTheme.labelSmall?.copyWith(color: DashboardColors.safeGrey(700)),
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
      {'metric': 'Members', 'value': provider.communityMembers, 'color': DashboardColors.safeGreen(600)},
      {'metric': 'Volunteer Hours', 'value': provider.volunteerHours, 'color': DashboardColors.safeBlue(600)},
      {'metric': 'Active Events', 'value': provider.activeEvents, 'color': DashboardColors.safeOrange(600)},
      {'metric': 'Completed Projects', 'value': provider.completedProjects, 'color': DashboardColors.safePurple(600)},
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
            color: _applyOpacity(item['color'] as Color, 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _applyOpacity(item['color'] as Color, 0.3)),
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
              DashboardColors.safeGreen(700),
            ),
            const SizedBox(height: 12),
            _buildProgressMetric(
              'Event Completion Rate',
              '${eventCompletionRate.toStringAsFixed(1)}%',
              eventCompletionRate / 100,
              DashboardColors.safeBlue(700),
            ),
            const SizedBox(height: 12),
            _buildProgressMetric(
              'Sponsorship Success',
              '${provider.activeSponsors}/${provider.totalSponsors} Active',
              provider.totalSponsors > 0 ? provider.activeSponsors / provider.totalSponsors : 0,
              DashboardColors.safeOrange(700),
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
          backgroundColor: DashboardColors.safeGrey(200),
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

  // Helper to apply opacity without using deprecated APIs
  Color _applyOpacity(Color color, double opacity) {
    final alpha = (opacity * 255).clamp(0, 255).toInt();
    return color.withAlpha(alpha);
  }
}