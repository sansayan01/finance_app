import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/chatbot_repository.dart';
import 'chat_config_provider.dart';
import '../../../loans/data/providers/loan_providers.dart';
import '../../../../router/app_router.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  final config = ref.watch(chatConfigProvider);
  return ChatbotRepository(apiKey: config.apiKey, model: config.modelId);
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isListening;
  final bool isSpeaking;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isListening,
    bool? isSpeaking,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatbotRepository _repository;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final Ref _ref;

  ChatNotifier(this._repository, this._ref) : super(ChatState()) {
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
  }

  Future<void> sendMessage(String text, {String? contextRoute}) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, role: MessageRole.user);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Agentic Navigation Logic
    final t = text.toLowerCase();
    if (t.contains('go to') || t.contains('navigate to') || t.contains('open')) {
      bool navigated = false;
      if (t.contains('settings') || t.contains('admin')) {
        _ref.read(routerProvider).go('/settings');
        navigated = true;
      } else if (t.contains('analytics') || t.contains('dashboard')) {
        _ref.read(routerProvider).go('/analytics');
        navigated = true;
      } else if (t.contains('loans')) {
        _ref.read(routerProvider).go('/loans');
        navigated = true;
      } else if (t.contains('savings')) {
        _ref.read(routerProvider).go('/savings');
        navigated = true;
      } else if (t.contains('users') || t.contains('members')) {
        _ref.read(routerProvider).go('/users');
        navigated = true;
      }

      if (navigated) {
        state = state.copyWith(
          messages: [...state.messages, ChatMessage(text: "Navigating there now.", role: MessageRole.assistant)],
          isLoading: false,
        );
        return;
      }
    }

    // Auto-detect current page context
    String? currentRoute;
    try {
      currentRoute = _ref.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();
    } catch (_) {}

    // RAG: Auto-fetch Live Database Context if requested
    String? businessContext;
    if (t.contains('loan') || t.contains('summary') || t.contains('portfolio') || t.contains('analytics')) {
      try {
        final loanSummary = await _ref.read(loanSummaryProvider.future);
        businessContext = '''
Total Loans: ${loanSummary.totalLoans}
Active Loans: ${loanSummary.activeLoans}
Default Loans: ${loanSummary.defaultLoans}
Total Outstanding: \$${loanSummary.totalOutstanding.toStringAsFixed(2)}
Total Disbursed: \$${loanSummary.totalDisbursed.toStringAsFixed(2)}
Total Collected: \$${loanSummary.totalCollected.toStringAsFixed(2)}
Overdue Amount: \$${loanSummary.overdueAmount.toStringAsFixed(2)}
PAR (Portfolio at Risk): ${loanSummary.parPercentage.toStringAsFixed(1)}%
''';
      } catch (e) {
        businessContext = 'Error fetching live data: $e';
      }
    }

    try {
      final responseText = await _repository.getChatResponse(state.messages, contextRoute: currentRoute, businessContext: businessContext)
          .timeout(const Duration(seconds: 30), onTimeout: () {
            throw Exception('Connection timed out. Please check your internet and API status.');
          });
          
      final assistantMessage = ChatMessage(text: responseText, role: MessageRole.assistant);
      
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('401')) errorMsg = 'Invalid API Key. Please check your NVIDIA NIM credentials.';
      if (errorMsg.contains('404')) errorMsg = 'Model not found. Please verify the Model ID in settings.';
      
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
      );
    }
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          state = state.copyWith(isListening: false);
        }
      },
      onError: (errorNotification) {
        state = state.copyWith(isListening: false, error: errorNotification.errorMsg);
      },
    );

    if (available) {
      state = state.copyWith(isListening: true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            sendMessage(result.recognizedWords);
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  Future<void> speak(String text) async {
    state = state.copyWith(isSpeaking: true);
    await _tts.speak(text);
    _tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    state = state.copyWith(isSpeaking: false);
  }

  void clearHistory() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatbotRepositoryProvider);
  return ChatNotifier(repository, ref);
});
