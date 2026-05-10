import '../../../../core/utils/calculations.dart';

enum LoanStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  active,
  defaultStatus,
  closed,
}

enum RiskCategory {
  standard,
  subStandard,
  doubtful,
  loss,
}

class LoanModel {
  final String id;
  final String memberId;
  final String memberName;
  final double principal;
  final double outstandingAmount;
  final double interestRate;
  final int tenureMonths;
  final PaymentFrequency frequency;
  final LoanStatus status;
  final RiskCategory riskCategory;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? disbursedAt;
  final DateTime? closedAt;
  final String? remarks;

  LoanModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.principal,
    required this.outstandingAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.frequency,
    required this.status,
    this.riskCategory = RiskCategory.standard,
    required this.createdAt,
    this.approvedAt,
    this.disbursedAt,
    this.closedAt,
    this.remarks,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String? ?? '',
      principal: (json['principal'] as num).toDouble(),
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble() ?? (json['principal'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      tenureMonths: json['tenure_months'] as int,
      frequency: PaymentFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => PaymentFrequency.monthly,
      ),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LoanStatus.draft,
      ),
      riskCategory: RiskCategory.values.firstWhere(
        (e) => e.name == json['risk_category'],
        orElse: () => RiskCategory.standard,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      disbursedAt: json['disbursed_at'] != null
          ? DateTime.parse(json['disbursed_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'principal': principal,
      'outstanding_amount': outstandingAmount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'frequency': frequency.name,
      'status': status.name,
      'risk_category': riskCategory.name,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'disbursed_at': disbursedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'remarks': remarks,
    };
  }
}

class LoanScheduleEntry {
  final int period;
  final DateTime dueDate;
  final double emi;
  final double principal;
  final double interest;
  final double balance;
  final bool isPaid;
  final bool isOverdue;
  final DateTime? paidDate;
  final double? penalty;

  LoanScheduleEntry({
    required this.period,
    required this.dueDate,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
    this.isPaid = false,
    this.isOverdue = false,
    this.paidDate,
    this.penalty,
  });

  factory LoanScheduleEntry.fromJson(Map<String, dynamic> json) {
    return LoanScheduleEntry(
      period: json['period'] as int,
      dueDate: DateTime.parse(json['due_date'] as String),
      emi: (json['emi'] as num).toDouble(),
      principal: (json['principal'] as num).toDouble(),
      interest: (json['interest'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      isPaid: json['is_paid'] as bool? ?? false,
      isOverdue: json['is_overdue'] as bool? ?? false,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      penalty: json['penalty'] != null
          ? (json['penalty'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'due_date': dueDate.toIso8601String(),
      'emi': emi,
      'principal': principal,
      'interest': interest,
      'balance': balance,
      'is_paid': isPaid,
      'is_overdue': isOverdue,
      'paid_date': paidDate?.toIso8601String(),
      'penalty': penalty,
    };
  }
}

class LoanSummary {
  final int totalLoans;
  final int activeLoans;
  final int defaultLoans;
  final double totalOutstanding;
  final double totalDisbursed;
  final double totalCollected;
  final double overdueAmount;
  final double parPercentage;

  LoanSummary({
    required this.totalLoans,
    required this.activeLoans,
    required this.defaultLoans,
    required this.totalOutstanding,
    required this.totalDisbursed,
    required this.totalCollected,
    required this.overdueAmount,
    required this.parPercentage,
  });

  factory LoanSummary.fromJson(Map<String, dynamic> json) {
    return LoanSummary(
      totalLoans: json['total_loans'] as int? ?? 0,
      activeLoans: json['active_loans'] as int? ?? 0,
      defaultLoans: json['default_loans'] as int? ?? 0,
      totalOutstanding: (json['total_outstanding'] as num?)?.toDouble() ?? 0,
      totalDisbursed: (json['total_disbursed'] as num?)?.toDouble() ?? 0,
      totalCollected: (json['total_collected'] as num?)?.toDouble() ?? 0,
      overdueAmount: (json['overdue_amount'] as num?)?.toDouble() ?? 0,
      parPercentage: (json['par_percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}