import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 24),
          _buildKPICards(context, ref),
          const SizedBox(height: 24),
          _buildTodaysTasks(context, ref),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildActiveLoansSection(context, ref),
          const SizedBox(height: 24),
          _buildSavingsSection(context, ref),
          const SizedBox(height: 24),
          _buildRecentTransactions(context, ref),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              user?.fullName ?? 'User',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _HeaderIconBtn(icon: Icons.notifications_outlined, theme: theme),
            const SizedBox(width: 10),
            _HeaderIconBtn(icon: Icons.search_rounded, theme: theme),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildKPICards(BuildContext context, WidgetRef ref) {
    final loanSummaryAsync = ref.watch(loanSummaryProvider);
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      children: [
        loanSummaryAsync.when(
          data: (summary) => _KPICard(
            title: 'Total Outstanding',
            value: AppFormatters.formatCompactCurrency(summary.totalOutstanding),
            subtitle: summary.parPercentage > 0
                ? '${summary.parPercentage.toStringAsFixed(1)}% PAR'
                : 'No overdue',
            icon: Icons.account_balance_wallet_rounded,
            color: primary,
          ),
          loading: () => const ShimmerCard(height: 120),
          error: (_, __) => _KPICard(
            title: 'Total Outstanding',
            value: '--',
            subtitle: 'Unable to load',
            icon: Icons.account_balance_wallet_rounded,
            color: primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: loanSummaryAsync.when(
                data: (summary) => _KPICard(
                  title: 'Active Members',
                  value: summary.activeLoans.toString(),
                  subtitle: '${summary.defaultLoans} defaults',
                  icon: Icons.people_rounded,
                  color: const Color(0xFFAF52DE),
                ),
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => _KPICard(
                  title: 'Active Members',
                  value: '--',
                  subtitle: 'Unable to load',
                  icon: Icons.people_rounded,
                  color: const Color(0xFFAF52DE),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: todayStatsAsync.when(
                data: (stats) {
                  final collected = (stats['collected'] as num?)?.toDouble() ?? 0;
                  final count = stats['collectionCount'] as int? ?? 0;
                  return _KPICard(
                    title: "Today's Collection",
                    value: AppFormatters.formatCurrency(collected),
                    subtitle: '$count collections',
                    icon: Icons.payments_rounded,
                    color: const Color(0xFF34C759),
                  );
                },
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => _KPICard(
                  title: "Today's Collection",
                  value: '--',
                  subtitle: 'Unable to load',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF34C759),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTodaysTasks(BuildContext context, WidgetRef ref) {
    final todayStatsAsync = ref.watch(todayStatsProvider);
    final theme = Theme.of(context);

    return todayStatsAsync.when(
      data: (stats) {
        final count = stats['collectionCount'] as int? ?? 0;
        final totalDue = stats['totalDue'] as int? ?? 0;
        final pending = totalDue > 0 ? totalDue - count : 0;

        return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Tasks", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      totalDue > 0 ? '${((count / totalDue) * 100).toInt()}%' : '0%',
                      style: const TextStyle(color: Color(0xFF34C759), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressBar(
                value: totalDue > 0 ? (count / totalDue).clamp(0.0, 1.0) : 0.0,
                height: 6,
                progressColor: const Color(0xFF34C759),
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _TaskStat(value: '$count', label: 'Completed', color: const Color(0xFF34C759)),
                  const SizedBox(width: 32),
                  _TaskStat(value: '$pending', label: 'Pending', color: const Color(0xFFFF9F0A)),
                  const SizedBox(width: 32),
                  _TaskStat(value: '0', label: 'Overdue', color: const Color(0xFFFF3B30)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerCard(height: 140),
      error: (_, __) => GlassCard(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text("Unable to load tasks", style: theme.textTheme.bodySmall)),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _QuickActionBtn(icon: Icons.person_add_alt_1_rounded, label: 'New Member', color: primary, onTap: onQuickAction)),
            const SizedBox(width: 10),
            Expanded(child: _QuickActionBtn(icon: Icons.request_quote_rounded, label: 'New Loan', color: const Color(0xFF5856D6), onTap: () { try { GoRouter.of(context).push('/loans/new'); } catch (_) { onQuickAction(); } })),
            const SizedBox(width: 10),
            Expanded(child: _QuickActionBtn(icon: Icons.savings_rounded, label: 'Deposit', color: const Color(0xFF34C759), onTap: onQuickAction)),
            const SizedBox(width: 10),
            Expanded(child: _QuickActionBtn(icon: Icons.qr_code_scanner_rounded, label: 'Scan Pay', color: const Color(0xFFFF9F0A), onTap: onQuickAction)),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0);
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
            Text('Active Loans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: onViewAllLoans,
              child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        loansAsync.when(
          data: (loans) {
            if (loans.isEmpty) {
              return GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('No active loans', style: theme.textTheme.bodySmall)));
            }
            return Column(
              children: loans.take(2).map((loan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LoanCard(loan: loan),
              )).toList(),
            );
          },
          loading: () => Column(children: List.generate(2, (_) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerCard(height: 160)))),
          error: (_, __) => GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('Unable to load loans', style: theme.textTheme.bodySmall))),
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
            Text('Savings Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: onViewAllSavings,
              child: Text('View All', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        savingsAsync.when(
          data: (savings) {
            if (savings.isEmpty) {
              return GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('No active savings plans', style: theme.textTheme.bodySmall)));
            }
            return Row(
              children: savings.take(2).map((saving) => Expanded(
                child: Padding(padding: const EdgeInsets.only(right: 10), child: _SavingsCard(saving: saving)),
              )).toList(),
            );
          },
          loading: () => const ShimmerStatsRow(itemCount: 2),
          error: (_, __) => GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('Unable to load savings', style: theme.textTheme.bodySmall))),
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
        Text('Recent Transactions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('No recent transactions', style: theme.textTheme.bodySmall)));
            }
            return GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Column(
                    children: [
                      _buildTransactionItem(context, transaction),
                      if (index < transactions.length - 1)
                        Divider(height: 24, color: theme.dividerColor.withValues(alpha: 0.3)),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerCard(height: 180),
          error: (_, __) => GlassCard(padding: const EdgeInsets.all(24), child: Center(child: Text('Unable to load transactions', style: theme.textTheme.bodySmall))),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTransactionItem(BuildContext context, TransactionModel transaction) {
    final theme = Theme.of(context);
    final isDeposit = transaction.type == TransactionType.emiPayment || transaction.type == TransactionType.savingsDeposit;
    final icon = isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final iconColor = isDeposit ? const Color(0xFF34C759) : const Color(0xFFFF3B30);

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
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
              Text(AppFormatters.formatRelativeTime(transaction.createdAt), style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
        Text(AppFormatters.formatCurrency(transaction.amount), style: TextStyle(color: iconColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Sub-Widgets ───

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final ThemeData theme;
  const _HeaderIconBtn({required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: theme.textTheme.bodyLarge?.color),
    );
  }
}

class _TaskStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _TaskStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}

enum Trend { up, down, neutral }

class _KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _KPICard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
    final statusType = loan.status == LoanStatus.active ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus ? StatusType.defaultStatus : StatusType.pending;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(
                  (loan.customerName ?? '?')[0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w700),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.customerName ?? 'Unknown', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(loan.loanNumber, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontFamily: 'JetBrains Mono')),
                  ],
                ),
              ),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressBar(
            value: progress.clamp(0.0, 1.0),
            height: 5,
            progressColor: theme.colorScheme.primary,
            backgroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          ),
          const SizedBox(height: 14),
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
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings_rounded, color: Color(0xFF34C759), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(saving.memberName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          ProgressGauge(
            value: progress.clamp(0.0, 1.0),
            size: 54,
            strokeWidth: 4,
            progressColor: const Color(0xFF34C759),
            center: Text('${(progress * 100).toInt()}%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          const SizedBox(height: 8),
          Text(AppFormatters.formatCurrency(saving.currentAmount), style: TextStyle(color: const Color(0xFF34C759), fontSize: 15, fontWeight: FontWeight.w700)),
          Text('of ${AppFormatters.formatCompactCurrency(saving.targetAmount)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}