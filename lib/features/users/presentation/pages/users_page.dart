import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text('Add User', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Users', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5))
                .animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),
              const SizedBox(height: 4),
              Text('Manage administrative privileges and user lifecycle', style: theme.textTheme.bodySmall?.copyWith(fontSize: 14))
                .animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 24),

              // ─── Stats Row ───
              Row(children: [
                Expanded(child: _StatCard(label: 'Total', value: '0', icon: Icons.people_rounded, color: primary)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Admins', value: '0', icon: Icons.shield_rounded, color: const Color(0xFF5856D6))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Agents', value: '0', icon: Icons.support_agent_rounded, color: const Color(0xFFFF9F0A))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Members', value: '0', icon: Icons.groups_rounded, color: const Color(0xFF34C759))),
              ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.04, end: 0),

              const SizedBox(height: 20),

              // ─── Search ───
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or ID...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: theme.textTheme.bodySmall?.color),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 32),

              // ─── Empty State ───
              _buildEmptyState(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(children: [
        const SizedBox(height: 48),
        Icon(Icons.person_off_outlined, size: 56, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('No users found', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Add a new user to get started.', style: theme.textTheme.bodySmall),
      ]),
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
