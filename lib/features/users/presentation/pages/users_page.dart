import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/users/new'),
        backgroundColor: primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.person_add_alt_1_rounded, size: 22, color: isDark ? Colors.black : Colors.white),
        label: Text('Add User', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.3, color: isDark ? Colors.black : Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Users',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  fontSize: 32,
                ),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),
              const SizedBox(height: 4),
              Text(
                'Manage administrative privileges and user lifecycle',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Total', value: '0', icon: Icons.people_rounded, color: primary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Admins', value: '0', icon: Icons.shield_rounded, color: isDark ? AppColors.accentDark : AppColors.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Agents', value: '0', icon: Icons.support_agent_rounded, color: isDark ? AppColors.warningDark : AppColors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Members', value: '0', icon: Icons.groups_rounded, color: isDark ? AppColors.successDark : AppColors.success)),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.04, end: 0),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or ID...',
                    hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, size: 22, color: theme.textTheme.bodySmall?.color),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 32),
              _buildEmptyState(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.person_off_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text('No users found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add a new user to get started.', style: theme.textTheme.bodySmall),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 22)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
