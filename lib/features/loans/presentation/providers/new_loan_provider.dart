import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InterestLogic { reducingBalance, flat }
enum LoanFrequency { daily, weekly, monthly, yearly }

class NewLoanState {
  final String? borrowerId;
  final double principalAmount;
  final double interestRate;
  final LoanFrequency frequency;
  final int tenureMonths;
  final LoanFrequency collectionType;
  final InterestLogic interestLogic;
  final DateTime? firstInstallmentDate;

  NewLoanState({
    this.borrowerId,
    this.principalAmount = 50000,
    this.interestRate = 24, // Use 24% APR as default (equivalent to 2% monthly)
    this.frequency = LoanFrequency.monthly,
    this.tenureMonths = 12,
    this.collectionType = LoanFrequency.monthly,
    this.interestLogic = InterestLogic.reducingBalance,
    this.firstInstallmentDate,
  });

  NewLoanState copyWith({
    String? borrowerId,
    double? principalAmount,
    double? interestRate,
    LoanFrequency? frequency,
    int? tenureMonths,
    LoanFrequency? collectionType,
    InterestLogic? interestLogic,
    DateTime? firstInstallmentDate,
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
    );
  }

  // Total number of installments
  int get numberOfInstallments {
    if (tenureMonths <= 0) return 0;
    switch (collectionType) {
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
    switch (collectionType) {
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

class NewLoanNotifier extends StateNotifier<NewLoanState> {
  NewLoanNotifier() : super(NewLoanState());

  void updateBorrower(String? id) => state = state.copyWith(borrowerId: id);
  void updatePrincipal(double amount) => state = state.copyWith(principalAmount: amount);
  void updateInterestRate(double rate) => state = state.copyWith(interestRate: rate);
  void updateFrequency(LoanFrequency freq) => state = state.copyWith(frequency: freq);
  void updateTenure(int months) => state = state.copyWith(tenureMonths: months);
  void updateCollectionType(LoanFrequency type) => state = state.copyWith(collectionType: type);
  void updateInterestLogic(InterestLogic logic) => state = state.copyWith(interestLogic: logic);
  void updateFirstInstallmentDate(DateTime date) => state = state.copyWith(firstInstallmentDate: date);
  
  void reset() => state = NewLoanState();
}

final newLoanProvider = StateNotifierProvider<NewLoanNotifier, NewLoanState>((ref) {
  return NewLoanNotifier();
});
