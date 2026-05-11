import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/savings_model.dart';

class SavingsRepository {
  final SupabaseClient _client;
  SavingsRepository(this._client);

  Future<void> createSavingsPlan({
    required String memberId,
    required double installmentAmount,
    required double maturityAmount,
    required DateTime maturityDate,
    required String collectionType,
    required double penalty,
    required int totalInstallments,
  }) async {
    await _client.from('savings_plans').insert({
      'member_id': memberId,
      'installment_amount': installmentAmount,
      'maturity_amount': maturityAmount,
      'maturity_date': maturityDate.toIso8601String(),
      'collection_type': collectionType,
      'premature_penalty': penalty,
      'total_installments': totalInstallments,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SavingsModel>> getActiveSavingsPlans({int limit = 50}) async {
    try {
      final response = await _client
          .from('savings_plans')
          .select('*, profiles:member_id(full_name)')
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        // Map the new schema to the existing SavingsModel
        return SavingsModel(
          id: json['id']?.toString() ?? '',
          memberId: json['member_id']?.toString() ?? '',
          memberName: json['profiles']?['full_name']?.toString() ?? 'Unknown',
          planName: 'Recurring Deposit',
          targetAmount: (json['maturity_amount'] as num?)?.toDouble() ?? 0,
          currentAmount: 0, // Would need actual balance calculation
          monthlyDeposit: (json['installment_amount'] as num?)?.toDouble() ?? 0,
          interestRate: 0, 
          maturityDate: DateTime.tryParse(json['maturity_date']?.toString() ?? '') ?? DateTime.now(),
          createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
          status: json['status']?.toString() ?? 'active',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<SavingsSummary> getSavingsSummary() async {
    try {
      final plans = await getActiveSavingsPlans();
      
      return SavingsSummary(
        totalSavings: 0, // Needs real balance from transactions
        activeAccounts: plans.length,
        averageBalance: 0,
        interestEarned: 0,
      );
    } catch (e) {
      return SavingsSummary(
        totalSavings: 0,
        activeAccounts: 0,
        averageBalance: 0,
        interestEarned: 0,
      );
    }
  }

  Future<List<SavingsModel>> getPendingDeposits({int limit = 10}) async {
    // For now, return same as active since we don't have a separate table for collection schedule
    return getActiveSavingsPlans(limit: limit);
  }
}