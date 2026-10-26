import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/token_storage.dart';

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
  final TokenStorage _tokens = TokenStorage();

  // One refresh at a time: the server accepts each refresh token once, so two
  // parallel refreshes would end the login. Everyone waits for the same one.
  Future<String?>? _refreshing;

  /// Stores the tokens from a login, registration or refresh response.
  Future<void> saveSession(Map<String, dynamic> data) async {
    final access = data['accessToken'];
    final refresh = data['refreshToken'];
    if (access is String) await _tokens.saveToken(access);
    if (refresh is String) await _tokens.saveRefreshToken(refresh);
  }

  /// Swaps the refresh token for a new access token; null if the login is over.
  Future<String?> _refreshAccessToken() {
    return _refreshing ??= () async {
      try {
        final refresh = await _tokens.getRefreshToken();
        if (refresh == null) return null;
        // A bare client: no interceptors, so a failure here cannot loop back into refreshing.
        final bare = Dio(BaseOptions(
          baseUrl: _apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
        final response = await bare.post('/auth/refresh', data: {'refreshToken': refresh});
        await saveSession(Map<String, dynamic>.from(response.data as Map));
        return response.data['accessToken'] as String;
      } catch (_) {
        return null;
      } finally {
        _refreshing = null;
      }
    }();
  }

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
        // 401 usually means the short-lived access token expired: renew it and
        // retry the request once. If that fails the login is over.
        final request = error.requestOptions;
        final isAuthCall = request.path.startsWith('/auth/');
        if (error.response?.statusCode == 401 && !isAuthCall && request.extra['retried'] != true) {
          final token = await _refreshAccessToken();
          if (token != null) {
            request.extra['retried'] = true;
            request.headers['Authorization'] = 'Bearer $token';
            try {
              return handler.resolve(await dio.fetch(request));
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
        }
        if (error.response?.statusCode == 401 && !isAuthCall) {
          await _tokens.deleteToken();
        }
        return handler.next(error);
      },
    ));
  }
}
