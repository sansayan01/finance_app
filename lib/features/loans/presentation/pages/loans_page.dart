import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/enums.dart';
import '../../data/models/loan_model.dart';
import '../../data/providers/loan_providers.dart';

class LoansPage extends ConsumerStatefulWidget {
  const LoansPage({super.key});

  @override
  ConsumerState<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends ConsumerState<LoansPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  LoanStatus? _filterStatus;

  final _tabs = const ['All', 'Active', 'Pending', 'Defaulted', 'Closed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  LoanStatus? _statusForTab(int index) {
    switch (index) {
      case 1: return LoanStatus.active;
      case 2: return LoanStatus.pending;
      case 3: return LoanStatus.defaultStatus;
      case 4: return LoanStatus.closed;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/loans/new'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('New Loan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loans', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Manage and track all loan accounts', style: theme.textTheme.bodySmall?.copyWith(fontSize: 14)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),

            const SizedBox(height: 16),

            // ─── Search Bar ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search loans...',
                    prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodySmall?.color, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // ─── Tab Filter ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (i) => setState(() => _filterStatus = _statusForTab(i)),
                  indicator: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(3),
                  labelColor: theme.textTheme.bodyLarge?.color,
                  unselectedLabelColor: theme.textTheme.bodySmall?.color,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  dividerColor: Colors.transparent,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // ─── Loan List ───
            Expanded(
              child: loansAsync.when(
                data: (loans) {
                  var filtered = loans.where((l) {
                    if (_filterStatus != null && l.status != _filterStatus) return false;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      return (l.customerName?.toLowerCase().contains(q) ?? false) ||
                             l.loanNumber.toLowerCase().contains(q);
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LoanListItem(loan: filtered[i], theme: theme).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.03, end: 0),
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerCard(height: 100)),
                ),
                error: (e, _) => Center(child: Text('Error loading loans: $e', style: theme.textTheme.bodySmall)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 56, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No loans found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Adjust filters or create a new loan.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LoanListItem extends StatelessWidget {
  final LoanModel loan;
  final ThemeData theme;
  const _LoanListItem({required this.loan, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final progress = 1 - (loan.outstandingBalance / loan.amount);
    final statusType = loan.status == LoanStatus.active ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus ? StatusType.defaultStatus
        : loan.status == LoanStatus.pending ? StatusType.pending : StatusType.completed;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/loans/${loan.id}'),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text((loan.customerName ?? '?')[0].toUpperCase(), style: TextStyle(color: primary, fontSize: 17, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loan.customerName ?? 'Unknown', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(loan.loanNumber, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontFamily: 'JetBrains Mono')),
                ],
              )),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType, glow: false),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressBar(
            value: progress.clamp(0.0, 1.0),
            height: 4,
            progressColor: primary,
            backgroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'Amount', value: AppFormatters.formatCompactCurrency(loan.amount), theme: theme),
              _InfoChip(label: 'EMI', value: AppFormatters.formatCurrency(loan.emiAmount), theme: theme),
              _InfoChip(label: 'Balance', value: AppFormatters.formatCompactCurrency(loan.outstandingBalance), theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  const _InfoChip({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }
}