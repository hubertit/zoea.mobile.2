import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  final _periods = ['Today', 'This Week', 'This Month', 'This Year'];

  // Mock data
  final _stats = {
    'revenue': 2450000.0,
    'bookings': 156,
    'views': 3420,
    'conversion': 4.56,
  };

  final _revenueByCategory = [
    {'category': 'Accommodation', 'amount': 1200000.0, 'percentage': 49},
    {'category': 'Dining', 'amount': 650000.0, 'percentage': 27},
    {'category': 'Tours', 'amount': 400000.0, 'percentage': 16},
    {'category': 'Events', 'amount': 200000.0, 'percentage': 8},
  ];

  final _recentActivity = [
    {'type': 'booking', 'title': 'New booking', 'subtitle': 'Deluxe Room - 2 nights', 'amount': 180000.0, 'time': '2h ago'},
    {'type': 'payment', 'title': 'Payment received', 'subtitle': 'Table for 4 - Dinner', 'amount': 45000.0, 'time': '4h ago'},
    {'type': 'review', 'title': 'New review', 'subtitle': '5 stars - "Amazing experience!"', 'amount': null, 'time': '6h ago'},
    {'type': 'booking', 'title': 'New booking', 'subtitle': 'City Tour - 4 guests', 'amount': 120000.0, 'time': '1d ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Analytics',
          style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showExportOptions,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: AppTheme.spacing20),

            // Key Stats
            _buildKeyStats(),
            const SizedBox(height: AppTheme.spacing24),

            // Revenue Breakdown
            _buildSectionTitle('Revenue Breakdown'),
            const SizedBox(height: AppTheme.spacing12),
            _buildRevenueBreakdown(),
            const SizedBox(height: AppTheme.spacing24),

            // Performance Chart Placeholder
            _buildSectionTitle('Performance'),
            const SizedBox(height: AppTheme.spacing12),
            _buildPerformanceChart(),
            const SizedBox(height: AppTheme.spacing24),

            // Recent Activity
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: AppTheme.spacing12),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacing8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPeriod = period),
              backgroundColor: AppTheme.cardColor,
              selectedColor: AppTheme.primaryColor,
              labelStyle: AppTheme.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppTheme.primaryTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Revenue',
            value: 'RWF ${NumberFormat.compact().format(_stats['revenue'])}',
            icon: Icons.trending_up,
            iconColor: AppTheme.successColor,
            change: '+12.5%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _StatCard(
            title: 'Bookings',
            value: '${_stats['bookings']}',
            icon: Icons.calendar_today,
            iconColor: AppTheme.primaryColor,
            change: '+8.2%',
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRevenueBreakdown() {
    return AppCard(
      child: Column(
        children: _revenueByCategory.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == _revenueByCategory.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item['category'] as String,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item['percentage'] as int) / 100,
                        backgroundColor: AppTheme.dividerColor,
                        valueColor: AlwaysStoppedAnimation(
                          _getCategoryColor(entry.key),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'RWF ${NumberFormat.compact().format(item['amount'])}',
                      style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: AppTheme.spacing16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    // Simple bar chart placeholder
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLegend('Bookings', AppTheme.primaryColor),
              _buildChartLegend('Revenue', AppTheme.successColor),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final bookingHeight = [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.75][index];
                final revenueHeight = [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 0.7][index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 150 * bookingHeight,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Container(
                            height: 150 * revenueHeight,
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Text(d, style: AppTheme.labelSmall))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: _recentActivity.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
            border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getActivityColor(activity['type'] as String).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getActivityIcon(activity['type'] as String),
                  size: 20,
                  color: _getActivityColor(activity['type'] as String),
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      activity['subtitle'] as String,
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (activity['amount'] != null)
                    Text(
                      '+RWF ${NumberFormat.compact().format(activity['amount'])}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    activity['time'] as String,
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      Colors.orange,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'payment':
        return Icons.payment;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'booking':
        return AppTheme.primaryColor;
      case 'payment':
        return AppTheme.successColor;
      case 'review':
        return Colors.amber;
      default:
        return AppTheme.secondaryTextColor;
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  AppTheme.successSnackBar(message: 'Report exported as PDF'),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  AppTheme.successSnackBar(message: 'Report exported as CSV'),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String change;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius12),
        border: Border.all(color: AppTheme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: AppTheme.labelSmall.copyWith(
                    color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            value,
            style: AppTheme.headlineSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(title, style: AppTheme.labelSmall),
        ],
      ),
    );
  }
}

