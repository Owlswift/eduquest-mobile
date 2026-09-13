import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../quiz/models/quiz_models.dart';
import '../models/challenge_models.dart';

class ChallengesService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Students matching [q] by username/name, for picking an opponent.
  /// Requires at least 2 characters, same as the backend. The backend
  /// already restricts results to the caller's own class level, and -
  /// when [subjectId] is given - excludes anyone the caller already has
  /// an open challenge with for that subject, so every result here is
  /// actually challengeable.
  Future<List<ChallengeOpponentCandidate>> searchOpponents(String q, {String? subjectId}) async {
    if (q.trim().length < 2) return [];
    final response = await _dio.get(
      '/users/search',
      queryParameters: {'q': q, if (subjectId != null) 'subjectId': subjectId},
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list.map((u) => ChallengeOpponentCandidate.fromJson(u)).toList();
  }

  /// Algorithm-picked opponents for a subject, ranked by similar
  /// subject-specific ability, recent topic overlap, and activity -
  /// shown pseudonymously until a challenge actually exists.
  Future<ChallengeSuggestions> getSuggestions(String subjectId) async {
    final response = await _dio.get(
      '/challenges/suggestions',
      queryParameters: {'subjectId': subjectId},
      options: await _authOptions(),
    );
    return ChallengeSuggestions.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> create({
    required String opponentId,
    required String subjectId,
    required List<String> topics,
  }) async {
    final response = await _dio.post(
      '/challenges',
      data: {'opponentId': opponentId, 'subjectId': subjectId, 'topics': topics},
      options: await _authOptions(),
    );
    return response.data['id'] as String;
  }

  Future<List<ChallengeSummary>> list({String? status}) async {
    final response = await _dio.get(
      '/challenges',
      queryParameters: status != null ? {'status': status} : null,
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list.map((c) => ChallengeSummary.fromJson(c)).toList();
  }

  Future<ChallengeDetail> getOne(String id) async {
    final response = await _dio.get('/challenges/$id', options: await _authOptions());
    return ChallengeDetail.fromJson(response.data as Map<String, dynamic>);
  }

  /// The opponent picks their own topics and accepts - this is what
  /// triggers the combined, weighted question pool to be generated.
  Future<void> respond(String id, List<String> topics) async {
    await _dio.post(
      '/challenges/$id/respond',
      data: {'topics': topics},
      options: await _authOptions(),
    );
  }

  Future<void> decline(String id) async {
    await _dio.post('/challenges/$id/decline', options: await _authOptions());
  }

  /// This player's questions, with options in their own randomized order.
  /// Never includes the correct answer - grading happens on submit.
  Future<List<ChallengeQuestion>> getQuestions(String id) async {
    final response = await _dio.get('/challenges/$id/questions', options: await _authOptions());
    final List<dynamic> list = response.data;
    return list.map((q) => ChallengeQuestion.fromJson(q)).toList();
  }

  Future<Map<String, dynamic>> submitAnswers(
    String id,
    List<SubmittedAnswer> answers,
  ) async {
    final response = await _dio.post(
      '/challenges/$id/answers',
      data: {'answers': answers.map((a) => a.toJson()).toList()},
      options: await _authOptions(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<ChallengeResults> getResults(String id) async {
    final response = await _dio.get('/challenges/$id/results', options: await _authOptions());
    return ChallengeResults.fromJson(response.data as Map<String, dynamic>);
  }
}
