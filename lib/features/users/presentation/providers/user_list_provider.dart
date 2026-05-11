import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import 'new_user_provider.dart';

final userListProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
});

final userDetailsProvider = FutureProvider.family<ProfileModel?, String>((ref, id) async {
  final users = await ref.watch(userListProvider.future);
  try {
    return users.firstWhere((u) => u.id == id);
  } catch (e) {
    return null;
  }
});

final userStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserStats();
});
