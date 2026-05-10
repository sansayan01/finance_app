import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/new_recurring_saving_provider.dart';

class NewRecurringSavingPage extends ConsumerStatefulWidget {
  const NewRecurringSavingPage({super.key});

  @override
  ConsumerState<NewRecurringSavingPage> createState() => _NewRecurringSavingPageState();
}

class _NewRecurringSavingPageState extends ConsumerState<NewRecurringSavingPage> {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final currencyFormatNoDecimals = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _maturityAmountController = TextEditingController();
  final TextEditingController _penaltyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(newRecurringSavingProvider);
      _installmentController.text = state.installmentAmount.toInt().toString();
      _maturityAmountController.text = state.maturityAmount.toInt().toString();
      _penaltyController.text = state.prematurePenalty.toInt().toString();
    });
  }

  @override
  void dispose() {
    _installmentController.dispose();
    _maturityAmountController.dispose();
    _penaltyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newRecurringSavingProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () {
            ref.read(newRecurringSavingProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Savings',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Set up a new recurring saving plan',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildFormDetails(state, theme, isDark, primary)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 1, child: _buildSummary(state, theme, isDark, primary)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildSummary(state, theme, isDark, primary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFormDetails(state, theme, isDark, primary),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFormDetails(NewRecurringSavingState state, ThemeData theme, bool isDark, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: primary, size: 20),
              const SizedBox(width: 8),
              Text('Account Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildLabel('MEMBER ACCOUNT *', theme),
          const SizedBox(height: 8),
          _buildDropdown(
            value: state.memberId,
            hint: 'Select registered member',
            items: [],
            onChanged: (val) => ref.read(newRecurringSavingProvider.notifier).updateMember(val),
            theme: theme, isDark: isDark,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('COLLECTION TYPE *', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: state.collectionType.name,
                      hint: 'Select',
                      items: CollectionType.values.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(newRecurringSavingProvider.notifier).updateCollectionType(
                            CollectionType.values.firstWhere((e) => e.name == val)
                          );
                        }
                      },
                      theme: theme, isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('INSTALLMENT AMOUNT (₹) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _installmentController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newRecurringSavingProvider.notifier).updateInstallmentAmount(parsed);
                      },
                      theme: theme, isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 1,
                child: _buildSlider(
                  value: state.installmentAmount.clamp(10, 50000),
                  min: 10,
                  max: 50000,
                  label: 'ADJUST INSTALLMENT',
                  displayValue: currencyFormatNoDecimals.format(state.installmentAmount),
                  minLabel: '₹10',
                  maxLabel: '₹50,000',
                  onChanged: (val) {
                    _installmentController.text = val.toInt().toString();
                    ref.read(newRecurringSavingProvider.notifier).updateInstallmentAmount(val);
                  },
                  theme: theme, primary: primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('MATURITY AMOUNT (₹) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _maturityAmountController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newRecurringSavingProvider.notifier).updateMaturityAmount(parsed);
                      },
                      theme: theme, isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('MATURITY DATE *', theme),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.maturityDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          ref.read(newRecurringSavingProvider.notifier).updateMaturityDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(state.maturityDate),
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                            Icon(Icons.calendar_today_outlined, size: 18, color: theme.textTheme.bodySmall?.color),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildSlider(
                  value: state.maturityAmount.clamp(1000, 5000000),
                  min: 1000,
                  max: 5000000,
                  label: 'ADJUST GOAL',
                  displayValue: currencyFormatNoDecimals.format(state.maturityAmount),
                  minLabel: '₹1,000',
                  maxLabel: '₹50,00,000',
                  onChanged: (val) {
                    _maturityAmountController.text = val.toInt().toString();
                    ref.read(newRecurringSavingProvider.notifier).updateMaturityAmount(val);
                  },
                  theme: theme, primary: primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('PREMATURE PENALTY (%) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _penaltyController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newRecurringSavingProvider.notifier).updatePrematurePenalty(parsed);
                      },
                      theme: theme, isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      value: state.prematurePenalty.clamp(0, 10),
                      min: 0,
                      max: 10,
                      label: 'ADJUST PENALTY',
                      displayValue: '${state.prematurePenalty.toInt()}%',
                      minLabel: '0%',
                      maxLabel: '10%',
                      onChanged: (val) {
                        _penaltyController.text = val.toInt().toString();
                        ref.read(newRecurringSavingProvider.notifier).updatePrematurePenalty(val);
                      },
                      theme: theme, primary: primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30D158).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF30D158).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF30D158), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRINCIPAL PROTECTED',
                              style: TextStyle(color: Color(0xFF30D158), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This plan is fully insured and capital-guaranteed.',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(newRecurringSavingProvider.notifier).reset();
                  context.pop();
                },
                child: Text('Discard', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Account...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Open Account', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSummary(NewRecurringSavingState state, ThemeData theme, bool isDark, Color primary) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.radar_outlined, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 8),
                  Text('Wealth Forecast', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSummaryRow('DEPOSIT CYCLE', _capitalize(state.collectionType.name), theme),
              const SizedBox(height: 16),
              _buildSummaryRow('PERIODIC INSTALLMENT', currencyFormat.format(state.installmentAmount), theme),
              const SizedBox(height: 16),
              _buildSummaryRow('TOTAL TENURE', '${state.totalInstallments} installments', theme),
              const SizedBox(height: 16),
              _buildSummaryRow('TOTAL CAPITAL INVESTED', currencyFormat.format(state.totalCapitalInvested), theme),
              const SizedBox(height: 16),
              _buildSummaryRow('ESTIMATED INTEREST/YIELD', currencyFormat.format(state.estimatedInterest), theme, valueColor: const Color(0xFF30D158)),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GUARANTEED MATURITY', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(state.maturityAmount),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
        
        const SizedBox(height: AppSpacing.lg),
        
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD60A), size: 20),
                  const SizedBox(width: 8),
                  Text('Premature Exit Policy', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'A ${state.prematurePenalty.toInt()}% penalty on total accumulated interest will apply for withdrawals before ${DateFormat('dd/MM/yyyy').format(state.maturityDate)}.',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
        Text(value, style: TextStyle(color: valueColor ?? theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required Function(String) onChanged,
    required ThemeData theme,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: theme.textTheme.bodySmall),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.textTheme.bodySmall?.color),
          dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(_capitalize(item), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required String label,
    required String displayValue,
    required String minLabel,
    required String maxLabel,
    required Function(double) onChanged,
    required ThemeData theme,
    required Color primary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 4, color: primary),
                const SizedBox(width: 4),
                Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
            Text(displayValue, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: primary)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primary.withValues(alpha: 0.3),
            inactiveTrackColor: theme.dividerColor.withValues(alpha: 0.2),
            thumbColor: primary,
            overlayColor: primary.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9)),
            Text(maxLabel, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9)),
          ],
        ),
      ],
    );
  }
}
