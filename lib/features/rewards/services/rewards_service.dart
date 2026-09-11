import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/reward.dart';

class RewardsService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<RewardsCatalog> getRewards() async {
    final response = await _dio.get('/rewards', options: await _authOptions());
    return RewardsCatalog.fromJson(response.data as Map<String, dynamic>);
  }

  Future<int> redeem(String rewardId) async {
    final response = await _dio.post(
      '/rewards/$rewardId/redeem',
      options: await _authOptions(),
    );
    return (response.data as Map<String, dynamic>)['coins'] as int;
  }
}
