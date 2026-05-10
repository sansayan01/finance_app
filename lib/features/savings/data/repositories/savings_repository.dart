import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../settings/data/repositories/activity_log_repository.dart';
import '../../../settings/data/models/activity_log_model.dart';
import '../models/savings_model.dart';

class SavingsRepository {
  final SupabaseClient _client;
  final ActivityLogRepository? _logRepo;

  SavingsRepository(this._client, [this._logRepo]);

  Future<List<SavingsModel>> getActiveSavingsPlans({int limit = 20}) async {
    try {
      final response = await _client
          .from('savings')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => SavingsModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<SavingsSummary> getSavingsSummary() async {
    try {
      final response = await _client
          .from('savings')
          .select('id, current_amount')
          .eq('status', 'active');

      final savings = response as List;
      final total = savings.fold<double>(0, (sum, s) => sum + (s['current_amount'] as num).toDouble());
      final count = savings.length;

      return SavingsSummary(
        totalSavings: total,
        activeAccounts: count,
        averageBalance: count > 0 ? total / count : 0,
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
    final today = DateTime.now();
    final response = await _client
        .from('savings')
        .select()
        .eq('status', 'active')
        .lte('maturity_date', today.add(const Duration(days: 1)))
        .order('maturity_date', ascending: true)
        .limit(limit);

    return (response as List)
        .map((json) => SavingsModel.fromJson(json))
        .toList();
  }

  Future<SavingsModel?> getSavingsById(String id) async {
    final response = await _client
        .from('savings')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return SavingsModel.fromJson(response);
  }

  Future<SavingsModel?> createSavingsPlan(SavingsModel plan) async {
    try {
      final response = await _client
          .from('savings')
          .insert(plan.toJson())
          .select()
          .single();

      final createdPlan = SavingsModel.fromJson(response);
      
      await _logRepo?.log(
        action: 'New Savings Plan',
        details: 'Amount: ₹${createdPlan.targetAmount}/mo, Member ID: ${createdPlan.memberId}',
        type: ActivityType.financialTransaction,
      );
      
      return createdPlan;
    } catch (e) {
      return null;
    }
  }
}