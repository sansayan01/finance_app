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

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      phone: user.phone,
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

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String? ?? '',
      phone: user.phone,
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  Stream<User?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}