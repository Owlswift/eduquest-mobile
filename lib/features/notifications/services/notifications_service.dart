import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/app_notification.dart';

class NotificationsService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get('/notifications', options: await _authOptions());
    final List<dynamic> list = response.data;
    return list.map((n) => AppNotification.fromJson(n as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count', options: await _authOptions());
    return (response.data as Map<String, dynamic>)['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) async {
    await _dio.post('/notifications/$id/read', options: await _authOptions());
  }

  Future<void> markAllRead() async {
    await _dio.post('/notifications/read-all', options: await _authOptions());
  }
}
