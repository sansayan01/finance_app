import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/data/models/user_model.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  Future<List<ProfileModel>> getUsers() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => ProfileModel.fromJson(json)).toList();
  }

  Future<void> createUser({
    required String fullName,
    required String email,
    required String phone,
    required UserRole role,
    required String aadhar,
    required String pan,
    String? employeeId,
    String? assignedZone,
    required String password,
  }) async {
    // In a production app with Supabase, creating an AUTH user requires an Edge Function
    // or Service Role. For now, we will create the PROFILE record.
    // If the user needs to LOGIN, they should be created via the Auth flow or a backend function.
    
    await _client.from('profiles').insert({
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'aadhar': aadhar,
      'pan': pan,
      'employee_id': employeeId,
      'assigned_zone': assignedZone,
    });
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', id);
  }

  Future<Map<String, int>> getUserStats() async {
    final response = await _client.from('profiles').select('role');
    final roles = (response as List).map((e) => e['role'] as String).toList();
    
    final stats = {
      'total': roles.length,
      'admins': roles.where((r) => r == UserRole.executiveAdmin.name).length,
      'managers': roles.where((r) => r == UserRole.manager.name).length,
      'staff': roles.where((r) => r == UserRole.fieldStaff.name).length,
      'members': roles.where((r) => r == UserRole.retailMember.name).length,
    };
    
    return stats;
  }
}
