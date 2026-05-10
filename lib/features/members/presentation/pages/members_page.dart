import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/kyc_validators.dart';
import '../providers/member_providers.dart';
import '../../data/models/member_model.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, primary),
          const SizedBox(height: AppSpacing.lg),
          _buildSearchBar(theme, isDark),
          const SizedBox(height: AppSpacing.lg),
          _buildMemberStats(theme, primary),
          const SizedBox(height: AppSpacing.lg),
          _buildMembersList(theme, isDark, primary),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage member records and KYC',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.person_add, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Add Member',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(membersSearchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or ID...',
          prefixIcon: Icon(Icons.search, color: theme.textTheme.bodySmall?.color),
          suffixIcon: IconButton(
            icon: Icon(Icons.tune, color: theme.textTheme.bodySmall?.color),
            onPressed: () {},
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMemberStats(ThemeData theme, Color primary) {
    final summaryAsync = ref.watch(memberSummaryProvider);

    return summaryAsync.when(
      data: (summary) => Row(
        children: [
          Expanded(
            child: _MemberStatCard(label: 'Total Members', value: summary.totalMembers.toString(), icon: Icons.people, color: primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MemberStatCard(label: 'Active', value: summary.activeMembers.toString(), icon: Icons.check_circle, color: const Color(0xFF34C759)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MemberStatCard(label: 'Pending KYC', value: summary.pendingKYC.toString(), icon: Icons.pending, color: const Color(0xFFFF9F0A)),
          ),
        ],
      ),
      loading: () => const ShimmerStatsRow(itemCount: 3),
      error: (_, __) => const SizedBox.shrink(),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMembersList(ThemeData theme, bool isDark, Color primary) {
    final membersAsync = ref.watch(membersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member List',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        membersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Text('No members found', style: theme.textTheme.bodySmall),
                ),
              );
            }
            return Column(
              children: members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MemberCard(member: member)
                      .animate(delay: (300 + index * 50).ms)
                      .fadeIn()
                      .slideX(begin: 0.05, end: 0),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: ShimmerCard(height: 90),
              ),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading members: ${err.toString().contains('404') || err.toString().contains('PGRST205') ? 'Database table missing' : err}',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  if (err.toString().contains('PGRST205'))
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Please run the supabase_schema.sql script in your Supabase SQL editor.',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MemberStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
            child: Center(
              child: Text(
                member.fullName.isNotEmpty ? member.fullName[0] : '?',
                style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.memberId} • ${KYCValidators.formatPhoneForDisplay(member.phone)}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoPill(icon: Icons.account_balance, label: '${member.activeLoans} Loans'),
                    const SizedBox(width: AppSpacing.xs),
                    _InfoPill(icon: Icons.savings, label: AppFormatters.formatCompactCurrency(member.totalSavings)),
                  ],
                ),
              ],
            ),
          ),
          _KYCStatusBadge(status: member.kycStatus),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: theme.textTheme.bodySmall?.color),
          const SizedBox(width: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _KYCStatusBadge extends StatelessWidget {
  final KYCStatus status;

  const _KYCStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case KYCStatus.verified:
        color = const Color(0xFF34C759);
        label = 'Verified';
        icon = Icons.verified;
      case KYCStatus.pending:
        color = const Color(0xFFFF9F0A);
        label = 'Pending';
        icon = Icons.pending;
      case KYCStatus.rejected:
        color = const Color(0xFFFF3B30);
        label = 'Rejected';
        icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}