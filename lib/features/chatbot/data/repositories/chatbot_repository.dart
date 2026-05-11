import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/chat_message.dart';

class ChatbotRepository {
  final String _apiKey;
  final String _model;

  ChatbotRepository({required String apiKey, required String model}) 
    : _apiKey = apiKey, 
      _model = model;

  Future<String> getChatResponse(List<ChatMessage> history, {String? contextRoute, String? businessContext}) async {
    final messages = history.map((m) => m.toJson()).toList();
    
    String systemContext = 'You are the MicroFlow Pro Assistant, a multilingual financial expert. '
        'You must respond in the same language the user uses. Support all Indian regional languages '
        '(Hindi, Tamil, Telugu, Bengali, Kannada, Marathi, etc.) with professional financial terminology. '
        'Keep responses concise. If the user asks for a loan summary or portfolio overview, '
        'you MUST include the exact tag [UI:LOAN_SUMMARY] somewhere in your response to trigger a rich interactive chart.';
    
    if (contextRoute != null && contextRoute.isNotEmpty) {
      systemContext += ' \nThe user is currently viewing the "$contextRoute" page.';
    }
    
    if (businessContext != null && businessContext.isNotEmpty) {
      systemContext += ' \nLIVE DATABASE CONTEXT:\n$businessContext';
    }

    messages.insert(0, {
      'role': 'system',
      'content': systemContext
    });

    // Try all known NVIDIA NIM gateways for maximum compatibility
    final endpoints = [
      'https://integrate.api.nvidia.com/v1/chat/completions',
      'https://ai.api.nvidia.com/v1/chat/completions',
      'https://api.nvidia.com/v1/chat/completions',
    ];

    Object? lastError;

    // Use a CORS proxy if running on Web to bypass browser restrictions
    final proxyPrefix = kIsWeb ? 'https://corsproxy.io/?' : '';

    for (final baseEndpoint in endpoints) {
      try {
        final url = '$proxyPrefix$baseEndpoint';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'model': _model,
            'messages': messages,
            'temperature': 0.5,
            'max_tokens': 1024,
            'top_p': 1,
          }),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'] as String;
        } else {
          throw Exception('NVIDIA Error ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        lastError = e;
        continue; // Try next endpoint
      }
    }

    throw Exception('All connection attempts failed. Last error: $lastError');
  }
}
