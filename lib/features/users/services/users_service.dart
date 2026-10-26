import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../dashboard/models/daily_summary.dart';
import '../../dashboard/models/leaderboard.dart';
import '../../dashboard/models/subject_progress_entry.dart';
import '../../quiz/models/quiz_models.dart';

class UsersService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  // ─── Inject token into every request ────────────────────────────────────────

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ─── Get my profile ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(
      '/users/me',
      options: await _authOptions(),
    );
    return response.data;
  }

  // ─── Daily summary (streak strip + today's goal) ─────────────────────────────

  Future<DailySummary> getDailySummary() async {
    final response = await _dio.get(
      '/users/daily-summary',
      options: await _authOptions(),
    );
    return DailySummary.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Leaderboard (all-time, by XP) ──────────────────────────────────────────

  /// [period]: 'all' (lifetime total), 'weekly' or 'monthly' (XP earned
  /// in the last 7/30 days).
  Future<LeaderboardData> getLeaderboard({String period = 'all'}) async {
    final response = await _dio.get(
      '/users/leaderboard',
      queryParameters: {'period': period},
      options: await _authOptions(),
    );
    return LeaderboardData.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── Per-subject mastery progress (Profile tab) ─────────────────────────────

  Future<List<SubjectProgressEntry>> getSubjectProgress() async {
    final response = await _dio.get(
      '/users/subject-progress',
      options: await _authOptions(),
    );
    final List<dynamic> list = response.data;
    return list
        .map((e) => SubjectProgressEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Update profile (fullName, phone, classLevel, state, subjects) ──────────

  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
    String? classLevel,
    String? state,
    List<String>? subjects,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (classLevel != null) data['classLevel'] = classLevel;
    if (state != null) data['state'] = state;
    if (subjects != null) data['subjects'] = subjects;

    final response = await _dio.patch(
      '/users/profile',
      data: data,
      options: await _authOptions(),
    );
    return response.data;
  }

  // ─── Change password (while logged in) ──────────────────────────────────────

  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dio.patch(
      '/users/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        // So this device stays signed in while the others are signed out.
        'refreshToken': await _storage.getRefreshToken(),
      },
      options: await _authOptions(),
    );
  }

  // ─── Delete account ──────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    await _dio.delete('/users/me', options: await _authOptions());
  }

  // ─── Claim welcome bonus ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> claimWelcomeBonus() async {
    final response = await _dio.post(
      '/users/claim-bonus',
      options: await _authOptions(),
    );
    return response.data;
  }

  // ─── Complete starter challenge ──────────────────────────────────────────────

  Future<Map<String, dynamic>> completeStarterChallenge(
    String sessionId,
    List<SubmittedAnswer> answers,
  ) async {
    final response = await _dio.post(
      '/users/complete-challenge',
      data: {
        'sessionId': sessionId,
        'answers': answers.map((a) => a.toJson()).toList(),
      },
      options: await _authOptions(),
    );
    return response.data;
  }
}