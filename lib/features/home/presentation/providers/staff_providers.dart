import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../loans/data/models/emi_schedule_model.dart';
import '../../../loans/data/models/loan_model.dart';

import '../../../loans/presentation/providers/loan_providers.dart';
import '../../../savings/data/models/savings_model.dart';
import '../../../savings/data/providers/savings_providers.dart';
import '../../../transactions/data/models/transaction_model.dart';

import '../../../../core/services/offline_queue_service.dart';

class StaffDueItem {
  final String id;
  final String type; // 'emi' or 'savings'
  final String memberName;
  final String? memberPhone;
  final double amount;
  final String? loanId;
  final String? savingsId;
  final int? emiNumber;
  final String? loanNumber;
  final String? planName;
  final DateTime? dueDate;

  StaffDueItem({
    required this.id,
    required this.type,
    required this.memberName,
    this.memberPhone,
    required this.amount,
    this.loanId,
    this.savingsId,
    this.emiNumber,
    this.loanNumber,
    this.planName,
    this.dueDate,
  });
}

class StaffTodayStats {
  final double target;
  final double collected;
  final int totalDues;
  final int collectedCount;
  final int pendingSyncCount;

  StaffTodayStats({
    required this.target,
    required this.collected,
    required this.totalDues,
    required this.collectedCount,
    required this.pendingSyncCount,
  });

  double get remaining => target > collected ? target - collected : 0;
  double get progress =>
      target > 0 ? (collected / target).clamp(0.0, 1.0) : 0.0;
}

final staffTodayEmiDuesProvider =
    FutureProvider<List<EMIScheduleModel>>((ref) async {
  final repository = ref.watch(emiRepositoryProvider);
  return repository.getTodaysDues();
});

final staffActiveLoansProvider = FutureProvider<List<LoanModel>>((ref) async {
  final repository = ref.watch(loansRepositoryProvider);
  return repository.getAllLoans();
});

final staffActiveSavingsProvider =
    FutureProvider<List<SavingsModel>>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return repository.getActiveSavingsPlans();
});

final staffTodaysDuesProvider = FutureProvider<List<StaffDueItem>>((ref) async {
  final emisAsync = ref.watch(staffTodayEmiDuesProvider);
  final loansAsync = ref.watch(staffActiveLoansProvider);
  final savingsAsync = ref.watch(staffActiveSavingsProvider);

  final emis = emisAsync.value ?? [];
  final loans = loansAsync.value ?? [];
  final savings = savingsAsync.value ?? [];

  final loanMap = {for (final l in loans) l.id: l};

  final dues = <StaffDueItem>[];

  for (final emi in emis) {
    final loan = loanMap[emi.loanId];
    dues.add(StaffDueItem(
      id: emi.id,
      type: 'emi',
      memberName: loan?.customerName ?? 'Unknown',
      memberPhone: loan?.customerPhone,
      amount: emi.emiAmount,
      loanId: emi.loanId,
      emiNumber: emi.emiNumber,
      loanNumber: loan?.loanNumber,
      dueDate: emi.dueDate,
    ));
  }

  for (final s in savings) {
    if (s.monthlyDeposit > 0) {
      dues.add(StaffDueItem(
        id: s.id,
        type: 'savings',
        memberName: s.memberName,
        amount: s.monthlyDeposit,
        savingsId: s.id,
        planName: s.planName.isNotEmpty ? s.planName : 'Recurring Deposit',
      ));
    }
  }

  return dues;
});

final staffTodayStatsProvider = FutureProvider<StaffTodayStats>((ref) async {
  final duesAsync = ref.watch(staffTodaysDuesProvider);
  final transactionsRepo = ref.watch(transactionsRepositoryProvider);
  final stats = await transactionsRepo.getTodayStats();

  final dues = duesAsync.value ?? [];
  final target = dues.fold<double>(0, (sum, d) => sum + d.amount);
  final collected = (stats['collected'] as double?) ?? 0.0;
  final collectedCount = (stats['collectionCount'] as int?) ?? 0;

  final queue = OfflineQueueService();
  final pendingSync = await queue.pendingCount;

  return StaffTodayStats(
    target: target,
    collected: collected,
    totalDues: dues.length,
    collectedCount: collectedCount,
    pendingSyncCount: pendingSync,
  );
});

final staffRecentActivityProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.getTransactionsByDate(DateTime.now());
});

final offlineQueueCountProvider = FutureProvider<int>((ref) async {
  final queue = OfflineQueueService();
  return queue.pendingCount;
});
