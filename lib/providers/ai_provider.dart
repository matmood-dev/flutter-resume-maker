import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';

class AiState {
  final int aiCredits;
  final bool isGenerating;
  final String? lastResult;
  final String? error;

  const AiState({
    this.aiCredits = 10,
    this.isGenerating = false,
    this.lastResult,
    this.error,
  });

  AiState copyWith({
    int? aiCredits,
    bool? isGenerating,
    String? lastResult,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return AiState(
      aiCredits: aiCredits ?? this.aiCredits,
      isGenerating: isGenerating ?? this.isGenerating,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiNotifier extends StateNotifier<AiState> {
  final Ref ref;

  AiNotifier(this.ref) : super(const AiState());

  Future<void> loadCredits() async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select('ai_credits')
          .eq('id', user.id)
          .single();

      final credits = data['ai_credits'] as int? ?? 10;
      state = state.copyWith(aiCredits: credits);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool useCredit() {
    if (state.aiCredits <= 0) {
      state = state.copyWith(error: 'No AI credits remaining.');
      return false;
    }
    state = state.copyWith(aiCredits: state.aiCredits - 1, clearError: true);
    return true;
  }

  Future<void> _updateCreditsInSupabase(int newCredits) async {
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      await Supabase.instance.client
          .from('profiles')
          .update({'ai_credits': newCredits}).eq('id', user.id);
    } catch (_) {}
  }

  Future<String> generateContent({
    required String prompt,
    String? section,
  }) async {
    if (!useCredit()) {
      return '';
    }

    state = state.copyWith(isGenerating: true, clearError: true);
    await Future.delayed(const Duration(seconds: 2));

    final result = _mockGenerate(prompt, section);
    state = state.copyWith(isGenerating: false, lastResult: result);
    await _updateCreditsInSupabase(state.aiCredits);
    return result;
  }

  Future<String> improveContent({
    required String content,
    required String instruction,
  }) async {
    if (!useCredit()) {
      return content;
    }

    state = state.copyWith(isGenerating: true, clearError: true);
    await Future.delayed(const Duration(seconds: 2));

    final result = _mockImprove(content, instruction);
    state = state.copyWith(isGenerating: false, lastResult: result);
    await _updateCreditsInSupabase(state.aiCredits);
    return result;
  }

  String _mockGenerate(String prompt, String? section) {
    switch (section) {
      case 'summary':
        return 'Results-driven professional with a proven track record of delivering high-impact '
            'projects on time. Adept at cross-functional collaboration and innovative problem-solving.';
      case 'experience':
        return '• Led a team of 6 engineers to deliver a customer-facing dashboard, '
            'increasing user engagement by 34%.\n'
            '• Architected a microservices migration that reduced latency by 40%.';
      case 'skills':
        return 'Dart, Flutter, Firebase, AWS, CI/CD, Agile Methodologies';
      default:
        return 'Experienced professional with expertise in building scalable solutions '
            'and driving measurable business outcomes.';
    }
  }

  String _mockImprove(String content, String instruction) {
    if (instruction.toLowerCase().contains('shorter')) {
      return content.length > 60 ? '${content.substring(0, 60)}...' : content;
    }
    if (instruction.toLowerCase().contains('longer')) {
      return '$content Expanded with additional context and quantifiable achievements to demonstrate greater impact and scope.';
    }
    return 'Enhanced: $content';
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(ref);
});

final aiCreditsProvider = Provider<int>((ref) {
  return ref.watch(aiProvider).aiCredits;
});
