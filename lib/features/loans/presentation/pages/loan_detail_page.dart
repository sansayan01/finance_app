import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/loan_providers.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/emi_schedule_model.dart';
import '../widgets/collection_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class LoanDetailPage extends ConsumerWidget {
  final String loanId;

  const LoanDetailPage({super.key, required this.loanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanAsync = ref.watch(loanDetailProvider(loanId));
    final scheduleAsync = ref.watch(emiScheduleProvider(loanId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Loan Registry',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, color: theme.colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'settle') {
                // Implement settlement logic
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settle',
                child: Row(
                  children: [
                    Icon(Icons.handshake_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Settle Loan'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reschedule',
                child: Row(
                  children: [
                    Icon(Icons.event_repeat_rounded, size: 18),
                    SizedBox(width: 12),
                    Text('Reschedule'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: loanAsync.when(
        data: (loan) {
          if (loan == null) {
            return Center(child: Text('Loan not found', style: theme.textTheme.bodyMedium));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(loan, theme),
                const SizedBox(height: AppSpacing.lg),
                _buildMiniStats(loan, theme, primary),
                const SizedBox(height: AppSpacing.lg),
                _buildRepaymentJourney(loan, scheduleAsync, theme, isDark, primary),
                const SizedBox(height: AppSpacing.lg),
                _buildRepaymentSchedule(ref, loan, scheduleAsync, theme),
                const SizedBox(height: AppSpacing.lg),
                _buildAdminContext(loan, theme, primary),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: theme.textTheme.bodySmall)),
      ),
      floatingActionButton: loanAsync.when(
        data: (loan) {
          if (loan == null || loan.status != LoanStatus.active) return null;
          return scheduleAsync.when(
            data: (schedule) {
              if (schedule.isEmpty) return null;
              final nextEmi = schedule.firstWhere(
                (e) => e.status != EMIStatus.paid,
                orElse: () => schedule.first,
              );
              return FloatingActionButton.extended(
                onPressed: () => _showCollectionSheet(context, loan, nextEmi),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Collect Next EMI', style: TextStyle(fontWeight: FontWeight.w600)),
              );
            },
            loading: () => null,
            error: (_, __) => null,
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _showCollectionSheet(BuildContext context, LoanModel loan, EMIScheduleModel emi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionSheet(loan: loan, emi: emi),
    );
  }

  Future<void> _sendReminder(LoanModel loan, EMIScheduleModel emi) async {
    final phone = loan.customerPhone ?? '';
    final message = Uri.encodeComponent(
      'Hi ${loan.customerName}, this is a reminder for your loan ${loan.loanNumber}. '
      'Your EMI of ${AppFormatters.formatCurrency(emi.emiAmount)} is due on ${AppFormatters.formatDate(emi.dueDate)}. '
      'Please ensure the payment is made on time to avoid penalties.'
    );
    final url = 'https://wa.me/$phone?text=$message';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _generateSchedule(WidgetRef ref, LoanModel loan) async {
    try {
      final repository = ref.read(emiRepositoryProvider);
      await repository.generateSchedule(
        loan.id,
        principal: loan.amount,
        interestRate: loan.interestRate,
        tenureMonths: loan.tenureMonths,
        interestType: loan.interestType.name,
        startDate: loan.firstEmiDate ?? DateTime.now().add(const Duration(days: 30)),
        emiAmount: loan.emiAmount,
      );
      ref.invalidate(emiScheduleProvider(loan.id));
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildHeader(LoanModel loan, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              loan.loanNumber,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppFormatters.formatCurrency(loan.amount)} Principal · ${loan.interestRate}% · ${loan.tenureMonths} Mo Term',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildMiniStats(LoanModel loan, ThemeData theme, Color primary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.6,
      children: [
        _MiniStatCard(label: 'Principal', value: AppFormatters.formatCurrency(loan.amount), icon: Icons.account_balance, color: primary),
        _MiniStatCard(label: 'Outstanding', value: AppFormatters.formatCurrency(loan.outstandingBalance), icon: Icons.show_chart, color: const Color(0xFF5E5CE6), highlight: loan.outstandingBalance > 0),
        _MiniStatCard(label: 'Monthly EMI', value: AppFormatters.formatCurrency(loan.emiAmount), icon: Icons.payments, color: const Color(0xFFBF5AF2)),
        _MiniStatCard(label: 'Total Interest', value: AppFormatters.formatCurrency(loan.totalInterest), icon: Icons.percent, color: const Color(0xFFFF9F0A)),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildRepaymentJourney(LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync, ThemeData theme, bool isDark, Color primary) {
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
                      Icon(Icons.auto_awesome, size: 16, color: primary),
                      const SizedBox(width: 8),
                      Text('Repayment Journey', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$paidCount of ${loan.tenureMonths} Installments',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressBar(
                value: progress.clamp(0.0, 1.0),
                height: 10,
                progressColor: primary,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${(progress * 100).toStringAsFixed(1)}%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text('CAPITAL RECOVERED', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${loan.tenureMonths - paidCount}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text('REMAINING', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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

  Widget _buildRepaymentSchedule(WidgetRef ref, LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Repayment Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.md),
          scheduleAsync.when(
            data: (schedule) {
              if (schedule.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Text('No schedule generated', style: theme.textTheme.bodySmall),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _generateSchedule(ref, loan),
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                          label: const Text('Generate Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                  columns: [
                    DataColumn(label: Text('#', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('DUE DATE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('AMOUNT', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('STATUS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900))),
                    DataColumn(label: Text('ACTION', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900))),
                  ],
                  rows: schedule.map((emi) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          emi.emiNumber.toString().padLeft(2, '0'),
                          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700),
                        )),
                        DataCell(Text(
                          AppFormatters.formatDate(emi.dueDate),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                        )),
                        DataCell(Text(
                          AppFormatters.formatCurrency(emi.emiAmount),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 13),
                        )),
                        DataCell(StatusBadge(
                          label: emi.status.name,
                          type: _getEMIStatusType(emi.status),
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.send_rounded, size: 18, color: theme.colorScheme.primary),
                          onPressed: () => _sendReminder(loan, emi),
                          tooltip: 'Send Reminder',
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('Failed to load schedule', style: theme.textTheme.bodySmall)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildAdminContext(LoanModel loan, ThemeData theme, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: primary),
              const SizedBox(width: 8),
              Text('Administrative Context', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContextItem('Assigned Staff', loan.staffName ?? '—', Icons.person_outline, theme, primary),
          _buildContextItem('Interest Method', loan.interestType.name, Icons.percent, theme, primary),
          _buildContextItem('Disbursement Date', loan.disbursementDate != null ? AppFormatters.formatDate(loan.disbursementDate!) : 'Pending', Icons.calendar_today_outlined, theme, primary),
          _buildContextItem('Purpose', loan.purpose ?? 'Not Specified', Icons.assignment_outlined, theme, primary),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildContextItem(String label, String value, IconData icon, ThemeData theme, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: primary),
              const SizedBox(width: 6),
              Text(label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
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
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight ? theme.colorScheme.error : theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
