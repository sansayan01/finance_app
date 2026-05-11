import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/loan_providers.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/emi_schedule_model.dart';
import '../widgets/collection_sheet.dart';

class LoanDetailPage extends ConsumerStatefulWidget {
  final String loanId;
  const LoanDetailPage({super.key, required this.loanId});

  @override
  ConsumerState<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends ConsumerState<LoanDetailPage> with SingleTickerProviderStateMixin {
  bool _isActionHubExpanded = false;
  late AnimationController _auroraController;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(vsync: this, duration: 10.seconds)..repeat();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanAsync = ref.watch(loanDetailProvider(widget.loanId));
    final scheduleAsync = ref.watch(emiScheduleProvider(widget.loanId));
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: loanAsync.when(
        data: (loan) {
          if (loan == null) return const Center(child: Text('Loan Not Found'));
          return Stack(
            children: [
              _buildEliteBackground(theme, primary),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildCustomAppBar(loan, theme),
                  _buildImmersiveHeader(loan, theme, primary),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildInteractiveDebtSplit(loan, theme, primary),
                          const SizedBox(height: 32),
                          _buildQuickMetrics(loan, theme, primary),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Borrower Insights', theme),
                          const SizedBox(height: 16),
                          _buildEliteBorrowerInsights(loan, theme, primary),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Repayment Timeline', theme),
                          const SizedBox(height: 16),
                          _buildTimeline(loan, scheduleAsync, theme, primary),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Administration Log', theme),
                          const SizedBox(height: 16),
                          _buildAdminLog(loan, theme, primary),
                          const SizedBox(height: 160), // Extra space for Hub
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildActionHub(loan, scheduleAsync, theme, primary),
            ],
          );
        },
        loading: () => _buildLoadingState(theme),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEliteBackground(ThemeData theme, Color primary) {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: theme.scaffoldBackgroundColor),
            Positioned(
              top: -200 + (50 * _auroraController.value),
              right: -100 + (20 * _auroraController.value),
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomAppBar(LoanModel loan, ThemeData theme) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        loan.loanNumber,
        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontFamily: 'JetBrains Mono'),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildImmersiveHeader(LoanModel loan, ThemeData theme, Color primary) {
    final progress = 1 - (loan.outstandingBalance / loan.totalRepayable);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180, height: 180,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 16,
                    backgroundColor: primary.withValues(alpha: 0.05),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -2),
                    ),
                    Text(
                      'PRINCIPAL RECOVERED',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ).animate().scale(curve: Curves.elasticOut, duration: 1.seconds),
            const SizedBox(height: 40),
            Text(
              AppFormatters.formatCurrency(loan.outstandingBalance),
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.5),
            ),
            Text(
              'REMAINING OUTSTANDING',
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveDebtSplit(LoanModel loan, ThemeData theme, Color primary) {
    final total = loan.totalRepayable > 0 ? loan.totalRepayable : 1.0;
    final principalFlex = ((loan.amount / total) * 100).toInt().clamp(1, 100);
    final interestFlex = 100 - principalFlex;
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('Interest Rate', '${loan.interestRate}%', theme),
              _buildMiniMetric('Total Interest', AppFormatters.formatCurrency(loan.totalInterest), theme, alignEnd: true),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(flex: principalFlex, child: Container(height: 8, color: primary)),
                Expanded(flex: interestFlex, child: Container(height: 8, color: Colors.orange.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Legend(label: 'Principal ($principalFlex%)', color: primary),
              _Legend(label: 'Interest Reserve ($interestFlex%)', color: Colors.orange),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildEliteBorrowerInsights(LoanModel loan, ThemeData theme, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'loan_avatar_${loan.id}',
                child: Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 10)],
                    gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.7)]),
                  ),
                  child: Center(
                    child: Text((loan.customerName ?? '?')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.customerName ?? 'Unknown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('VERIFIED MEMBER', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'LOANS', value: '1 Active', icon: Icons.account_balance_wallet_outlined),
              _StatItem(label: 'SINCE', value: 'Dec 2023', icon: Icons.calendar_today_rounded),
              _StatItem(label: 'HEALTH', value: 'Good', icon: Icons.favorite_rounded, color: Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(loan.customerPhone ?? ''),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Call Member'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeWhatsApp(loan.customerPhone ?? '', loan),
                  icon: const Icon(Icons.chat_bubble_rounded),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAdminLog(LoanModel loan, ThemeData theme, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _LogEntry(label: 'Loan Disbursed', value: AppFormatters.formatDate(loan.createdAt), icon: Icons.check_circle_rounded, color: Colors.green),
          _LogEntry(label: 'Assigned Agent', value: loan.staffName ?? 'System Auto', icon: Icons.person_rounded, color: primary),
          _LogEntry(label: 'Status Updated', value: loan.status.name.toUpperCase(), icon: Icons.sync_rounded, color: Colors.orange, isLast: true),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildTimeline(LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync, ThemeData theme, Color primary) {
    return scheduleAsync.when(
      data: (schedule) {
        if (schedule.isEmpty) return _buildNoScheduleState(loan);
        return Column(
          children: schedule.asMap().entries.map((entry) {
            final index = entry.key;
            final emi = entry.value;
            final isLast = index == schedule.length - 1;
            
            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getTimelineColor(emi.status, primary),
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                          boxShadow: [BoxShadow(color: _getTimelineColor(emi.status, primary).withValues(alpha: 0.2), blurRadius: 10)],
                        ),
                        child: emi.status == EMIStatus.paid ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: _getTimelineColor(emi.status, primary).withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('INSTALLMENT #${emi.emiNumber}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: primary)),
                                Text(AppFormatters.formatDate(emi.dueDate), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(AppFormatters.formatCurrency(emi.emiAmount), style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900)),
                              StatusBadge(label: emi.status.name, type: _getEMIStatusType(emi.status)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const ShimmerCard(height: 200),
      error: (_, __) => const Text('Timeline Error'),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildActionHub(LoanModel loan, AsyncValue<List<EMIScheduleModel>> scheduleAsync, ThemeData theme, Color primary) {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isActionHubExpanded)
            _buildSecondaryActions(loan, theme, primary).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: 400.ms,
            curve: Curves.easeOutQuart,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: scheduleAsync.when(
                    data: (schedule) {
                      if (schedule.isEmpty) return const SizedBox();
                      final nextEmi = schedule.firstWhere((e) => e.status != EMIStatus.paid, orElse: () => schedule.first);
                      return InkWell(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          _showCollectionSheet(context, loan, nextEmi);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: const Center(
                            child: Text(
                              'Record Collection',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isActionHubExpanded = !_isActionHubExpanded);
                  },
                  child: AnimatedRotation(
                    duration: 400.ms,
                    turns: _isActionHubExpanded ? 0.125 : 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: _isActionHubExpanded ? 0.2 : 0.1),
                      ),
                      child: Icon(_isActionHubExpanded ? Icons.add : Icons.grid_view_rounded, color: primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, delay: 1000.ms);
  }

  Widget _buildSecondaryActions(LoanModel loan, ThemeData theme, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _SecondaryActionButton(icon: Icons.description_rounded, label: 'Export PDF', color: primary),
          _SecondaryActionButton(icon: Icons.account_balance_rounded, label: 'Settle Loan', color: Colors.green),
          _SecondaryActionButton(icon: Icons.event_note_rounded, label: 'Reschedule', color: Colors.orange),
          _SecondaryActionButton(icon: Icons.history_edu_rounded, label: 'Ledger', color: Colors.blue),
          _SecondaryActionButton(icon: Icons.group_rounded, label: 'Guarantors', color: Colors.purple),
          _SecondaryActionButton(icon: Icons.settings_backup_restore_rounded, label: 'Audit', color: Colors.teal),
        ],
      ),
    );
  }

  Widget _buildQuickMetrics(LoanModel loan, ThemeData theme, Color primary) {
    return Row(
      children: [
        Expanded(child: _MetricTile(label: 'MONTHLY EMI', value: AppFormatters.formatCurrency(loan.emiAmount), icon: Icons.receipt_long_rounded, color: primary)),
        const SizedBox(width: 12),
        Expanded(child: _MetricTile(label: 'TENURE', value: '${loan.tenureMonths} Mos', icon: Icons.timelapse_rounded, color: Colors.orange)),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildMiniMetric(String label, String value, ThemeData theme, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildNoScheduleState(LoanModel loan) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('No repayment schedule found', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _generateSchedule(loan),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(child: CircularProgressIndicator());
  }

  Color _getTimelineColor(EMIStatus status, Color primary) {
    switch (status) {
      case EMIStatus.paid: return Colors.green;
      case EMIStatus.overdue: return Colors.red;
      default: return primary;
    }
  }

  StatusType _getEMIStatusType(EMIStatus status) {
    switch (status) {
      case EMIStatus.paid: return StatusType.standard;
      case EMIStatus.overdue: return StatusType.defaultStatus;
      default: return StatusType.pending;
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  Future<void> _makeWhatsApp(String phone, LoanModel loan) async {
    final msg = Uri.encodeComponent('Hi ${loan.customerName}, regarding loan ${loan.loanNumber}...');
    final url = 'https://wa.me/$phone?text=$msg';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _generateSchedule(LoanModel loan) async {
    HapticFeedback.mediumImpact();
    await ref.read(emiRepositoryProvider).generateSchedule(
      loan.id,
      principal: loan.amount,
      interestRate: loan.interestRate,
      tenureMonths: loan.tenureMonths,
      interestType: loan.interestType.name,
      startDate: loan.firstEmiDate ?? DateTime.now().add(const Duration(days: 30)),
      emiAmount: loan.emiAmount,
    );
    ref.invalidate(emiScheduleProvider(loan.id));
  }

  void _showCollectionSheet(BuildContext context, LoanModel loan, EMIScheduleModel emi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionSheet(loan: loan, emi: emi),
    );
  }
}

class _LogEntry extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _LogEntry({required this.label, required this.value, required this.icon, required this.color, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w900)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SecondaryActionButton({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.7))),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
      ],
    );
  }
}

class AppColors {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
