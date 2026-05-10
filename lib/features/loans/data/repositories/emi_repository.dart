import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/emi_schedule_model.dart';

class EMIRepository {
  final SupabaseClient _client;

  EMIRepository(this._client);

  Future<List<EMIScheduleModel>> getByLoanId(String loanId) async {
    try {
      final response = await _client
          .from('emi_schedule')
          .select()
          .eq('loan_id', loanId)
          .order('emi_number', ascending: true);

      return (response as List)
          .map((json) => EMIScheduleModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> recordPayment({
    required String emiId,
    required String loanId,
    required double amount,
    required String paymentMode,
    String? notes,
  }) async {
    try {
      // 1. Update EMI Schedule
      await _client.from('emi_schedule').update({
        'status': 'paid',
        'paid_on': DateTime.now().toIso8601String(),
        'payment_mode': paymentMode,
      }).eq('id', emiId);

      // 2. Create Transaction Record
      await _client.from('transactions').insert({
        'loan_id': loanId,
        'type': 'emi_payment',
        'amount': amount,
        'payment_mode': paymentMode,
        'notes': notes,
        'entered_at': DateTime.now().toIso8601String(),
      });

      // Note: Supabase functions/triggers would normally handle 
      // updating the loan's outstanding balance and total collected.
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateSchedule(String loanId) async {
    // In a real app, this would be a Supabase Edge Function or RPC call
    // because complex amortization logic should be server-side.
    await _client.rpc('generate_emi_schedule', params: {'p_loan_id': loanId});
  }
}
