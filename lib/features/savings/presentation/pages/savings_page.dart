import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/savings_model.dart';
import '../../data/providers/savings_providers.dart';

class SavingsPage extends ConsumerStatefulWidget {
  const SavingsPage({super.key});

  @override
  ConsumerState<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends ConsumerState<SavingsPage>
    with SingleTickerProviderStateMixin {
  int _activeFilter = 0; // 0: All, 1: Active, 2: Matured

  @override
  Widget build(BuildContext context) {
    final savingsAsync = ref.watch(savingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0C) : const Color(0xFFF2F2F7),
      body: AuroraBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, theme, isDark),
            SliverToBoxAdapter(
                child: _buildWealthSummary(savingsAsync, theme, isDark)),
            _buildFilters(theme, isDark),
            _buildSavingsList(savingsAsync, theme, isDark),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(),
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        centerTitle: false,
        title: Text(
          'Savings Vault',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () => context.push('/savings/new'),
            icon: const Icon(Icons.add_rounded, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              foregroundColor: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWealthSummary(AsyncValue<List<SavingsModel>> savingsAsync,
      ThemeData theme, bool isDark) {
    return savingsAsync.when(
      data: (savings) {
        final totalSaved = savings.fold(0.0, (sum, s) => sum + s.currentAmount);
        final totalTarget = savings.fold(0.0, (sum, s) => sum + s.targetAmount);
        final progress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.1)),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                        child: const SizedBox()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GLOBAL WEALTH',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6))),
                              const SizedBox(height: 8),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    theme.colorScheme.onSurface,
                                    AppColors.success
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  AppFormatters.formatCurrency(totalSaved),
                                  style: theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      AppColors.success.withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.success
                                        .withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: const Icon(Icons.trending_up_rounded,
                                color: AppColors.success, size: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Maturity Goal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7))),
                          Text(AppFormatters.formatCompactCurrency(totalTarget),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            height: 8,
                            width: (MediaQuery.of(context).size.width - 104) *
                                progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                AppColors.success,
                                Color(0xFF34C759)
                              ]),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.success
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.1);
      },
      loading: () => const Padding(
          padding: EdgeInsets.all(24), child: ShimmerCard(height: 180)),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildFilters(ThemeData theme, bool isDark) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterDelegate(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildFilterPill('All Vaults', 0, theme),
                    const SizedBox(width: 12),
                    _buildFilterPill('Active Plans', 1, theme),
                    const SizedBox(width: 12),
                    _buildFilterPill('Matured', 2, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, int index, ThemeData theme) {
    final isSelected = _activeFilter == index;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeFilter = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(blue: 255)
                ])
              : null,
          color: !isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03))
              : null,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : theme.dividerColor.withValues(alpha: 0.1)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsList(AsyncValue<List<SavingsModel>> savingsAsync,
      ThemeData theme, bool isDark) {
    return savingsAsync.when(
      data: (savings) {
        final filtered = savings.where((s) {
          if (_activeFilter == 1 && s.status != 'active') return false;
          if (_activeFilter == 2 && s.status != 'completed') return false;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState(theme));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final saving = filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/savings/${saving.id}');
                    },
                    child: _PremiumSavingCard(saving: saving),
                  ),
                );
              },
              childCount: filtered.length,
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ShimmerCard(height: 160)),
            childCount: 3,
          ),
        ),
      ),
      error: (e, _) =>
          SliverFillRemaining(child: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text('No Savings Found',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Your financial future starts with a single deposit.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

class _PremiumSavingCard extends StatelessWidget {
  final SavingsModel saving;
  const _PremiumSavingCard({required this.saving});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (saving.targetAmount > 0)
        ? (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.25),
                      AppColors.success.withValues(alpha: 0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saving.memberName,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.formatCurrency(saving.monthlyDeposit)} Recurring',
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMaturityBadge(saving, theme),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right_rounded,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('Saved',
                  AppFormatters.formatCurrency(saving.currentAmount), theme),
              _buildMiniMetric(
                  'Target',
                  AppFormatters.formatCompactCurrency(saving.targetAmount),
                  theme),
              _buildMiniMetric('Yield', '${saving.interestRate}%', theme,
                  color: AppColors.success),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(3)),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 6,
                width: (MediaQuery.of(context).size.width - 88) * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF34C759)]),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 14, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                'Matures on ${AppFormatters.formatDate(saving.maturityDate)}',
                style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: Colors.orange),
              ),
              const Spacer(),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _buildMiniMetric(String label, String value, ThemeData theme,
      {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildMaturityBadge(SavingsModel saving, ThemeData theme) {
    final isMatured = saving.status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isMatured ? AppColors.success : AppColors.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMatured ? 'MATURED' : 'ACTIVE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isMatured ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }
}

class _FilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _FilterDelegate({required this.child});

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  double get maxExtent => 60;
  @override
  double get minExtent => 60;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
