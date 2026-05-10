import 'dart:math';

enum PaymentFrequency {
  daily,
  weekly,
  fortnightly,
  monthly,
}

class LoanCalculation {
  final double principal;
  final double annualInterestRate;
  final int tenureMonths;
  final PaymentFrequency frequency;

  LoanCalculation({
    required this.principal,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.frequency,
  });

  double get periodicInterestRate {
    final periodsPerYear = _getPeriodsPerYear();
    return (annualInterestRate / 100) / periodsPerYear;
  }

  int get totalPeriods {
    final periodsPerYear = _getPeriodsPerYear();
    return (tenureMonths / 12 * periodsPerYear).round();
  }

  double _getPeriodsPerYear() {
    switch (frequency) {
      case PaymentFrequency.daily:
        return 365;
      case PaymentFrequency.weekly:
        return 52;
      case PaymentFrequency.fortnightly:
        return 26;
      case PaymentFrequency.monthly:
        return 12;
    }
  }

  double calculateEMI() {
    if (periodicInterestRate == 0) {
      return principal / totalPeriods;
    }
    final r = periodicInterestRate;
    final n = totalPeriods;
    return principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  List<AmortizationEntry> generateAmortizationSchedule() {
    final emi = calculateEMI();
    final schedule = <AmortizationEntry>[];
    double balance = principal;
    final monthlyRate = annualInterestRate / 12 / 100;

    for (int i = 1; i <= totalPeriods; i++) {
      final interestPayment = balance * monthlyRate;
      final principalPayment = emi - interestPayment;
      balance -= principalPayment;

      schedule.add(AmortizationEntry(
        period: i,
        emi: emi,
        principal: principalPayment,
        interest: interestPayment,
        balance: balance < 0 ? 0 : balance,
      ));
    }

    return schedule;
  }

  Map<String, double> calculateTotalPayment() {
    final emi = calculateEMI();
    final totalPayment = emi * totalPeriods;
    final totalInterest = totalPayment - principal;

    return {
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
      'emi': emi,
    };
  }
}

class AmortizationEntry {
  final int period;
  final double emi;
  final double principal;
  final double interest;
  final double balance;

  AmortizationEntry({
    required this.period,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  double get principalPortion => principal / emi;
  double get interestPortion => interest / emi;
}

class SavingsCalculator {
  final double monthlyDeposit;
  final double annualInterestRate;
  final int tenureMonths;

  SavingsCalculator({
    required this.monthlyDeposit,
    required this.annualInterestRate,
    required this.tenureMonths,
  });

  double calculateMaturityValue() {
    final monthlyRate = annualInterestRate / 12 / 100;
    double balance = 0;

    for (int i = 0; i < tenureMonths; i++) {
      balance = (balance + monthlyDeposit) * (1 + monthlyRate);
    }

    return balance;
  }

  double calculateTotalDeposits() {
    return monthlyDeposit * tenureMonths;
  }

  double calculateTotalInterest() {
    return calculateMaturityValue() - calculateTotalDeposits();
  }

  double calculateProgressToTarget(double targetAmount) {
    final maturity = calculateMaturityValue();
    if (targetAmount <= 0) return 0;
    return (maturity / targetAmount).clamp(0.0, 1.0);
  }
}

class PenaltyCalculator {
  static double calculateLatePaymentPenalty({
    required double amount,
    required int daysLate,
    required double dailyPenaltyRate,
  }) {
    if (daysLate <= 0) return 0;
    return amount * dailyPenaltyRate * daysLate;
  }

  static double calculateMissingDepositPenalty({
    required double depositAmount,
    required int consecutiveMisses,
    required double penaltyRate,
  }) {
    if (consecutiveMisses <= 0) return 0;
    return depositAmount * penaltyRate * consecutiveMisses;
  }
}