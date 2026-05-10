import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brand_model.dart';
import 'activity_log_repository_provider.dart';
import '../models/activity_log_model.dart';

class BrandNotifier extends StateNotifier<BrandModel> {
  final SupabaseClient _client;
  final Ref _ref;

  BrandNotifier(this._client, this._ref) : super(BrandModel(name: 'MicroFlow Pro')) {
    _loadBrand();
  }

  Future<void> _loadBrand() async {
    try {
      final response = await _client
          .from('system_settings')
          .select()
          .eq('key', 'branding')
          .maybeSingle();

      if (response != null) {
        state = BrandModel.fromJson(response['value']);
      }
    } catch (e) {
      // Keep default if table/entry missing
    }
  }

  Future<void> updateBrand({String? name, String? logoUrl}) async {
    final oldName = state.name;
    final newState = state.copyWith(name: name, logoUrl: logoUrl);
    state = newState;

    try {
      await _client.from('system_settings').upsert({
        'key': 'branding',
        'value': newState.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Log the activity
      await _ref.read(activityLogRepositoryProvider).log(
        action: 'System Branding Updated',
        details: 'Changed brand name from "$oldName" to "${newState.name}"',
        type: ActivityType.systemUpdate,
      );
    } catch (e) {
      // Local only if DB fails
    }
  }
}

final brandProvider = StateNotifierProvider<BrandNotifier, BrandModel>((ref) {
  return BrandNotifier(Supabase.instance.client, ref);
});
