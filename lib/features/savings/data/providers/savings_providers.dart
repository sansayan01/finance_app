import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_model.dart';
import '../repositories/savings_repository.dart';
import '../../../../providers/supabase_provider.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository(ref.watch(supabaseClientProvider));
});

final allSavingsProvider = FutureProvider<List<SavingsModel>>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return repository.getActiveSavingsPlans();
});

final savingsSummaryProvider = FutureProvider<SavingsSummary>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return repository.getSavingsSummary();
});

// Alias for backward compatibility if needed by other pages
final savingsProvider = allSavingsProvider;
