import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/analytics_providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildPeriodSelector(),
          const SizedBox(height: AppSpacing.lg),
          analyticsAsync.when(
            data: (stats) => Column(
              children: [
                _buildPortfolioOverview(stats),
                const SizedBox(height: AppSpacing.lg),
                _buildDisbursementVsCollection(stats),
                const SizedBox(height: AppSpacing.lg),
                _buildPortfolioTrend(stats),
                const SizedBox(height: AppSpacing.lg),
                _buildDelinquencyAnalysis(stats),
              ],
            ),
            loading: () => Column(
              children: List.generate(
                4,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  child: ShimmerCard(height: 200),
                ),
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error loading analytics: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Portfolio insights and performance metrics',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(label: 'This Month', isSelected: true),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'Last Quarter'),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'YTD'),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'All Time'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPortfolioOverview(PortfolioStats stats) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: 'Total Disbursement',
            value: AppFormatters.formatCompactCurrency(stats.totalDisbursed),
            change: '--',
            isPositive: true,
            chartData: stats.monthlyDisbursements,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _OverviewCard(
            title: 'Total Collection',
            value: AppFormatters.formatCompactCurrency(stats.totalCollected),
            change: '--',
            isPositive: true,
            chartData: stats.monthlyCollections,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDisbursementVsCollection(PortfolioStats stats) {
    final hasData = stats.monthlyDisbursements.isNotEmpty && stats.monthlyCollections.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disbursement vs Collection',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!hasData)
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No historical data available',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() >= titles.length) return const SizedBox.shrink();
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: stats.monthlyDisbursements.asMap().entries.map((entry) {
                    final index = entry.key;
                    return _makeBarGroup(index, entry.value, stats.monthlyCollections[index]);
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.primaryTeal, label: 'Disbursement'),
              const SizedBox(width: AppSpacing.lg),
              _LegendItem(color: AppColors.primaryIndigo, label: 'Collection'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  BarChartGroupData _makeBarGroup(int x, double disbursement, double collection) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: disbursement,
          color: AppColors.primaryTeal,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: collection,
          color: AppColors.primaryIndigo,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPortfolioTrend(PortfolioStats stats) {
    final hasData = stats.monthlyCollections.isNotEmpty;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Growth Trend',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!hasData)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Insufficient trend data',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.glassBorder,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}M',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: stats.monthlyCollections.length.toDouble() - 1,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.monthlyCollections.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: AppColors.success,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.success.withValues(alpha: 0.3),
                            AppColors.success.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDelinquencyAnalysis(PortfolioStats stats) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delinquency Analysis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _DelinquencyChart(parPercentage: stats.parPercentage),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _DelinquencyItem(
                      label: 'Current',
                      amount: stats.totalDisbursed - (stats.totalDisbursed * stats.parPercentage / 100),
                      percentage: 100 - stats.parPercentage,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DelinquencyItem(
                      label: 'PAR (Overdue)',
                      amount: stats.totalDisbursed * stats.parPercentage / 100,
                      percentage: stats.parPercentage,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _PeriodChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: AppSpacing.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryIndigo.withValues(alpha: 0.2)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primaryIndigo : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final List<double> chartData;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 30,
            child: chartData.isEmpty 
              ? const SizedBox.shrink()
              : Row(
                  children: chartData.asMap().entries.map((entry) {
                    final maxVal = chartData.reduce((a, b) => a > b ? a : b);
                    if (maxVal == 0) return Expanded(child: Container());
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: (entry.value / maxVal) * 30,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.3 + (entry.key / chartData.length) * 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DelinquencyChart extends StatelessWidget {
  final double parPercentage;

  const _DelinquencyChart({required this.parPercentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 45,
              sections: [
                PieChartSectionData(
                  value: 100 - parPercentage,
                  color: AppColors.success,
                  radius: 25,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: parPercentage,
                  color: AppColors.error,
                  radius: 25,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${parPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'PAR',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DelinquencyItem extends StatelessWidget {
  final String label;
  final double amount;
  final double percentage;
  final Color color;

  const _DelinquencyItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                AppFormatters.formatCompactCurrency(amount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}