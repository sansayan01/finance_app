import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Text('Settings', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5))
                .animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),
              const SizedBox(height: 4),
              Text('Customize your experience', style: theme.textTheme.bodySmall?.copyWith(fontSize: 14))
                .animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 28),

              // ─── Appearance ───
              _SectionCard(
                title: 'Appearance',
                icon: Icons.palette_outlined,
                children: [
                  _SwitchRow(
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark themes',
                    value: ref.watch(themeProvider) == ThemeMode.dark,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 16),

              // ─── System Parameters ───
              _SectionCard(
                title: 'System Parameters',
                icon: Icons.tune_rounded,
                children: [
                  _SliderRow(title: 'Default Loan Interest', value: settings.defaultLoanInterest, min: 5, max: 25, unit: '%', onChanged: notifier.updateLoanInterest),
                  _SliderRow(title: 'Savings Maturity Yield', value: settings.defaultSavingsYield, min: 2, max: 15, unit: '%', onChanged: notifier.updateSavingsYield),
                  _SliderRow(title: 'Late Payment Penalty', value: settings.latePenaltyPercentage, min: 0, max: 5, unit: '%', onChanged: notifier.updatePenalty),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 16),

              // ─── Security ───
              _SectionCard(
                title: 'Security & Notifications',
                icon: Icons.shield_outlined,
                children: [
                  _SwitchRow(title: 'Biometric Authentication', subtitle: 'Use fingerprint or face ID', value: settings.biometricAuth, onChanged: notifier.toggleBiometric),
                  _SwitchRow(title: 'Notifications', subtitle: 'Late payment and maturity alerts', value: settings.enableNotifications, onChanged: notifier.toggleNotifications),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 28),

              // ─── Save Button ───
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Apply Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(1.seconds);
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('Settings saved successfully'),
      ]),
      backgroundColor: const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        ])),
        Switch.adaptive(value: value, onChanged: onChanged),
      ]),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.title, required this.value, required this.min, required this.max, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Text('${value.toStringAsFixed(1)}$unit', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
        const SizedBox(height: 4),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ]),
    );
  }
}
