import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/savings_model.dart';
import '../../data/repositories/savings_repository.dart';
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

final savingsSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredSavingsProvider = Provider<List<SavingsModel>>((ref) {
  final savings = ref.watch(allSavingsProvider).value ?? [];
  final query = ref.watch(savingsSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return savings;

  return savings.where((s) {
    return s.memberName.toLowerCase().contains(query) ||
        s.memberId.toLowerCase().contains(query) ||
        s.planName.toLowerCase().contains(query);
  }).toList();
});

final userSavingsProvider =
    FutureProvider.family<List<SavingsModel>, String>((ref, userId) async {
  final savings = await ref.watch(allSavingsProvider.future);
  return savings.where((s) => s.memberId == userId).toList();
});
