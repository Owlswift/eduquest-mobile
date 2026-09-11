import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/tutor_models.dart';

/// Talks to the NestJS Tutor Engine (/api/tutor/*, /api/curriculum/*).
/// Image generation and voice transcription run local models on the
/// backend and are noticeably slower than a normal API call, hence the
/// longer per-request timeouts below.
class TutorService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions({Duration? receiveTimeout}) async {
    final token = await _storage.getToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
      receiveTimeout: receiveTimeout,
    );
  }

  Future<List<CurriculumTopicSummary>> getTopics({
    required String subjectId,
    required String classLevel,
  }) async {
    final response = await _dio.get(
      '/curriculum/topics',
      queryParameters: {'subjectId': subjectId, 'classLevel': classLevel},
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list
        .map((t) => CurriculumTopicSummary.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Topics the student has started but not finished - one per topic, most
  /// recently active first. Never returns the full curriculum.
  Future<List<InProgressTopic>> getContinueLearning({String? subjectId}) async {
    final response = await _dio.get(
      '/tutor/continue-learning',
      queryParameters: {if (subjectId != null) 'subjectId': subjectId},
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list
        .map((t) => InProgressTopic.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<TutorTurnResult> startSession({
    required String subjectId,
    required String classLevel,
    required String topicId,
  }) async {
    final response = await _dio.post(
      '/tutor/sessions',
      data: {
        'subjectId': subjectId,
        'classLevel': classLevel,
        'topicId': topicId,
      },
      // Generates the first tutor turn via the local LLM. TutorLlmService
      // retries once on a schema-validation failure, so the worst case is
      // ~2x a single generation - 45s wasn't enough headroom for that.
      options: await _authOptions(receiveTimeout: const Duration(seconds: 90)),
    );
    return TutorTurnResult.fromJson(response.data);
  }

  Future<TutorTurnResult> postMessage({
    required String sessionId,
    required String content,
  }) async {
    final response = await _dio.post(
      '/tutor/sessions/$sessionId/messages',
      data: {'content': content},
      // Generates the next tutor turn via the local LLM (see startSession
      // for why this needs headroom for a possible retry).
      options: await _authOptions(receiveTimeout: const Duration(seconds: 90)),
    );
    return TutorTurnResult.fromJson(response.data);
  }

  Future<TutorTurnResult> skipAssessment({required String sessionId}) async {
    final response = await _dio.post(
      '/tutor/sessions/$sessionId/skip-assessment',
      // Generates the first teaching turn via the local LLM (see
      // startSession for why this needs headroom for a possible retry).
      options: await _authOptions(receiveTimeout: const Duration(seconds: 90)),
    );
    return TutorTurnResult.fromJson(response.data);
  }

  Future<TutorTurnResult> postVoiceMessage({
    required String sessionId,
    required String audioFilePath,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFilePath),
    });
    final response = await _dio.post(
      '/tutor/sessions/$sessionId/voice-messages',
      data: formData,
      // Transcription (whisper.cpp) + a full tutor turn (which can itself
      // retry once) can take a while.
      options: await _authOptions(receiveTimeout: const Duration(seconds: 100)),
    );
    return TutorTurnResult.fromJson(response.data);
  }

  Future<List<Flashcard>> getFlashcards(String sessionId) async {
    final response = await _dio.get(
      '/tutor/sessions/$sessionId/flashcards',
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list.map((f) => Flashcard.fromJson(f as Map<String, dynamic>)).toList();
  }

  Future<Uint8List> getMessageAudio(String messageId) async {
    final response = await _dio.get<List<int>>(
      '/tutor/messages/$messageId/audio',
      options: (await _authOptions(receiveTimeout: const Duration(seconds: 30)))
          .copyWith(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  /// Returns Mermaid syntax for the diagram block in this message, along
  /// with a plain-English caption. The client renders the Mermaid code
  /// itself (e.g. via a WebView) - nothing is generated server-side here.
  Future<({String mermaidCode, String? description})> getMessageDiagram(
    String messageId,
  ) async {
    final response = await _dio.get(
      '/tutor/messages/$messageId/diagram',
      options: await _authOptions(),
    );
    return (
      mermaidCode: response.data['mermaidCode'] as String,
      description: response.data['description'] as String?,
    );
  }

  /// Generates the illustration image for this message. Runs a local
  /// Stable Diffusion pass server-side, so this can take 15-30+ seconds.
  Future<Uint8List> getMessageIllustration(String messageId) async {
    final response = await _dio.get<List<int>>(
      '/tutor/messages/$messageId/illustration',
      options: (await _authOptions(receiveTimeout: const Duration(seconds: 90)))
          .copyWith(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}
