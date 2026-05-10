enum TransactionType {
  emiCollection,
  loanDisbursement,
  savingsDeposit,
  savingsWithdrawal,
  penalty,
  other,
}

class TransactionModel {
  final String id;
  final String memberId;
  final String memberName;
  final TransactionType type;
  final double amount;
  final String? loanId;
  final String? savingsId;
  final DateTime createdAt;
  final String? description;

  TransactionModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    this.loanId,
    this.savingsId,
    required this.createdAt,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String? ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.other,
      ),
      amount: (json['amount'] as num).toDouble(),
      loanId: json['loan_id'] as String?,
      savingsId: json['savings_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'type': type.name,
      'amount': amount,
      'loan_id': loanId,
      'savings_id': savingsId,
      'created_at': createdAt.toIso8601String(),
      'description': description,
    };
  }
}