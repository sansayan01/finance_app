import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/loan_providers.dart';
import '../../data/models/loan_model.dart';

final loanStatusFilterProvider = StateProvider<LoanStatus?>((ref) => null);

class LoansPage extends ConsumerStatefulWidget {
  const LoansPage({super.key});

  @override
  ConsumerState<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends ConsumerState<LoansPage> {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(loanStatsProvider);
    final filteredLoans = ref.watch(filteredLoansProvider);
    final selectedFilter = ref.watch(loanStatusFilterProvider);

    // Apply additional status filtering if selected
    final displayedLoans = selectedFilter == null 
        ? filteredLoans 
        : filteredLoans.where((l) => l.status == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildMetricHeader(statsAsync),
                  const SizedBox(height: 40),
                  _buildAssetPortfolioSection(displayedLoans),
                  const SizedBox(height: 40),
                  _buildDisbursementSection(statsAsync),
                  const SizedBox(height: 40),
                  _buildOperationalShortcuts(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint('FAB Clicked! Pushing /loans/new');
          context.push('/loans/new');
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Deploy Capital', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8F9FB),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Portfolio Registry',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              children: [
                _buildActionIcon(Icons.tune_rounded),
                const SizedBox(width: 8),
                _buildActionIcon(Icons.download_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }

  Widget _buildMetricHeader(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(child: _buildMetricCard('Active Assets', stats['activeCount'].toString(), Icons.bolt_rounded, AppColors.primaryTeal)),
          const SizedBox(width: 12),
          Expanded(child: _buildMetricCard('Exposure', currencyFormat.format(stats['totalOutstanding']), Icons.account_balance_wallet_rounded, AppColors.primaryIndigo)),
          const SizedBox(width: 12),
          Expanded(child: _buildMetricCard('Risk', '${stats['overdueCount']}', Icons.warning_amber_rounded, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _buildMetricCard('Queue', stats['pendingCount'].toString(), Icons.hourglass_empty_rounded, Colors.blueGrey)),
        ],
      ),
      loading: () => Row(
        children: List.generate(4, (index) => const Expanded(child: ShimmerCard(height: 100))),
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMutedLight, letterSpacing: 1),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildAssetPortfolioSection(List<LoanModel> loans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asset Portfolio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Detailed overview of deployed capital',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 24),
        _buildSearchAndFilter(),
        const SizedBox(height: 24),
        _buildAssetTable(loans),
      ],
    );
  }

  Widget _buildAssetTable(List<LoanModel> loans) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: Row(
              children: [
                _buildTableHeader('Ref ID', flex: 1),
                _buildTableHeader('Member Identity', flex: 2),
                _buildTableHeader('Principal Sum', flex: 1),
                _buildTableHeader('Scheduled EMI', flex: 1),
                _buildTableHeader('Asset Status', flex: 1, center: true),
                _buildTableHeader('Outstanding Liability', flex: 1),
                _buildTableHeader('Audit', flex: 0),
              ],
            ),
          ),
          loans.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemBuilder: (context, index) {
                    final loan = loans[index];
                    return _buildLoanRow(loan, index);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String label, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _buildLoanRow(LoanModel loan, int index) {
    return InkWell(
      onTap: () => context.push('/loans/${loan.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                loan.loanNumber,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                    child: Text(
                      loan.customerName?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loan.customerName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                currencyFormat.format(loan.amount),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                currencyFormat.format(loan.emiAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondaryLight),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(child: _buildStatusBadge(loan.status)),
            ),
            Expanded(
              flex: 1,
              child: Text(
                currencyFormat.format(loan.outstandingBalance),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: () => context.push('/loans/${loan.id}'),
              icon: const Icon(Icons.visibility_outlined, size: 20, color: AppColors.primaryTeal),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildStatusBadge(LoanStatus status) {
    Color color;
    switch (status) {
      case LoanStatus.active:
        color = Colors.green;
        break;
      case LoanStatus.pending:
        color = Colors.orange;
        break;
      case LoanStatus.approved:
        color = Colors.teal;
        break;
      case LoanStatus.defaultStatus:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildDisbursementSection(AsyncValue<Map<String, dynamic>> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disbursement Velocity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Capital allocation trend across portfolio',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL PORTFOLIO VOLUME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(stats['totalDisbursed']),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cumulative disbursement since inception',
                          style: TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.account_balance_outlined, color: AppColors.primaryTeal, size: 32),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(height: 100),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operational Shortcuts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildShortcutItem(
          Icons.add_rounded, 
          'Deploy Capital', 
          onTap: () {
            debugPrint('Shortcut Clicked! Pushing /loans/new');
            context.push('/loans/new');
          },
        ),
        const SizedBox(height: 12),
        _buildShortcutItem(Icons.trending_up_rounded, 'EMI Forecaster'),
      ],
    );
  }

  Widget _buildShortcutItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryTeal, size: 20),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMutedLight),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => ref.read(loanSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search by member, phone or ref id...',
                hintStyle: TextStyle(color: AppColors.textMutedLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMutedLight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFilterChip('Active', Icons.check_circle_outline_rounded),
      ],
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.account_balance_outlined, size: 64, color: AppColors.textMutedLight.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            const Text(
              'No loan records found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Refine your search parameters to find the assets.',
              style: TextStyle(color: AppColors.textMutedLight),
            ),
          ],
        ),
      ),
    );
  }
}