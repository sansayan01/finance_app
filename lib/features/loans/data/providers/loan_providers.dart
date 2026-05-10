import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../repositories/loans_repository.dart';
import '../../../../providers/supabase_provider.dart';

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  return LoansRepository(ref.watch(supabaseClientProvider));
});

final allLoansProvider = FutureProvider<List<LoanModel>>((ref) async {
  final repository = ref.watch(loansRepositoryProvider);
  return repository.getAllLoans();
});

// Alias for backward compatibility
final loansProvider = allLoansProvider;
