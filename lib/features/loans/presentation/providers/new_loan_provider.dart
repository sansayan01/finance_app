import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/loans_repository.dart';
import 'loan_providers.dart';

enum InterestLogic { reducingBalance, flat }

enum CollectionType { daily, weekly, monthly, yearly }

class NewLoanState {
  final String? borrowerId;
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final CollectionType collectionType;
  final InterestLogic interestLogic;
  final DateTime? firstInstallmentDate;
  final bool isLoading;

  NewLoanState({
    this.borrowerId,
    this.principalAmount = 50000,
    this.interestRate = 24,
    this.tenureMonths = 12,
    this.collectionType = CollectionType.monthly,
    this.interestLogic = InterestLogic.reducingBalance,
    this.firstInstallmentDate,
    this.isLoading = false,
  });

  NewLoanState copyWith({
    String? borrowerId,
    double? principalAmount,
    double? interestRate,
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
      tenureMonths: tenureMonths ?? this.tenureMonths,
      collectionType: collectionType ?? this.collectionType,
      interestLogic: interestLogic ?? this.interestLogic,
      firstInstallmentDate: firstInstallmentDate ?? this.firstInstallmentDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get numberOfInstallments {
    if (tenureMonths <= 0) return 0;
    switch (collectionType) {
      case CollectionType.daily:
        return (tenureMonths * 365 / 12).round();
      case CollectionType.weekly:
        return (tenureMonths * 52 / 12).round();
      case CollectionType.yearly:
        int n = (tenureMonths / 12).round();
        return n > 0 ? n : 1;
      case CollectionType.monthly:
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
      case CollectionType.daily:
        r = annualRate / 365;
        break;
      case CollectionType.weekly:
        r = annualRate / 52;
        break;
      case CollectionType.yearly:
        r = annualRate;
        break;
      case CollectionType.monthly:
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
  final LoansRepository _repository;
  final Ref _ref;

  NewLoanNotifier(this._repository, this._ref) : super(NewLoanState());

  void updateBorrower(String? id) => state = state.copyWith(borrowerId: id);
  void updatePrincipal(double amount) =>
      state = state.copyWith(principalAmount: amount);
  void updateInterestRate(double rate) =>
      state = state.copyWith(interestRate: rate);
  void updateTenure(int months) => state = state.copyWith(tenureMonths: months);
  void updateCollectionType(CollectionType type) =>
      state = state.copyWith(collectionType: type);
  void updateInterestLogic(InterestLogic logic) =>
      state = state.copyWith(interestLogic: logic);
  void updateFirstInstallmentDate(DateTime date) =>
      state = state.copyWith(firstInstallmentDate: date);

  Future<void> createLoan() async {
    if (state.borrowerId == null) throw Exception('Please select a borrower');

    state = state.copyWith(isLoading: true);
    try {
      await _repository.createLoan(
        borrowerId: state.borrowerId!,
        principal: state.principalAmount,
        interestRate: state.interestRate,
        tenureMonths: state.tenureMonths,
        frequency: state.collectionType.name,
        collectionType: state.collectionType.name,
        interestLogic: state.interestLogic.name,
        firstInstallmentDate: state.firstInstallmentDate ??
            DateTime.now().add(const Duration(days: 30)),
        estimatedInstallment: state.estimatedInstallment,
        totalExposure: state.totalExposure,
      );

      // Force refresh the loans list
      _ref.invalidate(loansProvider);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void reset() => state = NewLoanState();
}

final newLoanProvider =
    StateNotifierProvider<NewLoanNotifier, NewLoanState>((ref) {
  return NewLoanNotifier(ref.watch(loansRepositoryProvider), ref);
});
