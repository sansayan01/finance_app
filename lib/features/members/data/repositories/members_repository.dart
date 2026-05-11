import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_model.dart';

class MembersRepository {
  final SupabaseClient _client;

  MembersRepository(this._client);

  Future<List<MemberModel>> getMembers({int limit = 50, String? query}) async {
    try {
      var request = _client.from('members').select();

      if (query != null && query.isNotEmpty) {
        request = request.or(
            'full_name.ilike.%$query%,phone.ilike.%$query%,member_id.ilike.%$query%');
      }

      final response =
          await request.order('created_at', ascending: false).limit(limit);

      return (response as List)
          .map((json) => MemberModel.fromJson(json))
          .toList();
    } catch (e) {
      // If table is missing, return empty list instead of crashing
      return [];
    }
  }

  Future<MemberSummary> getMemberSummary() async {
    try {
      final response = await _client.from('members').select('id, kyc_status');
      final members = response as List;

      return MemberSummary(
        totalMembers: members.length,
        activeMembers:
            members.where((m) => m['kyc_status'] == 'verified').length,
        pendingKYC: members.where((m) => m['kyc_status'] == 'pending').length,
      );
    } catch (e) {
      return MemberSummary(totalMembers: 0, activeMembers: 0, pendingKYC: 0);
    }
  }
}
