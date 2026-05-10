import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loan_model.dart';

class LoansRepository {
  final SupabaseClient _client;

  LoansRepository(this._client);

  Future<List<LoanModel>> getActiveLoans({int limit = 10}) async {
    try {
      final response = await _client
          .from('loans')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => LoanModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LoanModel>> getLoansByStatus(String status, {int limit = 50}) async {
    try {
      final response = await _client
          .from('loans')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => LoanModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<LoanSummary> getLoanSummary() async {
    try {
      final activeResponse = await _client
          .from('loans')
          .select('id, principal, outstanding_amount')
          .eq('status', 'active');

      final defaultResponse = await _client
          .from('loans')
          .select('id, principal, outstanding_amount')
          .eq('status', 'defaultStatus');

      final activeLoans = activeResponse as List;
      final defaultLoans = defaultResponse as List;

      final totalOutstanding = [...activeLoans, ...defaultLoans]
          .fold<double>(0, (sum, loan) => sum + ((loan['outstanding_amount'] ?? loan['principal']) as num).toDouble());

      return LoanSummary(
        totalLoans: activeLoans.length + defaultLoans.length,
        activeLoans: activeLoans.length,
        defaultLoans: defaultLoans.length,
        totalOutstanding: totalOutstanding,
        totalDisbursed: 0,
        totalCollected: 0,
        overdueAmount: 0,
        parPercentage: activeLoans.isEmpty ? 0 : (defaultLoans.length / activeLoans.length) * 100,
      );
    } catch (e) {
      return LoanSummary(
        totalLoans: 0,
        activeLoans: 0,
        defaultLoans: 0,
        totalOutstanding: 0,
        totalDisbursed: 0,
        totalCollected: 0,
        overdueAmount: 0,
        parPercentage: 0,
      );
    }
  }

  Future<LoanModel?> getLoanById(String id) async {
    final response = await _client
        .from('loans')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return LoanModel.fromJson(response);
  }

  Future<List<LoanScheduleEntry>> getLoanSchedule(String loanId) async {
    final response = await _client
        .from('loan_schedules')
        .select()
        .eq('loan_id', loanId)
        .order('period', ascending: true);

    return (response as List)
        .map((json) => LoanScheduleEntry.fromJson(json))
        .toList();
  }
}