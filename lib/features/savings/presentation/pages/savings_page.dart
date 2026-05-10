import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/progress_gauge.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/savings_model.dart';
import '../../data/providers/savings_providers.dart';

class SavingsPage extends ConsumerStatefulWidget {
  const SavingsPage({super.key});

  @override
  ConsumerState<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends ConsumerState<SavingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savingsAsync = ref.watch(savingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings/new'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Savings', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('Track recurring savings plans', style: theme.textTheme.bodySmall?.copyWith(fontSize: 14)),
              ]),
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),

            const SizedBox(height: 16),

            // ─── Search ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search savings plans...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: theme.textTheme.bodySmall?.color),
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
                  onTap: (i) => setState(() => _activeTab = i),
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
                  tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Completed')],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // ─── List ───
            Expanded(
              child: savingsAsync.when(
                data: (savings) {
                  var filtered = savings.where((s) {
                    if (_activeTab == 1 && s.status != 'active') return false;
                    if (_activeTab == 2 && s.status != 'completed') return false;
                    if (_searchQuery.isNotEmpty) {
                      final q = _searchQuery.toLowerCase();
                      return s.memberName.toLowerCase().contains(q);
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) return _buildEmpty(theme);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SavingsListItem(saving: filtered[i], theme: theme)
                        .animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.03, end: 0),
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerCard(height: 120)),
                ),
                error: (e, _) => Center(child: Text('Error: $e', style: theme.textTheme.bodySmall)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.savings_outlined, size: 56, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3)),
      const SizedBox(height: 16),
      Text('No savings plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Create a new plan to get started.', style: theme.textTheme.bodySmall),
    ]));
  }
}

class _SavingsListItem extends StatelessWidget {
  final SavingsModel saving;
  final ThemeData theme;
  const _SavingsListItem({required this.saving, required this.theme});

  @override
  Widget build(BuildContext context) {
    final progress = (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0);
    final statusType = saving.status == 'active' ? StatusType.active
        : saving.status == 'completed' ? StatusType.completed : StatusType.pending;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFF34C759).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(saving.memberName[0].toUpperCase(), style: const TextStyle(color: Color(0xFF34C759), fontSize: 17, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(saving.memberName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
            Text('${AppFormatters.formatCurrency(saving.depositAmount)} / ${saving.frequency}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
          ])),
          StatusBadge(label: saving.status.toUpperCase(), type: statusType, glow: false),
        ]),
        const SizedBox(height: 14),
        LinearProgressBar(
          value: progress,
          height: 5,
          progressColor: const Color(0xFF34C759),
          backgroundColor: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _InfoChip(label: 'Saved', value: AppFormatters.formatCurrency(saving.currentAmount), theme: theme),
          _InfoChip(label: 'Target', value: AppFormatters.formatCompactCurrency(saving.targetAmount), theme: theme),
          _InfoChip(label: 'Progress', value: '${(progress * 100).toInt()}%', theme: theme),
        ]),
      ]),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
      Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
    ]);
  }
}