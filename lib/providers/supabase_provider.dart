import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (e) {
    throw Exception(
        'Supabase not initialized. Please configure your Supabase credentials.');
  }
});

final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange
        .map((event) => event.session?.user);
  } catch (e) {
    return const Stream.empty();
  }
});

final currentUserProvider = Provider<User?>((ref) {
  try {
    final authState = ref.watch(authStateProvider);
    return authState.whenOrNull(data: (user) => user);
  } catch (e) {
    return null;
  }
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  try {
    final user = ref.watch(currentUserProvider);
    return user != null;
  } catch (e) {
    return false;
  }
});
