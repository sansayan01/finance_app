import 'package:supabase_flutter/supabase_flutter.dart';

class LoanRepository {
  final SupabaseClient _client;
  LoanRepository(this._client);

  Future<void> createLoan({
    required String borrowerId,
    required double principal,
    required double interestRate,
    required int tenureMonths,
    required String frequency,
    required String collectionType,
    required String interestLogic,
    required DateTime firstInstallmentDate,
    required double estimatedInstallment,
    required double totalExposure,
  }) async {
    await _client.from('loans').insert({
      'borrower_id': borrowerId,
      'principal_amount': principal,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'frequency': frequency,
      'collection_type': collectionType,
      'interest_logic': interestLogic,
      'first_installment_date': firstInstallmentDate.toIso8601String(),
      'estimated_installment': estimatedInstallment,
      'total_exposure': totalExposure,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLoans() async {
    final response = await _client
        .from('loans')
        .select('*, profiles:borrower_id(full_name)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
