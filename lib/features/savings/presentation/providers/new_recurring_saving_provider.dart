import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CollectionType { daily, weekly, monthly }

class NewRecurringSavingState {
  final String? memberId;
  final CollectionType collectionType;
  final double installmentAmount;
  final double maturityAmount;
  final DateTime maturityDate;
  final double prematurePenalty;

  NewRecurringSavingState({
    this.memberId,
    this.collectionType = CollectionType.monthly,
    this.installmentAmount = 1000,
    this.maturityAmount = 12500,
    DateTime? maturityDate,
    this.prematurePenalty = 2,
  }) : maturityDate = maturityDate ?? DateTime.now().add(const Duration(days: 365));

  NewRecurringSavingState copyWith({
    String? memberId,
    CollectionType? collectionType,
    double? installmentAmount,
    double? maturityAmount,
    DateTime? maturityDate,
    double? prematurePenalty,
  }) {
    return NewRecurringSavingState(
      memberId: memberId ?? this.memberId,
      collectionType: collectionType ?? this.collectionType,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      maturityAmount: maturityAmount ?? this.maturityAmount,
      maturityDate: maturityDate ?? this.maturityDate,
      prematurePenalty: prematurePenalty ?? this.prematurePenalty,
    );
  }

  int get totalInstallments {
    final now = DateTime.now();
    if (maturityDate.isBefore(now)) return 0;
    
    final days = maturityDate.difference(now).inDays;
    switch (collectionType) {
      case CollectionType.daily:
        return days;
      case CollectionType.weekly:
        return (days / 7).round();
      case CollectionType.monthly:
        // approximate months
        return (days / 30.44).round();
    }
  }

  double get totalCapitalInvested {
    return installmentAmount * totalInstallments;
  }

  double get estimatedInterest {
    return maturityAmount - totalCapitalInvested;
  }
}

class NewRecurringSavingNotifier extends StateNotifier<NewRecurringSavingState> {
  NewRecurringSavingNotifier() : super(NewRecurringSavingState());

  void updateMember(String? id) => state = state.copyWith(memberId: id);
  void updateCollectionType(CollectionType type) => state = state.copyWith(collectionType: type);
  void updateInstallmentAmount(double amount) => state = state.copyWith(installmentAmount: amount);
  void updateMaturityAmount(double amount) => state = state.copyWith(maturityAmount: amount);
  void updateMaturityDate(DateTime date) => state = state.copyWith(maturityDate: date);
  void updatePrematurePenalty(double penalty) => state = state.copyWith(prematurePenalty: penalty);

  void reset() => state = NewRecurringSavingState();
}

final newRecurringSavingProvider = StateNotifierProvider<NewRecurringSavingNotifier, NewRecurringSavingState>((ref) {
  return NewRecurringSavingNotifier();
});
