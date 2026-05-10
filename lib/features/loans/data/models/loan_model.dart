import '../../../../core/constants/enums.dart';

class LoanModel {
  final String id;
  final String customerId;
  final String? planId;
  final String? staffId;
  final String loanNumber;
  final double amount;
  final double interestRate;
  final int tenureMonths;
  final double emiAmount;
  final double totalInterest;
  final double totalRepayable;
  final double outstandingBalance;
  final InterestType interestType;
  final DateTime? disbursementDate;
  final DateTime? firstEmiDate;
  final LoanStatus status;
  final String? purpose;
  final String? remarks;
  final String? createdBy;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined Data
  final String? customerName;
  final String? customerPhone;
  final String? staffName;

  LoanModel({
    required this.id,
    required this.customerId,
    this.planId,
    this.staffId,
    required this.loanNumber,
    required this.amount,
    required this.interestRate,
    required this.tenureMonths,
    required this.emiAmount,
    required this.totalInterest,
    required this.totalRepayable,
    required this.outstandingBalance,
    required this.interestType,
    this.disbursementDate,
    this.firstEmiDate,
    required this.status,
    this.purpose,
    this.remarks,
    this.createdBy,
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerPhone,
    this.staffName,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    // Handle Supabase join format: "customers": {"full_name": "...", "phone": "..."}
    final customersJson = json['customers'] as Map<String, dynamic>?;
    final staffJson = json['staff'] as Map<String, dynamic>?;

    return LoanModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      planId: json['plan_id'] as String?,
      staffId: json['staff_id'] as String?,
      loanNumber: json['loan_number'] as String,
      amount: (json['amount'] as num).toDouble(),
      interestRate: (json['interest_rate'] as num).toDouble(),
      tenureMonths: json['tenure_months'] as int,
      emiAmount: (json['emi_amount'] as num).toDouble(),
      totalInterest: (json['total_interest'] as num).toDouble(),
      totalRepayable: (json['total_repayable'] as num).toDouble(),
      outstandingBalance: (json['outstanding_balance'] as num).toDouble(),
      interestType: InterestType.values.firstWhere(
        (e) => e.name == json['interest_type'] || _toSnake(e.name) == json['interest_type'],
        orElse: () => InterestType.flat,
      ),
      disbursementDate: json['disbursement_date'] != null
          ? DateTime.parse(json['disbursement_date'] as String)
          : null,
      firstEmiDate: json['first_emi_date'] != null
          ? DateTime.parse(json['first_emi_date'] as String)
          : null,
      status: LoanStatus.values.firstWhere(
        (e) => e.name == json['status'] || _toSnake(e.name) == json['status'],
        orElse: () => LoanStatus.draft,
      ),
      purpose: json['purpose'] as String?,
      remarks: json['remarks'] as String?,
      createdBy: json['created_by'] as String?,
      approvedBy: json['approved_by'] as String?,
      rejectedBy: json['rejected_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customerName: customersJson?['full_name'] as String?,
      customerPhone: customersJson?['phone'] as String?,
      staffName: staffJson?['full_name'] as String?,
    );
  }

  static String _toSnake(String s) {
    return s.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'plan_id': planId,
      'staff_id': staffId,
      'loan_number': loanNumber,
      'amount': amount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'emi_amount': emiAmount,
      'total_interest': totalInterest,
      'total_repayable': totalRepayable,
      'outstanding_balance': outstandingBalance,
      'interest_type': interestType.name,
      'disbursement_date': disbursementDate?.toIso8601String(),
      'first_emi_date': firstEmiDate?.toIso8601String(),
      'status': status.name,
      'purpose': purpose,
      'remarks': remarks,
      'created_by': createdBy,
      'approved_by': approvedBy,
      'rejected_by': rejectedBy,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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