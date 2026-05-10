import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  try {
    final client = Supabase.instance.client;
    return AuthRepository(client);
  } catch (e) {
    // Return null if Supabase not initialized - demo mode
    return null;
  }
});

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository? _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    if (_repository == null) return;

    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (_repository == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Supabase not configured. Please add your Supabase credentials.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    if (_repository == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Supabase not configured. Please add your Supabase credentials.',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    if (_repository == null) return;
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> resetPassword(String email) async {
    if (_repository == null) return false;
    try {
      await _repository.resetPassword(email);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? email,
  }) async {
    if (_repository == null) return false;
    try {
      await _repository.updateProfile(fullName: fullName, phone: phone, email: email);
      await _checkSession(); // Refresh local user state
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: _getErrorMessage(e));
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_repository == null) return false;
    try {
      // Verify current password first
      await _repository.verifyPassword(currentPassword);
      // Update to new password
      await _repository.updatePassword(newPassword);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: _getErrorMessage(e));
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('user already registered')) {
      return 'This email is already registered';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address';
    }
    return 'An error occurred. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});