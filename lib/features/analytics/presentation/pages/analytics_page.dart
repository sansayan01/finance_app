import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../../members/data/models/member_model.dart';
import '../providers/analytics_providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final selectedPeriod = ref.watch(analyticsPeriodProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildPeriodSelector(ref, selectedPeriod, theme),
          const SizedBox(height: 24),
          analyticsAsync.when(
            data: (stats) => Column(
              children: [
                _buildPortfolioOverview(stats, theme),
                const SizedBox(height: 24),
                _buildSavingsAnalytics(stats, theme),
                const SizedBox(height: 24),
                _buildDisbursementVsCollection(context, stats, theme),
                const SizedBox(height: 24),
                _buildPortfolioTrend(context, stats, theme),
                const SizedBox(height: 24),
                _buildMemberInsights(stats, theme),
                const SizedBox(height: 24),
                _buildFinancialHealth(stats, theme),
                const SizedBox(height: 24),
                if (stats.upcomingMaturities.isNotEmpty) ...[
                  _buildUpcomingMaturities(stats, theme),
                  const SizedBox(height: 24),
                ],
                _buildDelinquencyAnalysis(stats, theme),
              ],
            ),
            loading: () => Column(
              children: List.generate(
                7,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: ShimmerCard(height: 220),
                ),
              ),
            ),
            error: (err, _) => _buildErrorState(err, theme),
          ),
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
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Portfolio insights and performance metrics',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildPeriodSelector(
      WidgetRef ref, AnalyticsPeriod selected, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = period == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () =>
                  ref.read(analyticsPeriodProvider.notifier).state = period,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.12)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : theme.dividerColor.withValues(alpha: 0.2),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color:
                        isSelected ? primary : theme.textTheme.bodySmall?.color,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildPortfolioOverview(AnalyticsStats stats, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: 'Total Disbursement',
            value: AppFormatters.formatCompactCurrency(stats.totalDisbursed),
            change: _formatChange(stats.disbursementChange),
            isPositive: stats.disbursementChange >= 0,
            chartData: stats.monthlyDisbursements,
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: 'Total Collection',
            value: AppFormatters.formatCompactCurrency(stats.totalCollected),
            change: _formatChange(stats.collectionChange),
            isPositive: stats.collectionChange >= 0,
            chartData: stats.monthlyCollections,
            theme: theme,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  String _formatChange(double value) {
    if (value == 0) return '--';
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(1)}%';
  }

  Widget _buildSavingsAnalytics(AnalyticsStats stats, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Savings Analytics',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total Savings',
                value: AppFormatters.formatCompactCurrency(stats.totalSavings),
                icon: Icons.savings_outlined,
                color: successColor,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Active Accounts',
                value: stats.activeSavingsAccounts.toString(),
                icon: Icons.people_outline,
                color: AppColors.primary,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Interest Earned',
                value:
                    AppFormatters.formatCompactCurrency(stats.interestEarned),
                icon: Icons.trending_up_outlined,
                color: AppColors.accentLight,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Avg Balance',
                value: AppFormatters.formatCompactCurrency(
                    stats.averageSavingsBalance),
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.info,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Maturities',
                value: stats.upcomingMaturities.length.toString(),
                icon: Icons.event_available_outlined,
                color: AppColors.orange,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDisbursementVsCollection(
      BuildContext context, AnalyticsStats stats, ThemeData theme) {
    final hasData = stats.monthlyDisbursements.isNotEmpty &&
        stats.monthlyCollections.isNotEmpty;
    final hasNonZero = stats.monthlyDisbursements.any((v) => v > 0) ||
        stats.monthlyCollections.any((v) => v > 0);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disbursement vs Collection',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (!hasNonZero)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Live',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (!hasData || !hasNonZero)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_outlined,
                        size: 48,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No transaction history yet',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/loans/new'),
                      child: const Text('Create First Loan'),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _computeMaxY(
                      stats.monthlyDisbursements, stats.monthlyCollections),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final monthNames = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec'
                          ];
                          final now = DateTime.now();
                          final idx = (now.month - 6 + value.toInt()) % 12;
                          final label = monthNames[idx < 0 ? idx + 12 : idx];
                          return Text(label,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups:
                      stats.monthlyDisbursements.asMap().entries.map((entry) {
                    final index = entry.key;
                    return _makeBarGroup(
                      index,
                      entry.value,
                      stats.monthlyCollections[index],
                      primary,
                      secondary,
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: primary, label: 'Disbursement', theme: theme),
              const SizedBox(width: 24),
              _LegendItem(color: secondary, label: 'Collection', theme: theme),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  double _computeMaxY(List<double> disbursed, List<double> collected) {
    final all = [...disbursed, ...collected];
    if (all.isEmpty) return 100;
    final max = all.reduce((a, b) => a > b ? a : b);
    return max > 0 ? max * 1.2 : 100;
  }

  BarChartGroupData _makeBarGroup(int x, double disbursement, double collection,
      Color primary, Color secondary) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: disbursement,
          color: primary,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: collection,
          color: secondary,
          width: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPortfolioTrend(
      BuildContext context, AnalyticsStats stats, ThemeData theme) {
    final hasData = stats.monthlyCollections.isNotEmpty &&
        stats.monthlyCollections.any((v) => v > 0);
    const trendColor = AppColors.success;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collection Trend',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: trendColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                          color: trendColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!hasData)
            SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart_outlined,
                        size: 48,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('Record transactions to see trends',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/savings/new'),
                      child: const Text('Record a Collection'),
                    ),
                  ],
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
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final monthNames = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec'
                          ];
                          final now = DateTime.now();
                          final idx = (now.month - 6 + value.toInt()) % 12;
                          final label = monthNames[idx < 0 ? idx + 12 : idx];
                          return Text(label,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            AppFormatters.formatCompactCurrency(value),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 9),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: stats.monthlyCollections.length.toDouble() - 1,
                  minY: 0,
                  maxY: _computeMaxY([], stats.monthlyCollections) * 0.8,
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.monthlyCollections
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
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
                          colors: [
                            trendColor.withValues(alpha: 0.3),
                            trendColor.withValues(alpha: 0.0)
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

  Widget _buildMemberInsights(AnalyticsStats stats, ThemeData theme) {
    final growthColor =
        stats.memberGrowthRate >= 0 ? AppColors.success : AppColors.error;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Member Insights',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: growthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      stats.memberGrowthRate >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14,
                      color: growthColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.memberGrowthRate >= 0 ? '+' : ''}${stats.memberGrowthRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: growthColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MemberStat(
                  value: stats.totalMembers.toString(),
                  label: 'Total Members',
                  icon: Icons.people_outline,
                  color: AppColors.primary,
                ),
              ),
              Container(
                  height: 40,
                  width: 1,
                  color: theme.dividerColor.withValues(alpha: 0.2)),
              Expanded(
                child: _MemberStat(
                  value: stats.newMembersThisPeriod.toString(),
                  label: 'New This Period',
                  icon: Icons.person_add_outlined,
                  color: AppColors.success,
                ),
              ),
              Container(
                  height: 40,
                  width: 1,
                  color: theme.dividerColor.withValues(alpha: 0.2)),
              Expanded(
                child: _MemberStat(
                  value: stats.activeMembers.toString(),
                  label: 'Verified KYC',
                  icon: Icons.verified_outlined,
                  color: AppColors.accentLight,
                ),
              ),
              Container(
                  height: 40,
                  width: 1,
                  color: theme.dividerColor.withValues(alpha: 0.2)),
              Expanded(
                child: _MemberStat(
                  value: stats.pendingKYC.toString(),
                  label: 'Pending KYC',
                  icon: Icons.pending_outlined,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          if (stats.recentMembers.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Recent Members',
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Column(
              children: stats.recentMembers
                  .take(3)
                  .map((member) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.15),
                                    AppColors.primary.withValues(alpha: 0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  member.fullName.isNotEmpty
                                      ? member.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.fullName,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    member.phone,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: member.kycStatus == KYCStatus.verified
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                member.kycStatus == KYCStatus.verified
                                    ? 'Verified'
                                    : 'Pending',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: member.kycStatus == KYCStatus.verified
                                      ? AppColors.success
                                      : AppColors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFinancialHealth(AnalyticsStats stats, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Health',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _HealthScoreCard(
                label: 'Collection Efficiency',
                value: stats.collectionEfficiency,
                icon: Icons.speed_outlined,
                color: AppColors.success,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HealthScoreCard(
                label: 'Portfolio Yield',
                value: stats.portfolioYield,
                icon: Icons.pie_chart_outline_outlined,
                color: AppColors.primary,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _HealthScoreCard(
                label: 'NPL Ratio',
                value: stats.nplRatio,
                icon: Icons.warning_amber_outlined,
                color: stats.nplRatio > 5 ? AppColors.error : AppColors.warning,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HealthScoreCard(
                label: 'Liquidity Ratio',
                value: stats.liquidityRatio,
                icon: Icons.water_drop_outlined,
                color: stats.liquidityRatio > 100
                    ? AppColors.success
                    : AppColors.info,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildUpcomingMaturities(AnalyticsStats stats, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_outlined,
                  size: 20, color: AppColors.orange),
              const SizedBox(width: 10),
              Text(
                'Upcoming Maturities',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats.upcomingMaturities.length} plans',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: stats.upcomingMaturities
                .take(3)
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.orange.withValues(alpha: 0.15),
                                  AppColors.orange.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.savings_outlined,
                                size: 18, color: AppColors.orange),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.memberName,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${AppFormatters.formatDate(s.maturityDate)} \u2022 ${s.maturityDate.difference(DateTime.now()).inDays} days left',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatters.formatCurrency(s.targetAmount),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.orange,
                                ),
                              ),
                              Text(
                                AppFormatters.formatCurrency(s.currentAmount),
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDelinquencyAnalysis(AnalyticsStats stats, ThemeData theme) {
    const successColor = AppColors.success;
    const errorColor = AppColors.error;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delinquency Analysis',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _DelinquencyChart(
                      parPercentage: stats.parPercentage, theme: theme)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _DelinquencyItem(
                      label: 'Current',
                      amount: stats.totalDisbursed -
                          (stats.totalDisbursed * stats.parPercentage / 100),
                      percentage: 100 - stats.parPercentage,
                      color: successColor,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
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
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildErrorState(Object err, ThemeData theme) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
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
    final trendColor = change == '--'
        ? theme.textTheme.bodySmall?.color
        : (isPositive ? AppColors.success : AppColors.error);
    final primary = theme.colorScheme.primary;
    final hasData = chartData.any((v) => v > 0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
              if (change != '--')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: trendColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change,
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 32,
            child: !hasData
                ? Row(
                    children: List.generate(
                      6,
                      (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 4 + (i % 3) * 8.0,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: chartData.asMap().entries.map((entry) {
                      final maxVal = chartData.reduce((a, b) => a > b ? a : b);
                      if (maxVal == 0) return Expanded(child: Container());
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: (entry.value / maxVal) * 32,
                          decoration: BoxDecoration(
                            color: primary.withValues(
                                alpha:
                                    0.3 + (entry.key / chartData.length) * 0.5),
                            borderRadius: BorderRadius.circular(3),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MemberStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MemberStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _HealthScoreCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
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

  const _LegendItem(
      {required this.color, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
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
    const successColor = AppColors.success;
    const errorColor = AppColors.error;

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
                  color: successColor,
                  radius: 25,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: parPercentage,
                  color: errorColor,
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
                  color: errorColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text('PAR',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              Text(
                AppFormatters.formatCompactCurrency(amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
