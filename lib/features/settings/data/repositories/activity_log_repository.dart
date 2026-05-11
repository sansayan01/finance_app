import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_log_model.dart';

class ActivityLogRepository {
  final SupabaseClient _client;

  ActivityLogRepository(this._client);

  Future<void> log({
    required String action,
    required String details,
    required ActivityType type,
    String? userId,
    String? userName,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      await _client.from('activity_logs').insert({
        'user_id': userId ?? currentUser?.id ?? 'system',
        'user_name':
            userName ?? currentUser?.userMetadata?['full_name'] ?? 'System',
        'action': action,
        'details': details,
        'type': type.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail logging in dev if table missing
    }
  }

  Future<List<ActivityLogModel>> fetchLogs() async {
    final response = await _client
        .from('activity_logs')
        .select()
        .order('timestamp', ascending: false)
        .limit(100);

    return (response as List).map((e) => ActivityLogModel.fromJson(e)).toList();
  }
}
