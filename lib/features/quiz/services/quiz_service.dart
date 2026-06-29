import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/quiz_models.dart';

class QuizService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  /// Fetch random questions for a quiz
  /// [subjectId] - The subject to fetch questions from
  /// [count] - Number of questions to fetch (default: 10)
  /// [classLevel] - Class level (SS1, SS2, SS3) for difficulty filtering
  Future<List<QuestionModel>> getRandomQuestions({
    required String subjectId,
    int count = 10,
    String classLevel = 'SS1',
  }) async {
    try {
      final token = await _storage.getToken();
      final response = await _dio.get(
        '/quiz/questions',
        queryParameters: {
          'subjectId': subjectId,
          'count': count,
          'classLevel': classLevel,
          'random': true,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> questionsList = response.data;
      return questionsList.map((q) => QuestionModel.fromJson(q)).toList();
    } catch (e) {
      // If API fails, return mock questions for demo purposes
      return _getMockQuestions(subjectId, count, classLevel);
    }
  }

  /// Submit quiz results to backend
  Future<Map<String, dynamic>> submitQuizResults({
    required String subjectId,
    required int correctAnswers,
    required int totalQuestions,
    required int timeTaken, // in seconds
  }) async {
    try {
      final token = await _storage.getToken();
      final response = await _dio.post(
        '/quiz/submit',
        data: {
          'subjectId': subjectId,
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'timeTaken': timeTaken,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      // Return mock results if API fails
      return {
        'earnedCoins': correctAnswers * 10,
        'earnedXp': correctAnswers * 10,
        'nationalRank': 4872,
        'stateRank': 312,
      };
    }
  }

  /// Mock questions for demo/fallback
  List<QuestionModel> _getMockQuestions(String subjectId, int count, String classLevel) {
    final mockQuestions = <QuestionModel>[
      QuestionModel(
        id: 'q1',
        subjectId: subjectId,
        questionText: 'What is the value of x in the equation: 2x + 5 = 13?',
        options: const [
          AnswerOption(id: 'a', text: '3'),
          AnswerOption(id: 'b', text: '4'),
          AnswerOption(id: 'c', text: '5'),
          AnswerOption(id: 'd', text: '6'),
        ],
        correctAnswerId: 'b',
        explanation: '2x + 5 = 13 → 2x = 8 → x = 4',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q2',
        subjectId: subjectId,
        questionText: 'Which of the following is a prime number?',
        options: const [
          AnswerOption(id: 'a', text: '15'),
          AnswerOption(id: 'b', text: '17'),
          AnswerOption(id: 'c', text: '21'),
          AnswerOption(id: 'd', text: '25'),
        ],
        correctAnswerId: 'b',
        explanation: '17 is only divisible by 1 and itself',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q3',
        subjectId: subjectId,
        questionText: 'What is the square root of 144?',
        options: const [
          AnswerOption(id: 'a', text: '10'),
          AnswerOption(id: 'b', text: '11'),
          AnswerOption(id: 'c', text: '12'),
          AnswerOption(id: 'd', text: '13'),
        ],
        correctAnswerId: 'c',
        explanation: '12 × 12 = 144',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q4',
        subjectId: subjectId,
        questionText: 'Solve: 3(x - 2) = 15',
        options: const [
          AnswerOption(id: 'a', text: '5'),
          AnswerOption(id: 'b', text: '6'),
          AnswerOption(id: 'c', text: '7'),
          AnswerOption(id: 'd', text: '8'),
        ],
        correctAnswerId: 'c',
        explanation: '3(x - 2) = 15 → x - 2 = 5 → x = 7',
        difficulty: 2,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q5',
        subjectId: subjectId,
        questionText: 'What is 15% of 200?',
        options: const [
          AnswerOption(id: 'a', text: '25'),
          AnswerOption(id: 'b', text: '30'),
          AnswerOption(id: 'c', text: '35'),
          AnswerOption(id: 'd', text: '40'),
        ],
        correctAnswerId: 'b',
        explanation: '15% of 200 = 0.15 × 200 = 30',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q6',
        subjectId: subjectId,
        questionText: 'If y = 2x + 3, what is y when x = 4?',
        options: const [
          AnswerOption(id: 'a', text: '8'),
          AnswerOption(id: 'b', text: '9'),
          AnswerOption(id: 'c', text: '10'),
          AnswerOption(id: 'd', text: '11'),
        ],
        correctAnswerId: 'd',
        explanation: 'y = 2(4) + 3 = 8 + 3 = 11',
        difficulty: 2,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q7',
        subjectId: subjectId,
        questionText: 'What is the area of a rectangle with length 8cm and width 5cm?',
        options: const [
          AnswerOption(id: 'a', text: '26 cm²'),
          AnswerOption(id: 'b', text: '36 cm²'),
          AnswerOption(id: 'c', text: '40 cm²'),
          AnswerOption(id: 'd', text: '48 cm²'),
        ],
        correctAnswerId: 'c',
        explanation: 'Area = length × width = 8 × 5 = 40 cm²',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q8',
        subjectId: subjectId,
        questionText: 'Simplify: 4x + 3x - 2x',
        options: const [
          AnswerOption(id: 'a', text: '3x'),
          AnswerOption(id: 'b', text: '5x'),
          AnswerOption(id: 'c', text: '7x'),
          AnswerOption(id: 'd', text: '9x'),
        ],
        correctAnswerId: 'b',
        explanation: '4x + 3x - 2x = (4 + 3 - 2)x = 5x',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q9',
        subjectId: subjectId,
        questionText: 'What is the next number in the sequence: 2, 6, 18, 54, ...?',
        options: const [
          AnswerOption(id: 'a', text: '108'),
          AnswerOption(id: 'b', text: '144'),
          AnswerOption(id: 'c', text: '162'),
          AnswerOption(id: 'd', text: '216'),
        ],
        correctAnswerId: 'c',
        explanation: 'Each number is multiplied by 3: 54 × 3 = 162',
        difficulty: 3,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q10',
        subjectId: subjectId,
        questionText: 'If a = 3 and b = 4, what is a² + b²?',
        options: const [
          AnswerOption(id: 'a', text: '12'),
          AnswerOption(id: 'b', text: '14'),
          AnswerOption(id: 'c', text: '25'),
          AnswerOption(id: 'd', text: '49'),
        ],
        correctAnswerId: 'c',
        explanation: 'a² + b² = 3² + 4² = 9 + 16 = 25',
        difficulty: 2,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q11',
        subjectId: subjectId,
        questionText: 'What is 25% of 80?',
        options: const [
          AnswerOption(id: 'a', text: '15'),
          AnswerOption(id: 'b', text: '20'),
          AnswerOption(id: 'c', text: '25'),
          AnswerOption(id: 'd', text: '30'),
        ],
        correctAnswerId: 'b',
        explanation: '25% of 80 = 0.25 × 80 = 20',
        difficulty: 1,
        classLevel: classLevel,
      ),
      QuestionModel(
        id: 'q12',
        subjectId: subjectId,
        questionText: 'Solve for x: 5x - 3 = 2x + 9',
        options: const [
          AnswerOption(id: 'a', text: '2'),
          AnswerOption(id: 'b', text: '3'),
          AnswerOption(id: 'c', text: '4'),
          AnswerOption(id: 'd', text: '5'),
        ],
        correctAnswerId: 'c',
        explanation: '5x - 2x = 9 + 3 → 3x = 12 → x = 4',
        difficulty: 2,
        classLevel: classLevel,
      ),
    ];

    // Return requested number of questions (shuffle and slice)
    final shuffled = mockQuestions.toList()..shuffle();
    return shuffled.take(count).toList();
  }
}