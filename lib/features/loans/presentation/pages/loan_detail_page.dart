import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/loan_providers.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/emi_schedule_model.dart';

class LoanDetailPage extends ConsumerWidget {
  final String loanId;

  const LoanDetailPage({super.key, required this.loanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanDetailProvider(loanId));
    final scheduleAsync = ref.watch(emiScheduleProvider(loanId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Loan Registry',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: loanAsync.when(
        data: (loan) {
          if (loan == null) {
            return const Center(child: Text('Loan not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(loan),
                const SizedBox(height: AppSpacing.lg),
                _buildMiniStats(loan),
                const SizedBox(height: AppSpacing.lg),
                _buildRepaymentJourney(loan, scheduleAsync),
                const SizedBox(height: AppSpacing.lg),
                _buildRepaymentSchedule(loan, scheduleAsync),
                const SizedBox(height: AppSpacing.lg),
                _buildAdminContext(loan),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: loanAsync.value?.status == LoanStatus.active
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: AppColors.primaryTeal,
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Record Payment'),
            )
          : null,
    );
  }

  Widget _buildHeader(LoanModel loan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              loan.loanNumber,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: loan.status.name.toUpperCase(),
              type: _getStatusType(loan.status),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          loan.customerName ?? 'Unknown Member',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppFormatters.formatCurrency(loan.amount)} Principal · ${loan.interestRate}% · ${loan.tenureMonths} Mo Term',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildMiniStats(LoanModel loan) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        _MiniStatCard(
          label: 'Principal',
          value: AppFormatters.formatCurrency(loan.amount),
          icon: Icons.account_balance,
          color: AppColors.primaryTeal,
        ),
        _MiniStatCard(
          label: 'Outstanding',
          value: AppFormatters.formatCurrency(loan.outstandingBalance),
          icon: Icons.show_chart,
          color: AppColors.primaryIndigo,
          highlight: loan.outstandingBalance > 0,
        ),
        _MiniStatCard(
          label: 'Monthly EMI',
          value: AppFormatters.formatCurrency(loan.emiAmount),
          icon: Icons.payments,
          color: AppColors.primaryPurple,
        ),
        _MiniStatCard(
          label: 'Total Interest',
          value: AppFormatters.formatCurrency(loan.totalInterest),
          icon: Icons.percent,
          color: Colors.orange,
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildRepaymentJourney(LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync) {
    return scheduleAsync.when(
      data: (schedule) {
        final paidCount = schedule.where((e) => e.status == EMIStatus.paid).length;
        final progress = loan.amount > 0 ? (1 - (loan.outstandingBalance / loan.amount)) : 0.0;

        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 8),
                      const Text(
                        'Repayment Journey',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.glassBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$paidCount of ${loan.tenureMonths} Installments',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: AppColors.glassBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'CAPITAL RECOVERED',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${loan.tenureMonths - paidCount}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'REMAINING',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const ShimmerCard(height: 140),
      error: (_, __) => const SizedBox(),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildRepaymentSchedule(LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Repayment Schedule',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          scheduleAsync.when(
            data: (schedule) {
              if (schedule.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Text('No schedule generated'),
                  ),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  headingRowHeight: 40,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 56,
                  columns: const [
                    DataColumn(label: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('DUE DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
                  ],
                  rows: schedule.map((emi) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          emi.emiNumber.toString().padLeft(2, '0'),
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          AppFormatters.formatDate(emi.dueDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        )),
                        DataCell(Text(
                          AppFormatters.formatCurrency(emi.emiAmount),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        )),
                        DataCell(StatusBadge(
                          label: emi.status.name,
                          type: _getEMIStatusType(emi.status),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Failed to load schedule')),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildAdminContext(LoanModel loan) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 16, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              const Text(
                'Administrative Context',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContextItem('Assigned Staff', loan.staffName ?? '—', Icons.person_outline),
          _buildContextItem('Interest Method', loan.interestType.name, Icons.percent),
          _buildContextItem('Disbursement Date', loan.disbursementDate != null ? AppFormatters.formatDate(loan.disbursementDate!) : 'Pending', Icons.calendar_today_outlined),
          _buildContextItem('Purpose', loan.purpose ?? 'Not Specified', Icons.assignment_outlined),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildContextItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.primaryTeal),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return StatusType.standard;
      case LoanStatus.defaultStatus:
        return StatusType.defaultStatus;
      case LoanStatus.pending:
        return StatusType.pending;
      case LoanStatus.closed:
        return StatusType.standard;
      default:
        return StatusType.pending;
    }
  }

  StatusType _getEMIStatusType(EMIStatus status) {
    switch (status) {
      case EMIStatus.paid:
        return StatusType.standard;
      case EMIStatus.overdue:
        return StatusType.defaultStatus;
      case EMIStatus.upcoming:
        return StatusType.pending;
      default:
        return StatusType.pending;
    }
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.error : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
