import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            ref.read(newLoanProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Loan Application',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Configure financial terms and borrower information',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          _buildActionIcon(Icons.auto_awesome),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.account_balance),
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
                  Expanded(flex: 2, child: _buildFacilityDetails(state)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 1, child: _buildFinancialSummary(state)),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildFinancialSummary(state),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFacilityDetails(state),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Icon(icon, size: 18, color: AppColors.primaryTeal),
    );
  }

  Widget _buildFacilityDetails(NewLoanState state) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Facility Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildLabel('BORROWER ACCOUNT *'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: state.borrowerId,
            hint: 'Select registered customer',
            items: [], // Will populate later from DB
            onChanged: (val) => ref.read(newLoanProvider.notifier).updateBorrower(val),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('PRINCIPAL AMOUNT (₹) *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _principalController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newLoanProvider.notifier).updatePrincipal(parsed);
                      },
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
                    _buildLabel('INTEREST RATE (%) *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _rateController,
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        ref.read(newLoanProvider.notifier).updateInterestRate(parsed);
                      },
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
                    _buildLabel('FREQUENCY'),
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
                  min: 1000,
                  max: 1000000,
                  label: 'ADJUST AMOUNT',
                  displayValue: currencyFormatNoDecimals.format(state.principalAmount),
                  minLabel: '₹1,000',
                  maxLabel: '₹10,00,000',
                  onChanged: (val) {
                    _principalController.text = val.toInt().toString();
                    ref.read(newLoanProvider.notifier).updatePrincipal(val);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 2,
                child: _buildSlider(
                  value: state.interestRate.clamp(0, 50),
                  min: 0,
                  max: 50,
                  label: 'ADJUST RATE',
                  displayValue: '${state.interestRate.toStringAsFixed(1)}%',
                  minLabel: '0%',
                  maxLabel: '50%',
                  onChanged: (val) {
                    _rateController.text = val.toStringAsFixed(1);
                    ref.read(newLoanProvider.notifier).updateInterestRate(val);
                  },
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
                    _buildLabel('TENURE (MONTHS) *'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _tenureController,
                      onChanged: (val) {
                        final parsed = int.tryParse(val) ?? 1;
                        ref.read(newLoanProvider.notifier).updateTenure(parsed);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      value: state.tenureMonths.toDouble().clamp(1, 120),
                      min: 1,
                      max: 120,
                      label: 'ADJUST TENURE',
                      displayValue: '${state.tenureMonths} Mo',
                      minLabel: '1 Mo',
                      maxLabel: '120 Mo',
                      onChanged: (val) {
                        _tenureController.text = val.toInt().toString();
                        ref.read(newLoanProvider.notifier).updateTenure(val.toInt());
                      },
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
                    _buildLabel('COLLECTION TYPE *'),
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
                    _buildLabel('INTEREST LOGIC'),
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
                    _buildLabel('FIRST INSTALLMENT DATE *'),
                    const SizedBox(height: 8),
                    InkWell(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.firstInstallmentDate != null 
                                ? DateFormat('MM/dd/yyyy').format(state.firstInstallmentDate!)
                                : 'mm/dd/yyyy',
                              style: TextStyle(
                                color: state.firstInstallmentDate != null ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textMuted),
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
                child: const Text('Discard', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Submit logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Loan Application...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Create Application', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildFinancialSummary(NewLoanState state) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate_outlined, color: AppColors.textPrimary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Financial Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              _buildSummaryRow('CAPITAL OUTLAY', currencyFormatNoDecimals.format(state.principalAmount)),
              const SizedBox(height: 16),
              _buildSummaryRow('YIELD RATE', '${state.interestRate}% APR'),
              const SizedBox(height: 16),
              _buildSummaryRow('MATURITY', '${state.tenureMonths} Months (${state.tenureMonths} ${state.collectionType.name}s)'),
              
              const SizedBox(height: 24),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 24),
              
              Text('ESTIMATED INSTALLMENT', style: TextStyle(color: AppColors.textMutedLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(state.estimatedInstallment),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryTeal),
              ),
              
              const SizedBox(height: 16),
              // Visual Range Slider matching screenshot
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    height: 4,
                    width: 40, // Static visual representation for now
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned(
                    left: 36,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹500', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                  Text('₹50,000', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSummaryRow('INTEREST BURDEN', currencyFormat.format(state.interestBurden)),
              
              const SizedBox(height: 24),
              
              Text('TOTAL EXPOSURE', style: TextStyle(color: AppColors.textMutedLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(state.totalExposure),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
                  const Icon(Icons.schedule, color: AppColors.textPrimary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Amortization Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'The system will generate a full ${state.interestLogic == InterestLogic.reducingBalance ? 'reducing balance' : 'flat rate'} schedule upon approval. Late payment penalties may apply as per global policy.',
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textMutedLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: AppColors.textMutedLight,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required Function(String) onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: TextStyle(color: AppColors.textMuted)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                _capitalize(item),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, size: 4, color: AppColors.primaryTeal),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedLight, letterSpacing: 1),
                ),
              ],
            ),
            Text(
              displayValue,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryTeal),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primaryTeal.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.glassBorder,
            thumbColor: AppColors.primaryTeal,
            overlayColor: AppColors.primaryTeal.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: TextStyle(fontSize: 9, color: AppColors.textMutedLight)),
            Text(maxLabel, style: TextStyle(fontSize: 9, color: AppColors.textMutedLight)),
          ],
        ),
      ],
    );
  }
}
