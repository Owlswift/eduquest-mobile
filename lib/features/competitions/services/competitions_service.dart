import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/competition.dart';

class CompetitionsService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Competition>> getCompetitions() async {
    final response = await _dio.get('/competitions', options: await _authOptions());
    final List<dynamic> list = response.data;
    return list.map((c) => Competition.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<void> join(String competitionId) async {
    await _dio.post(
      '/competitions/$competitionId/join',
      options: await _authOptions(),
    );
  }

  Future<CompetitionLeaderboard> getLeaderboard(String competitionId) async {
    final response = await _dio.get(
      '/competitions/$competitionId/leaderboard',
      options: await _authOptions(),
    );
    return CompetitionLeaderboard.fromJson(response.data as Map<String, dynamic>);
  }
}
