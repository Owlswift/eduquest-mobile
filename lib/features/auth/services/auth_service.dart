import '../../../core/network/dio_client.dart';

class AuthService {
  final dio = DioClient().dio;

  Future<String> login(String email, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data['accessToken'];
  }

  Future<String> register(Map<String, dynamic> data) async {
    final response = await dio.post(
      '/auth/register',
      data: data,
    );

    return response.data['accessToken'];
  }
}