import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/quiz_models.dart';

class QuizService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Fetch random questions for a quiz. Never includes the correct answer -
  /// that's only revealed per-question (via [checkAnswer], after the
  /// student has answered) or computed server-side on submit.
  Future<List<QuestionModel>> getRandomQuestions({
    required String subjectId,
    int count = 10,
    String classLevel = 'SS1',
  }) async {
    final response = await _dio.get(
      '/quiz/questions',
      queryParameters: {
        'subjectId': subjectId,
        'count': count,
        'classLevel': classLevel,
      },
      options: await _authOptions(),
    );

    final List<dynamic> questionsList = response.data;
    return questionsList.map((q) => QuestionModel.fromJson(q)).toList();
  }

  /// Distinct topics tagged on a subject's question bank - powers the
  /// Challenges topic picker.
  Future<List<TopicOption>> getTopics({
    required String subjectId,
    String classLevel = 'SS1',
  }) async {
    final response = await _dio.get(
      '/quiz/topics',
      queryParameters: {'subjectId': subjectId, 'classLevel': classLevel},
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list.map((t) => TopicOption.fromJson(t)).toList();
  }

  /// Reveal whether one already-answered question was right. Stateless -
  /// doesn't affect scoring (submitQuizResults grades independently).
  Future<QuizAnswerCheck> checkAnswer({
    required String questionId,
    required String selectedOptionId,
  }) async {
    final response = await _dio.post(
      '/quiz/questions/$questionId/check',
      data: {'selectedOptionId': selectedOptionId},
      options: await _authOptions(),
    );
    return QuizAnswerCheck.fromJson(response.data as Map<String, dynamic>);
  }

  /// Submit a completed quiz for real, server-side grading.
  Future<Map<String, dynamic>> submitQuizResults({
    required String subjectId,
    required List<SubmittedAnswer> answers,
    required int timeTaken, // in seconds
  }) async {
    final response = await _dio.post(
      '/quiz/submit',
      data: {
        'subjectId': subjectId,
        'answers': answers.map((a) => a.toJson()).toList(),
        'timeTaken': timeTaken,
      },
      options: await _authOptions(),
    );
    return response.data as Map<String, dynamic>;
  }
}

class QuizAnswerCheck {
  final bool correct;
  final String correctOptionId;
  final String? explanation;

  const QuizAnswerCheck({
    required this.correct,
    required this.correctOptionId,
    this.explanation,
  });

  factory QuizAnswerCheck.fromJson(Map<String, dynamic> json) {
    return QuizAnswerCheck(
      correct: json['correct'] ?? false,
      correctOptionId: json['correctOptionId'] ?? '',
      explanation: json['explanation'],
    );
  }
}
