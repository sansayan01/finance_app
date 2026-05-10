import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/supabase_provider.dart';
import '../../../loans/data/repositories/loans_repository.dart';

class PortfolioStats {
  final double totalDisbursed;
  final double totalCollected;
  final double parPercentage;
  final List<double> monthlyDisbursements;
  final List<double> monthlyCollections;

  PortfolioStats({
    required this.totalDisbursed,
    required this.totalCollected,
    required this.parPercentage,
    required this.monthlyDisbursements,
    required this.monthlyCollections,
  });
}

final analyticsProvider = FutureProvider<PortfolioStats>((ref) async {
  final loansRepo = LoansRepository(ref.watch(supabaseClientProvider));

  final summary = await loansRepo.getLoanSummary();

  // For now, we return real totals from the repositories, 
  // but keep chart data empty or use real data if available in the future.
  return PortfolioStats(
    totalDisbursed: summary.totalDisbursed,
    totalCollected: summary.totalCollected,
    parPercentage: summary.parPercentage,
    monthlyDisbursements: [],
    monthlyCollections: [],
  );
});
