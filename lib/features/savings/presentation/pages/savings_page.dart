import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../home/data/providers/dashboard_providers.dart';
import '../../data/models/savings_model.dart';

class SavingsPage extends ConsumerWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildTotalSavings(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildSavingsAccounts(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildPendingDeposits(ref),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Savings Portfolio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Track member savings and targets',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.success,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTotalSavings(WidgetRef ref) {
    final savingsSummaryAsync = ref.watch(savingsSummaryProvider);

    return savingsSummaryAsync.when(
      data: (summary) => GlassCard(
        gradientColors: [
          AppColors.primaryIndigo.withValues(alpha: 0.2),
          AppColors.primaryTeal.withValues(alpha: 0.1),
        ],
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Savings',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatCurrency(summary.totalSavings),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.activeAccounts} active accounts',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
                  ),
                  child: const Icon(
                    Icons.savings,
                    color: AppColors.primaryTeal,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Active Accounts',
                    value: summary.activeAccounts.toString(),
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MiniStat(
                    label: 'Avg Balance',
                    value: AppFormatters.formatCompactCurrency(summary.averageBalance),
                    icon: Icons.bar_chart,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MiniStat(
                    label: 'Interest Earned',
                    value: AppFormatters.formatCompactCurrency(summary.interestEarned),
                    icon: Icons.percent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const ShimmerCard(height: 220),
      error: (_, __) => GlassCard(
        gradientColors: [
          AppColors.primaryIndigo.withValues(alpha: 0.2),
          AppColors.primaryTeal.withValues(alpha: 0.1),
        ],
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(
          child: Text(
            'Unable to load savings summary',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSavingsAccounts(WidgetRef ref) {
    final savingsAsync = ref.watch(activeSavingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Savings Plans',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        savingsAsync.when(
          data: (savings) {
            if (savings.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Center(
                  child: Text(
                    'No savings plans found',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return Column(
              children: savings.asMap().entries.map((entry) {
                final index = entry.key;
                final saving = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SavingsAccountCard(saving: saving)
                      .animate(delay: (200 + index * 50).ms)
                      .fadeIn()
                      .slideX(begin: 0.05, end: 0),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: const ShimmerCard(height: 180),
              ),
            ),
          ),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'Unable to load savings plans',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingDeposits(WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDepositsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Deposits',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        pendingAsync.when(
          data: (pending) {
            if (pending.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Center(
                  child: Text(
                    'No pending deposits',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: pending.asMap().entries.map((entry) {
                  final index = entry.key;
                  final deposit = entry.value;
                  return Column(
                    children: [
                      if (index > 0)
                        const Divider(color: AppColors.glassBorder, height: 20),
                      _PendingDepositItem(saving: deposit),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerCard(height: 160),
          error: (_, __) => GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'Unable to load pending deposits',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.05, end: 0),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryIndigo.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 14),
        ),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SavingsAccountCard extends StatelessWidget {
  final SavingsModel saving;

  const _SavingsAccountCard({required this.saving});

  @override
  Widget build(BuildContext context) {
    final progress = saving.currentAmount / saving.targetAmount;
    final daysRemaining = saving.maturityDate.difference(DateTime.now()).inDays;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {},
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                ),
                child: const Icon(
                  Icons.savings,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saving.memberName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      saving.planName,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(saving.currentAmount),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ProgressGauge(
                value: progress.clamp(0.0, 1.0),
                size: 60,
                strokeWidth: 5,
                progressColor: AppColors.success,
                center: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Monthly Deposit',
                      value: AppFormatters.formatCurrency(saving.monthlyDeposit),
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      label: 'Interest Rate',
                      value: '${saving.interestRate}%',
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(
                      label: 'Maturity',
                      value: '$daysRemaining days',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PendingDepositItem extends StatelessWidget {
  final SavingsModel saving;

  const _PendingDepositItem({required this.saving});

  @override
  Widget build(BuildContext context) {
    final isOverdue = saving.maturityDate.isBefore(DateTime.now());

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isOverdue ? AppColors.error : AppColors.warning)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
          ),
          child: Icon(
            Icons.schedule,
            color: isOverdue ? AppColors.error : AppColors.warning,
            size: 18,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saving.memberName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isOverdue
                    ? 'Overdue by ${DateTime.now().difference(saving.maturityDate).inDays} days'
                    : 'Due: ${AppFormatters.formatShortDate(saving.maturityDate)}',
                style: TextStyle(
                  color: isOverdue ? AppColors.error : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          AppFormatters.formatCurrency(saving.monthlyDeposit),
          style: TextStyle(
            color: isOverdue ? AppColors.error : AppColors.warning,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}