import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/status_badge.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings/new'),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.3)),
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
                    'Savings',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track recurring savings plans',
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
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search savings plans...',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, size: 22, color: theme.textTheme.bodySmall?.color),
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
                  onTap: (i) => setState(() => _activeTab = i),
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
                  tabs: const [Tab(text: 'All'), Tab(text: 'Active'), Tab(text: 'Completed')],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 20),

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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SavingsListItem(saving: filtered[i])
                        .animate().fadeIn(delay: (50 * i).ms).slideX(begin: 0.03, end: 0),
                    ),
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: 4,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: ShimmerCard(height: 140),
                  ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text('No savings plans', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Create a new plan to get started.', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SavingsListItem extends StatelessWidget {
  final SavingsModel saving;
  const _SavingsListItem({required this.saving});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0);
    final statusType = saving.status == 'active'
        ? StatusType.active
        : saving.status == 'completed'
            ? StatusType.completed
            : StatusType.pending;

    return GlassCard(
      padding: const EdgeInsets.all(20),
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
                    colors: [AppColors.success.withValues(alpha: 0.15), AppColors.success.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    saving.memberName[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.success, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saving.memberName,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.formatCurrency(saving.monthlyDeposit)} / Month',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: saving.status.toUpperCase(), type: statusType, glow: false),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(label: 'Saved', value: AppFormatters.formatCurrency(saving.currentAmount)),
              _InfoChip(label: 'Target', value: AppFormatters.formatCompactCurrency(saving.targetAmount)),
              _InfoChip(label: 'Progress', value: '${(progress * 100).toInt()}%'),
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