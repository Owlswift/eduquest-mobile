import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutor_models.dart';
import '../services/tutor_service.dart';

class TutorChatState {
  final bool loading;
  final bool sending;
  final TutorSession? session;
  final List<TutorMessage> messages;
  final String? error;

  const TutorChatState({
    this.loading = false,
    this.sending = false,
    this.session,
    this.messages = const [],
    this.error,
  });

  TutorChatState copyWith({
    bool? loading,
    bool? sending,
    TutorSession? session,
    List<TutorMessage>? messages,
    String? error,
    bool clearError = false,
  }) {
    return TutorChatState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final tutorControllerProvider =
    NotifierProvider<TutorController, TutorChatState>(TutorController.new);

class TutorController extends Notifier<TutorChatState> {
  final TutorService _service = TutorService();

  @override
  TutorChatState build() => const TutorChatState();

  Future<void> startSession({
    required String subjectId,
    required String classLevel,
    required String topicId,
  }) async {
    state = const TutorChatState(loading: true);
    try {
      final result = await _service.startSession(
        subjectId: subjectId,
        classLevel: classLevel,
        topicId: topicId,
      );
      state = TutorChatState(
        loading: false,
        session: result.session,
        messages: result.messages ?? [result.message],
      );
    } catch (e) {
      state = TutorChatState(loading: false, error: _parseError(e));
    }
  }

  Future<void> sendMessage(String content) async {
    final session = state.session;
    final trimmed = content.trim();
    if (session == null || trimmed.isEmpty) return;

    final studentMessage = TutorMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      sessionId: session.id,
      role: 'STUDENT',
      content: trimmed,
      blocks: const [],
      stateAt: session.state,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      sending: true,
      clearError: true,
      messages: [...state.messages, studentMessage],
    );
    try {
      final result = await _service.postMessage(
        sessionId: session.id,
        content: trimmed,
      );
      _applyTurnResult(result);
    } catch (e) {
      state = state.copyWith(sending: false, error: _parseError(e));
    }
  }

  Future<void> skipAssessment() async {
    final session = state.session;
    if (session == null) return;

    state = state.copyWith(sending: true, clearError: true);
    try {
      final result = await _service.skipAssessment(sessionId: session.id);
      _applyTurnResult(result);
    } catch (e) {
      state = state.copyWith(sending: false, error: _parseError(e));
    }
  }

  Future<void> sendVoiceMessage(String audioFilePath) async {
    final session = state.session;
    if (session == null) return;

    state = state.copyWith(sending: true, clearError: true);
    try {
      final result = await _service.postVoiceMessage(
        sessionId: session.id,
        audioFilePath: audioFilePath,
      );
      if (result.transcript != null && result.transcript!.trim().isNotEmpty) {
        final studentMessage = TutorMessage(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          sessionId: session.id,
          role: 'STUDENT',
          content: result.transcript!.trim(),
          blocks: const [],
          stateAt: session.state,
          createdAt: DateTime.now(),
        );
        state = state.copyWith(messages: [...state.messages, studentMessage]);
      }
      _applyTurnResult(result);
    } catch (e) {
      state = state.copyWith(sending: false, error: _parseError(e));
    }
  }

  void _applyTurnResult(TutorTurnResult result) {
    final updated = [
      ...state.messages,
      result.message,
      if (result.completionMessage != null) result.completionMessage!,
    ];
    state = state.copyWith(
      sending: false,
      session: result.session,
      messages: updated,
    );
  }

  String _parseError(Object e) {
    final message = e.toString();
    if (message.contains('SocketException') || message.contains('Connection')) {
      return "Can't reach the tutor right now - check your connection.";
    }
    if (message.contains('timeout')) {
      return 'That took too long to respond. Please try again.';
    }
    return "Something went wrong. Let's try that again.";
  }
}
