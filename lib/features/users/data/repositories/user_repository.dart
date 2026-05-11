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

    return (response as List)
        .map((json) => ProfileModel.fromJson(json))
        .toList();
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
    // Use edge function to create user with admin privileges
    final response = await _client.functions.invoke('create-user', body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'aadhar': aadhar,
      'pan': pan,
      'employee_id': employeeId,
      'assigned_zone': assignedZone,
    });

    if (response.data == null || response.data['error'] != null) {
      throw Exception(response.data?['error'] ?? 'Failed to create user');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', id);
  }

  Future<Map<String, int>> getUserStats() async {
    final response = await _client.from('profiles').select('role');
    final roles = (response as List).map((e) => e['role'] as String).toList();

    final stats = {
      'total': roles.length,
      'admins':
          roles.where((r) => r == 'admin' || r == 'executiveAdmin').length,
      'managers': roles.where((r) => r == 'manager').length,
      'staff': roles.where((r) => r == 'staff' || r == 'fieldStaff').length,
      'members':
          roles.where((r) => r == 'customer' || r == 'retailMember').length,
    };

    return stats;
  }

  Future<void> deleteUser(String id) async {
    // Get user_id from profile first
    final profile = await _client
        .from('profiles')
        .select('user_id')
        .eq('id', id)
        .maybeSingle();

    final userId = profile?['user_id'] as String?;

    // Delete profile first
    await _client.from('profiles').delete().eq('id', id);

    // If there's an auth user, delete it via edge function
    if (userId != null) {
      try {
        await _client.functions.invoke('delete-user', body: {'user_id': userId});
      } catch (e) {
        // Ignore if function fails - profile is already deleted
      }
    }
  }

  Future<void> deleteUsers(List<String> ids) async {
    for (final id in ids) {
      await deleteUser(id);
    }
  }
}
