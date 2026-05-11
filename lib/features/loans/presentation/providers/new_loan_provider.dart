import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/supabase_provider.dart';
import '../../data/repositories/loans_repository.dart';

enum InterestLogic { reducingBalance, flat }
enum LoanFrequency { daily, weekly, monthly, yearly }
enum CollectionType { doorToDoor, centerCollected, branchCollected }

class NewLoanState {
  final String? borrowerId;
  final double principalAmount;
  final double interestRate;
  final LoanFrequency frequency;
  final int tenureMonths;
  final CollectionType collectionType;
  final InterestLogic interestLogic;
  final DateTime? firstInstallmentDate;
  final bool isLoading;

  NewLoanState({
    this.borrowerId,
    this.principalAmount = 50000,
    this.interestRate = 24,
    this.frequency = LoanFrequency.monthly,
    this.tenureMonths = 12,
    this.collectionType = CollectionType.doorToDoor,
    this.interestLogic = InterestLogic.reducingBalance,
    this.firstInstallmentDate,
    this.isLoading = false,
  });

  NewLoanState copyWith({
    String? borrowerId,
    double? principalAmount,
    double? interestRate,
    LoanFrequency? frequency,
    int? tenureMonths,
    CollectionType? collectionType,
    InterestLogic? interestLogic,
    DateTime? firstInstallmentDate,
    bool? isLoading,
  }) {
    return NewLoanState(
      borrowerId: borrowerId ?? this.borrowerId,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      frequency: frequency ?? this.frequency,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      collectionType: collectionType ?? this.collectionType,
      interestLogic: interestLogic ?? this.interestLogic,
      firstInstallmentDate: firstInstallmentDate ?? this.firstInstallmentDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Total number of installments based on frequency
  int get numberOfInstallments {
    if (tenureMonths <= 0) return 0;
    switch (frequency) {
      case LoanFrequency.daily:
        return (tenureMonths * 365 / 12).round();
      case LoanFrequency.weekly:
        return (tenureMonths * 52 / 12).round();
      case LoanFrequency.yearly:
        int n = (tenureMonths / 12).round();
        return n > 0 ? n : 1;
      case LoanFrequency.monthly:
        return tenureMonths;
    }
  }

  // Calculated properties
  double get estimatedInstallment {
    if (principalAmount <= 0 || tenureMonths <= 0) return 0;

    double annualRate = interestRate / 100;
    int n = numberOfInstallments;
    if (n <= 0) return 0;

    double r;
    switch (frequency) {
      case LoanFrequency.daily:
        r = annualRate / 365;
        break;
      case LoanFrequency.weekly:
        r = annualRate / 52;
        break;
      case LoanFrequency.yearly:
        r = annualRate;
        break;
      case LoanFrequency.monthly:
        r = annualRate / 12;
        break;
    }

    double p = principalAmount;

    if (r == 0) {
      return p / n;
    }

    if (interestLogic == InterestLogic.reducingBalance) {
      return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    } else {
      // Flat rate
      double totalInterest = p * annualRate * (tenureMonths / 12);
      return (p + totalInterest) / n;
    }
  }

  double get interestBurden {
    return (estimatedInstallment * numberOfInstallments) - principalAmount;
  }

  double get totalExposure {
    return principalAmount + interestBurden;
  }
}

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  return LoansRepository(ref.watch(supabaseClientProvider));
});

class NewLoanNotifier extends StateNotifier<NewLoanState> {
  final LoansRepository _repository;
  
  NewLoanNotifier(this._repository) : super(NewLoanState());

  void updateBorrower(String? id) => state = state.copyWith(borrowerId: id);
  void updatePrincipal(double amount) => state = state.copyWith(principalAmount: amount);
  void updateInterestRate(double rate) => state = state.copyWith(interestRate: rate);
  void updateFrequency(LoanFrequency freq) => state = state.copyWith(frequency: freq);
  void updateTenure(int months) => state = state.copyWith(tenureMonths: months);
  void updateCollectionType(CollectionType type) => state = state.copyWith(collectionType: type);
  void updateInterestLogic(InterestLogic logic) => state = state.copyWith(interestLogic: logic);
  void updateFirstInstallmentDate(DateTime date) => state = state.copyWith(firstInstallmentDate: date);
  
  Future<void> createLoan() async {
    if (state.borrowerId == null) throw Exception('Please select a borrower');
    
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createLoan(
        borrowerId: state.borrowerId!,
        principal: state.principalAmount,
        interestRate: state.interestRate,
        tenureMonths: state.tenureMonths,
        frequency: state.frequency.name,
        collectionType: state.collectionType.name,
        interestLogic: state.interestLogic.name,
        firstInstallmentDate: state.firstInstallmentDate ?? DateTime.now().add(const Duration(days: 30)),
        estimatedInstallment: state.estimatedInstallment,
        totalExposure: state.totalExposure,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void reset() => state = NewLoanState();
}

final newLoanProvider = StateNotifierProvider<NewLoanNotifier, NewLoanState>((ref) {
  return NewLoanNotifier(ref.watch(loansRepositoryProvider));
});
