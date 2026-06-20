import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

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

  // ─── Update profile (classLevel, state, subjects) ────────────────────────────

  Future<Map<String, dynamic>> updateProfile({
    String? classLevel,
    String? state,
    List<String>? subjects,
  }) async {
    final data = <String, dynamic>{};
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

  // ─── Claim welcome bonus ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>> claimWelcomeBonus() async {
    final response = await _dio.post(
      '/users/claim-bonus',
      options: await _authOptions(),
    );
    return response.data;
  }

  // ─── Complete starter challenge ──────────────────────────────────────────────

  Future<Map<String, dynamic>> completeStarterChallenge() async {
    final response = await _dio.post(
      '/users/complete-challenge',
      options: await _authOptions(),
    );
    return response.data;
  }
}