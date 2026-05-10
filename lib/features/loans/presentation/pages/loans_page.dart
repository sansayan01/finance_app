import 'dart:ui';
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
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/aurora_background.dart';
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
  
  // Sorting options
  final String _sortBy = 'recent'; // 'recent', 'amount', 'balance'
  bool _sortAscending = false;

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

  Future<void> _onRefresh() async {
    ref.invalidate(loansProvider);
    ref.invalidate(loanSummaryProvider);
    return await ref.read(loansProvider.future).then((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider);
    final summaryAsync = ref.watch(loanSummaryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 20,
            color: primary,
            backgroundColor: theme.cardColor,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium Header Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Loan Portfolio',
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.2,
                                      fontSize: 34,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Portfolio Management & Risk',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                _buildSortToggle(isDark, theme),
                                const SizedBox(width: 8),
                                GlassButton(
                                  label: 'NEW',
                                  width: 80,
                                  height: 44,
                                  fontSize: 12,
                                  icon: Icons.add_rounded,
                                  onTap: () => context.push('/loans/new'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Summary Metrics Dashboard
                SliverToBoxAdapter(
                  child: summaryAsync.when(
                    data: (summary) => _buildSummaryDashboard(summary, primary, isDark, theme),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: ShimmerCard(height: 100),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ).animate().fadeIn(delay: 200.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Search and Filter Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    child: Container(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildSearchBar(isDark, theme),
                            ),
                            const SizedBox(height: 16),
                            _buildTabBar(isDark, theme),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Loan List
                loansAsync.when(
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

                    // Apply Sorting
                    filtered.sort((a, b) {
                      int cmp;
                      switch (_sortBy) {
                        case 'amount': cmp = a.amount.compareTo(b.amount); break;
                        case 'balance': cmp = a.outstandingBalance.compareTo(b.outstandingBalance); break;
                        default: cmp = a.createdAt.compareTo(b.createdAt); break;
                      }
                      return _sortAscending ? cmp : -cmp;
                    });

                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(theme, primary),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _LoanListItem(loan: filtered[i]).animate().fadeIn(delay: (50 * i).ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ShimmerCard(height: 160),
                        ),
                        childCount: 5,
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text('Error loading portfolio: $e', style: theme.textTheme.bodySmall),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard(LoanSummary summary, Color primary, bool isDark, ThemeData theme) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _SummaryCard(
            label: 'CAPITAL DEPLOYED',
            value: AppFormatters.formatCompactCurrency(summary.totalDisbursed),
            icon: Icons.account_balance_wallet_rounded,
            color: primary,
          ),
          const SizedBox(width: 16),
          _SummaryCard(
            label: 'OUTSTANDING',
            value: AppFormatters.formatCompactCurrency(summary.totalOutstanding),
            icon: Icons.pie_chart_rounded,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 16),
          _SummaryCard(
            label: 'PAR % (RISK)',
            value: '${summary.parPercentage.toStringAsFixed(1)}%',
            icon: Icons.warning_amber_rounded,
            color: summary.parPercentage > 10 ? Colors.redAccent : Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search portfolio...',
          hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          onTap: (i) => setState(() => _filterStatus = _statusForTab(i)),
          indicator: BoxDecoration(
            color: isDark ? AppColors.elevatedDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: theme.textTheme.bodyLarge?.color,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }

  Widget _buildSortToggle(bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          _sortAscending ? Icons.south_rounded : Icons.north_rounded,
          size: 20,
          color: theme.textTheme.bodySmall?.color,
        ),
        onPressed: () => setState(() => _sortAscending = !_sortAscending),
        tooltip: 'Change Sort Order',
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded, size: 64, color: primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 24),
          Text('No matching records', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Adjust your filters or deploy new capital.', style: theme.textTheme.bodySmall?.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 160,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    
    final progress = 1 - (loan.outstandingBalance / loan.totalRepayable);
    
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
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary.withValues(alpha: 0.2), primary.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Text(
                    (loan.customerName ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: primary, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.customerName ?? 'Unknown Borrower',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        loan.loanNumber,
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType, glow: loan.status == LoanStatus.active),
            ],
          ),
          const SizedBox(height: 20),
          
          // Refined Progress Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('REPAYMENT PROGRESS', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w900, color: primary)),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: 1.seconds,
                    height: 8,
                    width: MediaQuery.of(context).size.width * 0.7 * progress.clamp(0, 1),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'PRINCIPAL', value: AppFormatters.formatCompactCurrency(loan.amount)),
              _InfoChip(label: 'MONTHLY EMI', value: AppFormatters.formatCurrency(loan.emiAmount)),
              _InfoChip(label: 'BALANCE', value: AppFormatters.formatCompactCurrency(loan.outstandingBalance), highlight: true),
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
  final bool highlight;
  const _InfoChip({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(
          value, 
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900, 
            fontSize: 15,
            color: highlight ? primary : null,
          )
        ),
      ],
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 140;
  @override
  double get maxExtent => 140;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) => true;
}