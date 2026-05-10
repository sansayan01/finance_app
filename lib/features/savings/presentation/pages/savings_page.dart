import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/progress_gauge.dart';
import 'package:go_router/go_router.dart';
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
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Savings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '0 accounts managed • 0 growing',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.push('/savings/new');
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Open Account', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTotalSavings(WidgetRef ref) {
    final savingsSummaryAsync = ref.watch(savingsSummaryProvider);

    return savingsSummaryAsync.when(
      data: (summary) {
        return Row(
          children: [
            Expanded(
              child: _buildTopStatCard(
                label: 'TOTAL SAVED',
                value: AppFormatters.formatCurrency(summary.totalSavings),
                icon: Icons.savings,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTopStatCard(
                label: 'ACTIVE ACCOUNTS',
                value: summary.activeAccounts.toString(),
                icon: Icons.track_changes,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTopStatCard(
                label: 'MATURED',
                value: '0', // Adjust when matured logic is added
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTopStatCard(
                label: 'TOTAL TARGET',
                value: AppFormatters.formatCurrency(summary.totalSavings * 1.5), // Dummy logic for now
                icon: Icons.pie_chart_outline,
              ),
            ),
          ],
        );
      },
      loading: () => const ShimmerStatsRow(itemCount: 4),
      error: (_, __) => GlassCard(
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

  Widget _buildTopStatCard({required String label, required String value, required IconData icon}) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textMutedLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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