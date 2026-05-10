import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/new_loan_provider.dart';

class NewLoanPage extends ConsumerStatefulWidget {
  const NewLoanPage({super.key});

  @override
  ConsumerState<NewLoanPage> createState() => _NewLoanPageState();
}

class _NewLoanPageState extends ConsumerState<NewLoanPage> {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final currencyFormatNoDecimals = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(newLoanProvider);
      _principalController.text = state.principalAmount.toInt().toString();
      _rateController.text = state.interestRate.toString();
      _tenureController.text = state.tenureMonths.toString();
    });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newLoanProvider);
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
            ref.read(newLoanProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Loan',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Configure financial terms',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          _buildActionIcon(Icons.auto_awesome, theme, isDark),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.account_balance, theme, isDark),
          const SizedBox(width: 16),
        ],
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
                  Expanded(flex: 2, child: _buildFacilityDetails(state, theme, isDark, primary)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 1, child: _buildFinancialSummary(state, theme, isDark, primary)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildFinancialSummary(state, theme, isDark, primary),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFacilityDetails(state, theme, isDark, primary),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: theme.colorScheme.primary),
    );
  }

  Widget _buildFacilityDetails(NewLoanState state, ThemeData theme, bool isDark, Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: primary, size: 20),
              const SizedBox(width: 8),
              Text('Facility Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildLabel('BORROWER ACCOUNT *', theme),
          const SizedBox(height: 8),
          _buildDropdown(
            value: state.borrowerId,
            hint: 'Select registered customer',
            items: [],
            onChanged: (val) => ref.read(newLoanProvider.notifier).updateBorrower(val),
            theme: theme, isDark: isDark,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('PRINCIPAL AMOUNT (₹) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _principalController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newLoanProvider.notifier).updatePrincipal(parsed);
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
                    _buildLabel('INTEREST RATE (%) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _rateController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newLoanProvider.notifier).updateInterestRate(parsed);
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
                    _buildLabel('FREQUENCY', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: state.frequency.name,
                      hint: 'Select',
                      items: LoanFrequency.values.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(newLoanProvider.notifier).updateFrequency(
                            LoanFrequency.values.firstWhere((e) => e.name == val)
                          );
                        }
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
              Expanded(
                flex: 2,
                child: _buildSlider(
                  value: state.principalAmount.clamp(1000, 1000000),
                  min: 1000, max: 1000000,
                  label: 'ADJUST AMOUNT',
                  displayValue: currencyFormatNoDecimals.format(state.principalAmount),
                  minLabel: '₹1,000', maxLabel: '₹10,00,000',
                  onChanged: (val) {
                    _principalController.text = val.toInt().toString();
                    ref.read(newLoanProvider.notifier).updatePrincipal(val);
                  },
                  theme: theme, primary: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 2,
                child: _buildSlider(
                  value: state.interestRate.clamp(0, 50),
                  min: 0, max: 50,
                  label: 'ADJUST RATE',
                  displayValue: '${state.interestRate.toStringAsFixed(1)}%',
                  minLabel: '0%', maxLabel: '50%',
                  onChanged: (val) {
                    _rateController.text = val.toStringAsFixed(1);
                    ref.read(newLoanProvider.notifier).updateInterestRate(val);
                  },
                  theme: theme, primary: theme.colorScheme.primary,
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
                    _buildLabel('TENURE (MONTHS) *', theme),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _tenureController,
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 1;
                        ref.read(newLoanProvider.notifier).updateTenure(parsed);
                      },
                      theme: theme, isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      value: state.tenureMonths.toDouble().clamp(1, 120),
                      min: 1, max: 120,
                      label: 'ADJUST TENURE',
                      displayValue: '${state.tenureMonths} Mo',
                      minLabel: '1 Mo', maxLabel: '120 Mo',
                      onChanged: (val) {
                        _tenureController.text = val.toInt().toString();
                        ref.read(newLoanProvider.notifier).updateTenure(val.toInt());
                      },
                      theme: theme, primary: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildLabel('COLLECTION TYPE *', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: state.collectionType.name,
                      hint: 'Select',
                      items: LoanFrequency.values.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(newLoanProvider.notifier).updateCollectionType(
                            LoanFrequency.values.firstWhere((e) => e.name == val)
                          );
                        }
                      },
                      theme: theme, isDark: isDark,
                    ),
                  ],
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
                    _buildLabel('INTEREST LOGIC', theme),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: state.interestLogic.name,
                      hint: 'Select logic',
                      items: InterestLogic.values.map((e) => e.name).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(newLoanProvider.notifier).updateInterestLogic(
                            InterestLogic.values.firstWhere((e) => e.name == val)
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
                    _buildLabel('FIRST INSTALLMENT DATE *', theme),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          ref.read(newLoanProvider.notifier).updateFirstInstallmentDate(date);
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
                              state.firstInstallmentDate != null 
                                ? DateFormat('MM/dd/yyyy').format(state.firstInstallmentDate!)
                                : 'mm/dd/yyyy',
                              style: TextStyle(
                                color: state.firstInstallmentDate != null 
                                    ? theme.colorScheme.onSurface 
                                    : theme.textTheme.bodySmall?.color,
                              ),
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
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(newLoanProvider.notifier).reset();
                  context.pop();
                },
                child: Text('Discard', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Loan Application...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Create Application', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFinancialSummary(NewLoanState state, ThemeData theme, bool isDark, Color primary) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate_outlined, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 8),
                  Text('Financial Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSummaryRow('CAPITAL OUTLAY', currencyFormatNoDecimals.format(state.principalAmount), theme),
              const SizedBox(height: 16),
              _buildSummaryRow('YIELD RATE', '${state.interestRate}% APR', theme),
              const SizedBox(height: 16),
              _buildSummaryRow('MATURITY', '${state.tenureMonths} Months (${state.numberOfInstallments} ${state.collectionType.name}s)', theme),
              
              const SizedBox(height: 24),
              Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
              const SizedBox(height: 24),
              
              Text('ESTIMATED INSTALLMENT', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(state.estimatedInstallment),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: primary),
              ),
              
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    height: 4, width: 40,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned(
                    left: 36,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹500', style: theme.textTheme.labelSmall),
                  Text('₹50,000', style: theme.textTheme.labelSmall),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSummaryRow('INTEREST BURDEN', currencyFormat.format(state.interestBurden), theme),
              
              const SizedBox(height: 24),
              Text('TOTAL EXPOSURE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(state.totalExposure),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
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
                  Icon(Icons.schedule, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 8),
                  Text('Amortization Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'The system will generate a full ${state.interestLogic == InterestLogic.reducingBalance ? 'reducing balance' : 'flat rate'} schedule upon approval. Late payment penalties may apply as per global policy.',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 14)),
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
