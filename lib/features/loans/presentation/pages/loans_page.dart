import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('New Loan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.3)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loans',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and track all loan accounts',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.fillDark : AppColors.fillLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search loans...',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodySmall?.color, size: 22),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.fillDark : AppColors.fillLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (i) => setState(() => _filterStatus = _statusForTab(i)),
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.elevatedDark : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(3),
                  labelColor: theme.textTheme.bodyLarge?.color,
                  unselectedLabelColor: theme.textTheme.bodySmall?.color,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.3),
                  dividerColor: Colors.transparent,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LoanListItem(loan: filtered[i]).animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.03, end: 0),
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: 5,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerCard(height: 120),
                  ),
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
          Icon(Icons.description_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text('No loans found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Adjust filters or create a new loan.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LoanListItem extends StatelessWidget {
  final LoanModel loan;
  const _LoanListItem({required this.loan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final progress = 1 - (loan.outstandingBalance / loan.amount);
    final statusType = loan.status == LoanStatus.active
        ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus
            ? StatusType.defaultStatus
            : loan.status == LoanStatus.pending
                ? StatusType.pending
                : StatusType.completed;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push('/loans/${loan.id}'),
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
                    colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    (loan.customerName ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w700),
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
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loan.loanNumber,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontFamily: 'JetBrains Mono'),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType, glow: false),
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
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'Amount', value: AppFormatters.formatCompactCurrency(loan.amount)),
              _InfoChip(label: 'EMI', value: AppFormatters.formatCurrency(loan.emiAmount)),
              _InfoChip(label: 'Balance', value: AppFormatters.formatCompactCurrency(loan.outstandingBalance)),
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
  const _InfoChip({required this.label, required this.value});

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