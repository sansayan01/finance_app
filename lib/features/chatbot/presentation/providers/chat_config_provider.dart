import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatConfig {
  final String apiKey;
  final String modelId;

  ChatConfig({
    required this.apiKey,
    required this.modelId,
  });

  ChatConfig copyWith({
    String? apiKey,
    String? modelId,
  }) {
    return ChatConfig(
      apiKey: apiKey ?? this.apiKey,
      modelId: modelId ?? this.modelId,
    );
  }
}

class ChatConfigNotifier extends StateNotifier<ChatConfig> {
  static const _apiKeyKey = 'chatbot_api_key';
  static const _modelIdKey = 'chatbot_model_id';

  ChatConfigNotifier() : super(ChatConfig(
    apiKey: '',
    modelId: 'meta/llama3-70b-instruct',
  )) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      apiKey: prefs.getString(_apiKeyKey) ?? '',
      modelId: prefs.getString(_modelIdKey) ?? 'meta/llama3-70b-instruct',
    );
  }

  Future<void> updateConfig({required String apiKey, required String modelId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    await prefs.setString(_modelIdKey, modelId);
    state = state.copyWith(apiKey: apiKey, modelId: modelId);
  }
}

final chatConfigProvider = StateNotifierProvider<ChatConfigNotifier, ChatConfig>((ref) {
  return ChatConfigNotifier();
});
