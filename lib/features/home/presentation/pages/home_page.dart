import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 28),
          _buildHeroCard(context, ref),
          const SizedBox(height: 28),
          _buildQuickActions(context),
          const SizedBox(height: 28),
          _buildActiveLoansSection(context, ref),
          const SizedBox(height: 28),
          _buildSavingsSection(context, ref),
          const SizedBox(height: 28),
          _buildRecentTransactions(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.fullName ?? 'User',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _HeaderIconBtn(icon: Icons.notifications_outlined, onTap: () {}),
            const SizedBox(width: 12),
            _HeaderIconBtn(icon: Icons.search_rounded, onTap: () {}),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildHeroCard(BuildContext context, WidgetRef ref) {
    final loanSummaryAsync = ref.watch(loanSummaryProvider);
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return loanSummaryAsync.when(
      data: (summary) {
        final collected = todayStatsAsync.valueOrNull?['collected'] as double? ?? 0.0;
        return GlassCard(
          elevated: true,
          backgroundColor: isDark ? const Color(0xFF1E2230) : null,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live Portfolio',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: theme.textTheme.bodySmall?.color, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppFormatters.formatCompactCurrency(summary.totalOutstanding),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Outstanding',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      label: 'Active Members',
                      value: summary.activeLoans.toString(),
                      icon: Icons.people_rounded,
                      color: AppColors.accentLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: "Today's Collection",
                      value: AppFormatters.formatCompactCurrency(collected),
                      icon: Icons.payments_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeroStat(
                      label: 'PAR Rate',
                      value: '${summary.parPercentage.toStringAsFixed(1)}%',
                      icon: Icons.trending_down_rounded,
                      color: summary.parPercentage > 5 ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerCard(height: 220),
      error: (_, __) => GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Unable to load dashboard', style: theme.textTheme.bodySmall),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06, end: 0);
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Member',
                color: primary,
                onTap: onQuickAction,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.request_quote_rounded,
                label: 'Loan',
                color: AppColors.accent,
                onTap: () {
                  try { GoRouter.of(context).push('/loans/new'); } catch (_) { onQuickAction(); }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.savings_rounded,
                label: 'Deposit',
                color: AppColors.success,
                onTap: onQuickAction,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionBtn(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan',
                color: AppColors.orange,
                onTap: onQuickAction,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildActiveLoansSection(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(dashboardLoansProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Loans',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: onViewAllLoans,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'View All',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        loansAsync.when(
          data: (loans) {
            if (loans.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('No active loans', style: theme.textTheme.bodySmall),
                ),
              );
            }
            return Column(
              children: loans.take(3).map((loan) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LoanCard(loan: loan),
              )).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(2, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerCard(height: 160),
            )),
          ),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Unable to load loans', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSavingsSection(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(dashboardSavingsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Savings Progress',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: onViewAllSavings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'View All',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        savingsAsync.when(
          data: (savings) {
            if (savings.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('No active savings plans', style: theme.textTheme.bodySmall),
                ),
              );
            }
            return Row(
              children: savings.take(2).map((saving) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: saving == savings.last ? 0 : 12),
                  child: _SavingsCard(saving: saving),
                ),
              )).toList(),
            );
          },
          loading: () => const ShimmerStatsRow(itemCount: 2),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Unable to load savings', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(dashboardTransactionsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('No recent transactions', style: theme.textTheme.bodySmall),
                ),
              );
            }
            return GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Column(
                    children: [
                      _buildTransactionItem(context, transaction),
                      if (index < transactions.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerCard(height: 200),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Unable to load transactions', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    final theme = Theme.of(context);
    final isDeposit = transaction.type == TransactionType.emiPayment || transaction.type == TransactionType.savingsDeposit;
    final icon = isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final iconColor = isDeposit ? AppColors.success : AppColors.error;

    String title;
    switch (transaction.type) {
      case TransactionType.emiPayment: title = 'EMI Payment - ${transaction.memberName}'; break;
      case TransactionType.loanDisbursement: title = 'Loan Disbursement - ${transaction.memberName}'; break;
      case TransactionType.savingsDeposit: title = 'Savings Deposit - ${transaction.memberName}'; break;
      case TransactionType.savingsWithdrawal: title = 'Savings Withdrawal - ${transaction.memberName}'; break;
      case TransactionType.penalty: title = 'Penalty - ${transaction.memberName}'; break;
      default: title = transaction.description ?? 'Transaction';
    }

    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatters.formatRelativeTime(transaction.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          AppFormatters.formatCurrency(transaction.amount),
          style: TextStyle(
            color: iconColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Sub-Widgets ───

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            width: 0.5,
          ),
        ),
        child: Icon(icon, size: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _HeroStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
      borderRadius: 20,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
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
    final theme = Theme.of(context);
    final progress = 1 - (loan.outstandingBalance / loan.amount);
    final statusType = loan.status == LoanStatus.active
        ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus
            ? StatusType.defaultStatus
            : StatusType.pending;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () {},
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    (loan.customerName ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.customerName ?? 'Unknown',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan.loanNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LoanStat(label: 'Principal', value: AppFormatters.formatCompactCurrency(loan.amount)),
              _LoanStat(label: 'EMI', value: AppFormatters.formatCurrency(loan.emiAmount)),
              _LoanStat(label: 'Outstanding', value: AppFormatters.formatCompactCurrency(loan.outstandingBalance)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanStat extends StatelessWidget {
  final String label;
  final String value;
  const _LoanStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final SavingsModel saving;
  const _SavingsCard({required this.saving});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = saving.currentAmount / saving.targetAmount;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withValues(alpha: 0.15),
                      AppColors.success.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  saving.memberName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ProgressGauge(
              value: progress.clamp(0.0, 1.0),
              size: 64,
              strokeWidth: 5,
              progressColor: AppColors.success,
              center: Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppFormatters.formatCurrency(saving.currentAmount),
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              'of ${AppFormatters.formatCompactCurrency(saving.targetAmount)}',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}