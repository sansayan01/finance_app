import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/enums.dart';
import '../providers/loan_providers.dart';
import '../../data/models/emi_schedule_model.dart';
import '../../data/models/loan_model.dart';

class CollectionSheet extends ConsumerStatefulWidget {
  final LoanModel loan;
  final EMIScheduleModel emi;

  const CollectionSheet({
    super.key,
    required this.loan,
    required this.emi,
  });

  @override
  ConsumerState<CollectionSheet> createState() => _CollectionSheetState();
}

class _CollectionSheetState extends ConsumerState<CollectionSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMode _selectedMode = PaymentMode.cash;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.emi.emiAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final repository = ref.read(emiRepositoryProvider);
      await repository.recordPayment(
        emiId: widget.emi.id,
        loanId: widget.loan.id,
        amount: double.parse(_amountController.text),
        paymentMode: _selectedMode.name,
        notes: _notesController.text,
      );
      
      // Invalidate providers to refresh UI
      ref.invalidate(emiScheduleProvider(widget.loan.id));
      ref.invalidate(loanDetailProvider(widget.loan.id));
      ref.invalidate(loansProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Payment',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'EMI #${widget.emi.emiNumber} · ${widget.loan.loanNumber}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'COLLECTION AMOUNT',
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: primary),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: theme.textTheme.headlineSmall?.copyWith(color: primary, fontWeight: FontWeight.w900),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'PAYMENT MODE',
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildModeOption(PaymentMode.cash, Icons.payments_outlined),
              const SizedBox(width: 12),
              _buildModeOption(PaymentMode.upi, Icons.qr_code_2_rounded),
              const SizedBox(width: 12),
              _buildModeOption(PaymentMode.bankTransfer, Icons.account_balance_rounded),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'NOTES (OPTIONAL)',
            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add a note about this collection...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Collection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(PaymentMode mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? primary : theme.dividerColor.withValues(alpha: 0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primary : theme.colorScheme.onSurface, size: 24),
              const SizedBox(height: 8),
              Text(
                mode.name.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? primary : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
