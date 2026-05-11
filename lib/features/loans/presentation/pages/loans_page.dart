import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../data/models/loan_model.dart';
import '../providers/loan_providers.dart';

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
  String _sortBy = 'recent'; // 'recent', 'amount', 'balance'
  bool _sortAscending = false;

  final _tabs = const ['All', 'Active', 'Defaulted', 'Closed'];

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
      case 2: return LoanStatus.defaultStatus;
      case 3: return LoanStatus.closed;
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
                                      letterSpacing: -1.5,
                                      fontSize: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Capital Deployment & Risk Analytics',
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
                            GlassButton(
                              label: 'DEPLOY',
                              width: 100,
                              height: 46,
                              fontSize: 13,
                              icon: Icons.rocket_launch_rounded,
                              onTap: () => context.push('/loans/new'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Summary Metrics Dashboard
                SliverToBoxAdapter(
                  child: summaryAsync.when(
                    data: (summary) => _buildSummaryDashboard(summary, primary, isDark, theme),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: ShimmerCard(height: 120),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ).animate().fadeIn(delay: 200.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Search and Filter Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    child: Container(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(child: _buildSearchBar(isDark, theme)),
                                const SizedBox(width: 12),
                                _buildSortMenu(isDark, theme),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTabBar(isDark, theme),
                          const SizedBox(height: 16),
                        ],
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
                        case 'progress': 
                          final pA = 1 - (a.outstandingBalance / a.totalRepayable);
                          final pB = 1 - (b.outstandingBalance / b.totalRepayable);
                          cmp = pA.compareTo(pB);
                          break;
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
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _LoanListItem(loan: filtered[i]).animate()
                                .fadeIn(delay: (50 * i).ms)
                                .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
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
                          padding: EdgeInsets.only(bottom: 20),
                          child: ShimmerCard(height: 180),
                        ),
                        childCount: 4,
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
      height: 120,
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
            trend: '+12%',
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
            subtitle: 'Portfolio at Risk',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, ThemeData theme) {
    return Container(
      height: 52,
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
          hintText: 'Search borrower or loan ID...',
          hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSortMenu(bool isDark, ThemeData theme) {
    return PopupMenuButton<String>(
      onSelected: (val) => setState(() {
        if (_sortBy == val) {
          _sortAscending = !_sortAscending;
        } else {
          _sortBy = val;
          _sortAscending = false;
        }
      }),
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'recent', child: Text('Sort by Date')),
        const PopupMenuItem(value: 'amount', child: Text('Sort by Amount')),
        const PopupMenuItem(value: 'balance', child: Text('Sort by Balance')),
        const PopupMenuItem(value: 'progress', child: Text('Sort by Progress')),
      ],
      child: Container(
        height: 52, width: 52,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 22),
      ),
    );
  }

  Widget _buildTabBar(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
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
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.textTheme.bodySmall?.color,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          dividerColor: Colors.transparent,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_rounded, size: 72, color: primary.withValues(alpha: 0.2)),
          ),
          const SizedBox(height: 24),
          Text('Empty Portfolio', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 8),
          Text('No loans found matching your criteria.', style: theme.textTheme.bodySmall?.copyWith(fontSize: 16)),
          const SizedBox(height: 24),
          GlassButton(
            label: 'Deploy First Loan',
            width: 200,
            onTap: () => context.push('/loans/new'),
          ),
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
  final String? trend;
  final String? subtitle;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SizedBox(
      width: 180,
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: color),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(trend!, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                color: isDark ? Colors.white : Colors.black,
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

  Future<void> _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _makeWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    
    final progress = loan.totalRepayable > 0 
        ? (1 - (loan.outstandingBalance / loan.totalRepayable)).clamp(0.0, 1.0)
        : 0.0;
    
    final statusType = loan.status == LoanStatus.active
        ? StatusType.standard
        : loan.status == LoanStatus.defaultStatus
            ? StatusType.defaultStatus
            : loan.status == LoanStatus.pending
                ? StatusType.pending
                : StatusType.completed;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/loans/${loan.id}');
      },
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'loan_avatar_${loan.id}',
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primary.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: Text(
                      (loan.customerName ?? '?')[0].toUpperCase(),
                      style: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.customerName ?? 'Unknown Borrower',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.fingerprint_rounded, size: 12, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          loan.loanNumber,
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontFamily: 'JetBrains Mono', fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(label: loan.status.name.toUpperCase(), type: statusType, glow: loan.status == LoanStatus.active),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Refined Progress Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('COLLECTION PROGRESS', style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5))),
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: primary)),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedContainer(
                    duration: 1200.ms,
                    curve: Curves.easeOutQuart,
                    height: 10,
                    width: (MediaQuery.of(context).size.width - 92) * progress.clamp(0, 1),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'PRINCIPAL', value: AppFormatters.formatCompactCurrency(loan.amount)),
              _InfoChip(label: 'MONTHLY EMI', value: AppFormatters.formatCurrency(loan.emiAmount)),
              _InfoChip(label: 'BALANCE', value: AppFormatters.formatCompactCurrency(loan.outstandingBalance), highlight: true),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 14, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Text(
                      'Next: ${AppFormatters.formatDate(loan.firstEmiDate ?? loan.createdAt.add(const Duration(days: 30)))}',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (loan.customerPhone != null) ...[
                IconButton(
                  onPressed: () => _makeCall(loan.customerPhone!),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: primary.withValues(alpha: 0.1),
                    foregroundColor: primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _makeWhatsApp(loan.customerPhone!),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                    foregroundColor: AppColors.success,
                  ),
                ),
              ],
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
        const SizedBox(height: 6),
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