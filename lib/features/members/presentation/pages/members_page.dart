import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_text_field.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildSearchBar(),
          const SizedBox(height: AppSpacing.lg),
          _buildMemberStats(),
          const SizedBox(height: AppSpacing.lg),
          _buildMembersList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage member records and KYC',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.person_add, color: AppColors.textPrimary, size: 20),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Add Member',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSearchBar() {
    return GlassTextField(
      hint: 'Search by name, phone, or ID...',
      controller: _searchController,
      onChanged: (value) {
        ref.read(membersSearchQueryProvider.notifier).state = value;
      },
      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
      suffixIcon: IconButton(
        icon: const Icon(Icons.tune, color: AppColors.textMuted),
        onPressed: () {},
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMemberStats() {
    final summaryAsync = ref.watch(memberSummaryProvider);

    return summaryAsync.when(
      data: (summary) => Row(
        children: [
          Expanded(
            child: _MemberStatCard(
              label: 'Total Members',
              value: summary.totalMembers.toString(),
              icon: Icons.people,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MemberStatCard(
              label: 'Active',
              value: summary.activeMembers.toString(),
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MemberStatCard(
              label: 'Pending KYC',
              value: summary.pendingKYC.toString(),
              icon: Icons.pending,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
      loading: () => const ShimmerStatsRow(itemCount: 3),
      error: (_, __) => const SizedBox.shrink(),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMembersList() {
    final membersAsync = ref.watch(membersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Member List',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        membersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: const Center(
                  child: Text(
                    'No members found',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
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
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error loading members: ${err.toString().contains('404') || err.toString().contains('PGRST205') ? 'Database table missing' : err}',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  if (err.toString().contains('PGRST205'))
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Please run the supabase_schema.sql script in your Supabase SQL editor.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
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
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
            child: Center(
              child: Text(
                member.fullName.isNotEmpty ? member.fullName[0] : '?',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.memberId} • ${KYCValidators.formatPhoneForDisplay(member.phone)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoPill(
                      icon: Icons.account_balance,
                      label: '${member.activeLoans} Loans',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _InfoPill(
                      icon: Icons.savings,
                      label: AppFormatters.formatCompactCurrency(member.totalSavings),
                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textMuted),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
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
        color = AppColors.success;
        label = 'Verified';
        icon = Icons.verified;
      case KYCStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        icon = Icons.pending;
      case KYCStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
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
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}