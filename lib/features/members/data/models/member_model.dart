enum KYCStatus { verified, pending, rejected }

class MemberModel {
  final String id;
  final String fullName;
  final String phone;
  final String memberId;
  final KYCStatus kycStatus;
  final int activeLoans;
  final double totalSavings;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.memberId,
    required this.kycStatus,
    this.activeLoans = 0,
    this.totalSavings = 0,
    required this.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    KYCStatus status = KYCStatus.pending;
    final kycString = json['kyc_status'] as String?;
    if (kycString == 'verified') status = KYCStatus.verified;
    if (kycString == 'rejected') status = KYCStatus.rejected;

    return MemberModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown',
      phone: json['phone'] as String? ?? '',
      memberId: json['member_id'] as String? ?? '',
      kycStatus: status,
      activeLoans: json['active_loans'] as int? ?? 0,
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class MemberSummary {
  final int totalMembers;
  final int activeMembers;
  final int pendingKYC;

  MemberSummary({
    required this.totalMembers,
    required this.activeMembers,
    required this.pendingKYC,
  });
}
