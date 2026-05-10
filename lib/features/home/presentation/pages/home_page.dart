import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../loans/data/models/loan_model.dart';
import '../../../savings/data/models/savings_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../data/providers/dashboard_providers.dart';
import '../../../../core/constants/enums.dart';

class HomePage extends ConsumerWidget {
  final VoidCallback onViewAllLoans;
  final VoidCallback onViewAllSavings;
  final VoidCallback onQuickAction;

  const HomePage({
    super.key,
    required this.onViewAllLoans,
    required this.onViewAllSavings,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildKPICards(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildTodaysTasks(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActions(context),
          const SizedBox(height: AppSpacing.lg),
          _buildActiveLoansSection(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildSavingsSection(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildRecentTransactions(ref),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Morning',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user?.fullName ?? 'User',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderIcon(Icons.notifications_outlined),
            const SizedBox(width: AppSpacing.sm),
            _buildHeaderIcon(Icons.search),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 20),
    );
  }

  Widget _buildKPICards(WidgetRef ref) {
    final loanSummaryAsync = ref.watch(loanSummaryProvider);
    final todayStatsAsync = ref.watch(todayStatsProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: loanSummaryAsync.when(
                data: (summary) => _KPICard(
                  title: 'Total Outstanding',
                  value: AppFormatters.formatCompactCurrency(summary.totalOutstanding),
                  subtitle: summary.parPercentage > 0
                      ? '${summary.parPercentage.toStringAsFixed(1)}% PAR'
                      : 'No overdue',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.primaryTeal,
                  trend: Trend.neutral,
                ),
                loading: () => const ShimmerCard(height: 120),
                error: (_, __) => _KPICard(
                  title: 'Total Outstanding',
                  value: '--',
                  subtitle: 'Unable to load',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.primaryTeal,
                  trend: Trend.neutral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: loanSummaryAsync.when(
                data: (summary) => _KPICard(
                  title: 'Active Members',
                  value: summary.activeLoans.toString(),
                  subtitle: '${summary.defaultLoans} defaults',
                  icon: Icons.people,
                  color: AppColors.primaryPurple,
                  trend: Trend.neutral,
                ),
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => _KPICard(
                  title: 'Active Members',
                  value: '--',
                  subtitle: 'Unable to load',
                  icon: Icons.people,
                  color: AppColors.primaryPurple,
                  trend: Trend.neutral,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: todayStatsAsync.when(
                data: (stats) {
                  final collected = (stats['collected'] as num?)?.toDouble() ?? 0;
                  final count = stats['collectionCount'] as int? ?? 0;
                  return _KPICard(
                    title: "Today's Collection",
                    value: AppFormatters.formatCurrency(collected),
                    subtitle: '$count collections',
                    icon: Icons.payments,
                    color: AppColors.success,
                    trend: Trend.neutral,
                  );
                },
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => _KPICard(
                  title: "Today's Collection",
                  value: '--',
                  subtitle: 'Unable to load',
                  icon: Icons.payments,
                  color: AppColors.success,
                  trend: Trend.neutral,
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTodaysTasks(WidgetRef ref) {
    final todayStatsAsync = ref.watch(todayStatsProvider);

    return todayStatsAsync.when(
      data: (stats) {
        final count = stats['collectionCount'] as int? ?? 0;
        final totalDue = stats['totalDue'] as int? ?? 0;
        final completed = count;
        final pending = totalDue > 0 ? totalDue - count : 0;

        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Tasks",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
                    ),
                    child: Text(
                      totalDue > 0 ? '${((count / totalDue) * 100).toInt()}%' : '0%',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressBar(
                value: totalDue > 0 ? (count / totalDue).clamp(0.0, 1.0) : 0.0,
                height: 8,
                progressColor: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _buildTaskStat('$completed', 'Completed', AppColors.success),
                  const SizedBox(width: AppSpacing.lg),
                  _buildTaskStat('$pending', 'Pending', AppColors.warning),
                  const SizedBox(width: AppSpacing.lg),
                  _buildTaskStat('0', 'Overdue', AppColors.error),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerCard(height: 140),
      error: (_, __) => GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Today's Tasks",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'Unable to load tasks',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTaskStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.person_add_alt,
                label: 'New Member',
                onTap: onQuickAction,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.request_quote,
                label: 'New Loan',
                onTap: () {
                  // Direct navigation to the new loan application
                  // Using GoRouter requires checking if the context has GoRouter
                  try {
                    GoRouter.of(context).push('/loans/new');
                  } catch (e) {
                    onQuickAction();
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.savings,
                label: 'Deposit',
                onTap: onQuickAction,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan Pay',
                onTap: onQuickAction,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActiveLoansSection(WidgetRef ref) {
    final loansAsync = ref.watch(dashboardLoansProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Loans',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAllLoans,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        loansAsync.when(
          data: (loans) {
            if (loans.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Center(
                  child: Text(
                    'No active loans',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return Column(
              children: loans.take(2).map((loan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LoanCard(
                    loan: loan,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: const ShimmerCard(height: 160),
              ),
            ),
          ),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'Unable to load loans',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSavingsSection(WidgetRef ref) {
    final savingsAsync = ref.watch(dashboardSavingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Progress',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onViewAllSavings,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        savingsAsync.when(
          data: (savings) {
            if (savings.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Center(
                  child: Text(
                    'No active savings plans',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return Row(
              children: savings.take(2).map((saving) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _SavingsCard(saving: saving),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const ShimmerStatsRow(itemCount: 2),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'Unable to load savings',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecentTransactions(WidgetRef ref) {
    final transactionsAsync = ref.watch(dashboardTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Center(
                  child: Text(
                    'No recent transactions',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Column(
                    children: [
                      _buildTransactionItem(transaction),
                      if (index < transactions.length - 1)
                        const Divider(color: AppColors.glassBorder, height: 24),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerCard(height: 180),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'Unable to load transactions',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isDeposit = transaction.type == TransactionType.emiPayment ||
        transaction.type == TransactionType.savingsDeposit;
    final icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isDeposit ? AppColors.success : AppColors.error;

    String title;
    switch (transaction.type) {
      case TransactionType.emiPayment:
        title = 'EMI Payment - ${transaction.memberName}';
        break;
      case TransactionType.loanDisbursement:
        title = 'Loan Disbursement - ${transaction.memberName}';
        break;
      case TransactionType.savingsDeposit:
        title = 'Savings Deposit - ${transaction.memberName}';
        break;
      case TransactionType.savingsWithdrawal:
        title = 'Savings Withdrawal - ${transaction.memberName}';
        break;
      case TransactionType.penalty:
        title = 'Penalty - ${transaction.memberName}';
        break;
      default:
        title = transaction.description ?? 'Transaction';
    }

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                AppFormatters.formatRelativeTime(transaction.createdAt),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          AppFormatters.formatCurrency(transaction.amount),
          style: TextStyle(
            color: iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Trend trend;

  const _KPICard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.trend,
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (trend != Trend.neutral)
                Icon(
                  trend == Trend.up ? Icons.trending_up : Icons.trending_down,
                  color: trend == Trend.up ? AppColors.success : AppColors.error,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

enum Trend { up, down, neutral }

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 22),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (loan.outstandingBalance / loan.amount);
    final statusType = loan.status == LoanStatus.active
        ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus
            ? StatusType.defaultStatus
            : StatusType.pending;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {},
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                ),
                child: Center(
                  child: Text(
                    (loan.customerName?.isNotEmpty ?? false) ? loan.customerName![0] : '?',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.customerName ?? 'Unknown',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      loan.loanNumber,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: loan.status.name,
                type: statusType,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Outstanding',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(loan.outstandingBalance),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Principal',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(loan.amount),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressBar(
            value: progress.clamp(0.0, 1.0),
            height: 6,
            progressColor: statusType == StatusType.standard
                ? AppColors.success
                : AppColors.error,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% paid',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Text(
                '${loan.interestRate}% p.a.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final SavingsModel saving;

  const _SavingsCard({required this.saving});

  @override
  Widget build(BuildContext context) {
    final progress = saving.currentAmount / saving.targetAmount;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            saving.planName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ProgressGauge(
                value: progress.clamp(0.0, 1.0),
                size: 60,
                strokeWidth: 5,
                center: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatCompactCurrency(saving.currentAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'of ${AppFormatters.formatCompactCurrency(saving.targetAmount)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Maturity: ${AppFormatters.formatShortDate(saving.maturityDate)}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}