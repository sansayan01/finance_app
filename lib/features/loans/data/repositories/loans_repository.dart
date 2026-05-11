import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../settings/data/repositories/activity_log_repository.dart';
import '../../../settings/data/models/activity_log_model.dart';
import '../models/loan_model.dart';
import '../../../../core/constants/enums.dart';

class LoansRepository {
  final SupabaseClient _client;
  final ActivityLogRepository? _logRepo;

  LoansRepository(this._client, [this._logRepo]);

  Future<List<LoanModel>> getAllLoans({int limit = 100}) async {
    try {
      final response = await _client
          .from('loans')
          .select('*, profiles:customer_id(full_name, phone), staff:staff_id(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => LoanModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LoanModel>> getActiveLoans({int limit = 50}) async {
    try {
      final response = await _client
          .from('loans')
          .select('*, profiles:customer_id(full_name, phone), staff:staff_id(full_name)')
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

  Future<LoanSummary> getLoanSummary() async {
    try {
      final loans = await getAllLoans(limit: 1000);
      
      final active = loans.where((l) => l.status == LoanStatus.active).toList();
      final defaults = loans.where((l) => l.status == LoanStatus.defaultStatus).toList();
      
      final totalOutstanding = active.fold<double>(0.0, (double sum, LoanModel l) => sum + l.outstandingBalance) +
                               defaults.fold<double>(0.0, (double sum, LoanModel l) => sum + l.outstandingBalance);
      
      final totalDisbursed = loans
          .where((l) => l.status == LoanStatus.active || l.status == LoanStatus.closed)
          .fold<double>(0.0, (double sum, LoanModel l) => sum + l.amount);

      return LoanSummary(
        totalLoans: loans.length,
        activeLoans: active.length,
        defaultLoans: defaults.length,
        totalOutstanding: totalOutstanding,
        totalDisbursed: totalDisbursed,
        totalCollected: 0, // Would need transaction history
        overdueAmount: defaults.fold<double>(0.0, (double sum, LoanModel l) => sum + l.outstandingBalance),
        parPercentage: loans.isEmpty ? 0 : (defaults.length / loans.length) * 100,
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
    try {
      final response = await _client
          .from('loans')
          .select('*, profiles:customer_id(full_name, phone), staff:staff_id(full_name)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      final createdLoan = LoanModel.fromJson(response);
      
      await _logRepo?.log(
        action: 'Loan Disbursed',
        details: 'Amount: ₹${createdLoan.amount}, Customer ID: ${createdLoan.customerId}',
        type: ActivityType.financialTransaction,
      );
      
      return createdLoan;
    } catch (e) {
      return null;
    }
  }

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
    final now = DateTime.now();
    // Generate a unique loan number: L-YYYYMMDD-XXXX
    final loanNumber = 'L-${DateFormat('yyyyMMdd').format(now)}-${math.Random().nextInt(9999).toString().padLeft(4, '0')}';
    
    await _client.from('loans').insert({
      'customer_id': borrowerId,
      'loan_number': loanNumber,
      'amount': principal,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'frequency': frequency,
      'collection_type': collectionType,
      'emi_amount': estimatedInstallment,
      'outstanding_balance': totalExposure,
      'total_repayable': totalExposure,
      'interest_type': interestLogic,
      'status': 'active',
      'first_installment_date': firstInstallmentDate.toIso8601String(),
    });
  }

  Future<void> createLoanFromMap(Map<String, dynamic> data) async {
    await _client.from('loans').insert(data);
  }

  Future<void> updateLoanStatus(String id, String status) async {
    await _client.from('loans').update({'status': status}).eq('id', id);
  }
}