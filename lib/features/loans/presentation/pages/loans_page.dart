import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../home/data/providers/dashboard_providers.dart';
import '../../data/models/loan_model.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildStatsCards(ref),
          const SizedBox(height: AppSpacing.lg),
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
          _buildLoansList(ref),
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
              'Loan Portfolio',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage and track all loans',
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
            color: AppColors.primaryIndigo.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          ),
          child: const Icon(
            Icons.filter_list,
            color: AppColors.primaryTeal,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatsCards(WidgetRef ref) {
    final loanSummaryAsync = ref.watch(loanSummaryProvider);

    return loanSummaryAsync.when(
      data: (summary) => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Active Loans',
              value: summary.activeLoans.toString(),
              icon: Icons.account_balance,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'Default Rate',
              value: '${((summary.defaultLoans / (summary.activeLoans + summary.defaultLoans)) * 100).toStringAsFixed(1)}%',
              icon: Icons.warning_amber,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'PAR %',
              value: summary.parPercentage.toStringAsFixed(1),
              icon: Icons.pie_chart,
              color: AppColors.error,
            ),
          ),
        ],
      ),
      loading: () => const ShimmerStatsRow(itemCount: 3),
      error: (_, __) => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Active Loans',
              value: '--',
              icon: Icons.account_balance,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'Default Rate',
              value: '--',
              icon: Icons.warning_amber,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: 'PAR %',
              value: '--',
              icon: Icons.pie_chart,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'All', isSelected: true),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Active'),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Under Review'),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Default'),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(label: 'Closed'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLoansList(WidgetRef ref) {
    final loansAsync = ref.watch(activeLoansProvider);

    return loansAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: const Center(
              child: Text(
                'No loans found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          );
        }
        return Column(
          children: loans.asMap().entries.map((entry) {
            final index = entry.key;
            final loan = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LoanCard(loan: loan)
                  .animate(delay: (300 + index * 50).ms)
                  .fadeIn()
                  .slideX(begin: 0.05, end: 0),
            );
          }).toList(),
        );
      },
      loading: () => Column(
        children: List.generate(
          5,
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
            'Unable to load loans',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
  });

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

class _LoanCard extends StatelessWidget {
  final LoanModel loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (loan.outstandingAmount / loan.principal);
    final isOverdue = loan.status == LoanStatus.defaultStatus;

    StatusType statusType;
    switch (loan.status) {
      case LoanStatus.active:
        statusType = StatusType.standard;
        break;
      case LoanStatus.defaultStatus:
        statusType = StatusType.defaultStatus;
        break;
      case LoanStatus.underReview:
      case LoanStatus.submitted:
        statusType = StatusType.pending;
        break;
      case LoanStatus.approved:
        statusType = StatusType.approved;
        break;
      case LoanStatus.rejected:
        statusType = StatusType.rejected;
        break;
      default:
        statusType = StatusType.pending;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {},
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
                ),
                child: Center(
                  child: Text(
                    loan.memberName.isNotEmpty ? loan.memberName[0] : '?',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
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
                      loan.memberName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${loan.id.substring(0, 8).toUpperCase()} • ${AppFormatters.formatCompactCurrency(loan.principal)}',
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
            children: [
              Expanded(
                child: Column(
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
                      AppFormatters.formatCurrency(loan.outstandingAmount),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interest',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${loan.interestRate}%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOverdue ? 'Overdue' : 'Tenure',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    isOverdue ? 'Yes' : '${loan.tenureMonths} mo',
                    style: TextStyle(
                      color: isOverdue ? AppColors.error : AppColors.textPrimary,
                      fontSize: 14,
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
                : statusType == StatusType.defaultStatus
                    ? AppColors.error
                    : AppColors.warning,
          ),
        ],
      ),
    );
  }
}