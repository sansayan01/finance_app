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
    this.interestRate = 2, // e.g. 2% monthly or 24% annual? Let's assume the slider is Annual Percentage Rate (APR) based on standard practice, but the screenshot says "2" and "Monthly". We will treat it as Annual Rate for the math, or user input. Let's assume it's annual rate.
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

  // Calculated properties
  double get estimatedInstallment {
    if (principalAmount <= 0 || tenureMonths <= 0) return 0;

    // For simplicity, assuming the interest rate entered is the ANNUAL rate (APR).
    // If the screenshot implies something else (like 2% flat per month), this logic can be adjusted.
    // The screenshot says 50,000 principal, 2% rate, 12 months. Installment is 4727.98
    // Let's reverse engineer: 50000 * 0.02 = 1000. 1000 * 12 = 12000 total interest? No.
    // Reducing balance formula: P * r * (1+r)^n / ((1+r)^n - 1)
    // If r = 2% per month (0.02), n = 12, P = 50000
    // 50000 * 0.02 * (1.02)^12 / ((1.02)^12 - 1)
    // 1000 * 1.26824 / 0.26824 = 4727.98!
    // So the "INTEREST RATE (%)" in the UI is actually the MONTHLY rate.

    double r = interestRate / 100; // Monthly rate
    int n = tenureMonths;
    double p = principalAmount;

    if (interestRate == 0) {
      return p / n;
    }

    if (interestLogic == InterestLogic.reducingBalance) {
      return (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
    } else {
      // Flat rate
      // Total interest = P * r * n
      double totalInterest = p * r * n;
      return (p + totalInterest) / n;
    }
  }

  double get interestBurden {
    return (estimatedInstallment * tenureMonths) - principalAmount;
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
