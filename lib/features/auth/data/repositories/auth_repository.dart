import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Authentication failed');
    }

    final parsedDate = DateTime.tryParse(user.createdAt);
    
    // Fail-safe role fetching
    UserRole role = _parseRole(null, user.email);
    try {
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (profile != null) {
        role = _parseRole(profile['role'] as String?, user.email);
      }
    } catch (e) {
      // Fallback to default/email override
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      phone: user.phone,
      role: role,
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign up failed');
    }

    final parsedDate = DateTime.tryParse(user.createdAt);

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName,
      phone: phone,
      role: _parseRole(null, user.email),
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final parsedDate = DateTime.tryParse(user.createdAt);
    
    // Fail-safe role fetching
    UserRole role = _parseRole(null, user.email);
    try {
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile != null) {
        role = _parseRole(profile['role'] as String?, user.email);
      }
    } catch (e) {
      // Fallback to default/email override
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      phone: user.phone,
      role: role,
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  UserRole _parseRole(String? roleStr, String? email) {
    // Primary Admin Override
    if (email == 'msayan9733@gmail.com') {
      return UserRole.executiveAdmin;
    }
    
    if (roleStr == null) return UserRole.retailMember;
    
    return UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.retailMember,
    );
  }

  Stream<User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}