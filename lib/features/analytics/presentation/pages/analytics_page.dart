import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildPeriodSelector(theme),
          const SizedBox(height: AppSpacing.lg),
          analyticsAsync.when(
            data: (stats) => Column(
              children: [
                _buildPortfolioOverview(stats, theme),
                const SizedBox(height: AppSpacing.lg),
                _buildDisbursementVsCollection(stats, theme),
                const SizedBox(height: AppSpacing.lg),
                _buildPortfolioTrend(stats, theme),
                const SizedBox(height: AppSpacing.lg),
                _buildDelinquencyAnalysis(stats, theme),
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
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          'Portfolio insights and performance metrics',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _PeriodChip(label: 'This Month', isSelected: true, primary: primary, isDark: isDark, theme: theme),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'Last Quarter', primary: primary, isDark: isDark, theme: theme),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'YTD', primary: primary, isDark: isDark, theme: theme),
          const SizedBox(width: AppSpacing.sm),
          _PeriodChip(label: 'All Time', primary: primary, isDark: isDark, theme: theme),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPortfolioOverview(PortfolioStats stats, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: 'Total Disbursement',
            value: AppFormatters.formatCompactCurrency(stats.totalDisbursed),
            change: '--',
            isPositive: true,
            chartData: stats.monthlyDisbursements,
            theme: theme,
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
            theme: theme,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDisbursementVsCollection(PortfolioStats stats, ThemeData theme) {
    final hasData = stats.monthlyDisbursements.isNotEmpty && stats.monthlyCollections.isNotEmpty;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disbursement vs Collection',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!hasData)
            SizedBox(
              height: 200,
              child: Center(child: Text('No historical data available', style: theme.textTheme.bodySmall)),
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
                          return Text(titles[value.toInt()], style: theme.textTheme.bodySmall?.copyWith(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: stats.monthlyDisbursements.asMap().entries.map((entry) {
                    final index = entry.key;
                    return _makeBarGroup(index, entry.value, stats.monthlyCollections[index], primary, secondary);
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: primary, label: 'Disbursement', theme: theme),
              const SizedBox(width: AppSpacing.lg),
              _LegendItem(color: secondary, label: 'Collection', theme: theme),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  BarChartGroupData _makeBarGroup(int x, double disbursement, double collection, Color primary, Color secondary) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: disbursement, color: primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        BarChartRodData(toY: collection, color: secondary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ],
    );
  }

  Widget _buildPortfolioTrend(PortfolioStats stats, ThemeData theme) {
    final hasData = stats.monthlyCollections.isNotEmpty;
    const trendColor = Color(0xFF34C759);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Savings Growth Trend',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!hasData)
            SizedBox(
              height: 180,
              child: Center(child: Text('Insufficient trend data', style: theme.textTheme.bodySmall)),
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
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}M', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10));
                        },
                        reservedSize: 35,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      color: trendColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [trendColor.withValues(alpha: 0.3), trendColor.withValues(alpha: 0.0)],
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

  Widget _buildDelinquencyAnalysis(PortfolioStats stats, ThemeData theme) {
    const successColor = Color(0xFF34C759);
    const errorColor = Color(0xFFFF3B30);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delinquency Analysis',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _DelinquencyChart(parPercentage: stats.parPercentage, theme: theme)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _DelinquencyItem(
                      label: 'Current',
                      amount: stats.totalDisbursed - (stats.totalDisbursed * stats.parPercentage / 100),
                      percentage: 100 - stats.parPercentage,
                      color: successColor,
                      theme: theme,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DelinquencyItem(
                      label: 'PAR (Overdue)',
                      amount: stats.totalDisbursed * stats.parPercentage / 100,
                      percentage: stats.parPercentage,
                      color: errorColor,
                      theme: theme,
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
  final Color primary;
  final bool isDark;
  final ThemeData theme;

  const _PeriodChip({required this.label, this.isSelected = false, required this.primary, required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: AppSpacing.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
          border: Border.all(color: isSelected ? primary : theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primary : theme.textTheme.bodySmall?.color,
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
  final ThemeData theme;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.chartData,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
    final primary = theme.colorScheme.primary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: trendColor, size: 10),
                    const SizedBox(width: 2),
                    Text(change, style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
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
                            color: primary.withValues(alpha: 0.3 + (entry.key / chartData.length) * 0.5),
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
  final ThemeData theme;

  const _LegendItem({required this.color, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _DelinquencyChart extends StatelessWidget {
  final double parPercentage;
  final ThemeData theme;

  const _DelinquencyChart({required this.parPercentage, required this.theme});

  @override
  Widget build(BuildContext context) {
    const successColor = Color(0xFF34C759);
    const errorColor = Color(0xFFFF3B30);

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
                PieChartSectionData(value: 100 - parPercentage, color: successColor, radius: 25, showTitle: false),
                PieChartSectionData(value: parPercentage, color: errorColor, radius: 25, showTitle: false),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${parPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(color: errorColor, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text('PAR', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
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
  final ThemeData theme;

  const _DelinquencyItem({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
              Text(AppFormatters.formatCompactCurrency(amount), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Text('$percentage%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}