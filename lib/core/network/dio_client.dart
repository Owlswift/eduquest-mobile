import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Override at build time for a real deployment, e.g.:
//   flutter build ipa --dart-define=API_BASE_URL=https://api.eduquest.example/api
// Defaults to the local dev machine's LAN IP so `flutter run` keeps working
// unchanged during development. A release build must NOT ship with this
// default - there is no production backend behind it.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: "http://192.168.100.182:3050/api",
);

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Verbose request/response logging (headers included, so this covers
    // the bearer token) - dev-only, never in a release build.
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // ignore: avoid_print
          print('🌐 API: $obj');
        },
      ));
    }

    // Add token interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized - token expired or invalid
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'access_token');
        }
        return handler.next(error);
      },
    ));
  }
}
