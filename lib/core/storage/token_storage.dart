import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  static const _key = "access_token";
  static const _refreshKey = "refresh_token";

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  /// The long-lived token that renews the short-lived access token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  /// Ends the local login (both tokens).
  Future<void> deleteToken() async {
    await _storage.delete(key: _key);
    await _storage.delete(key: _refreshKey);
  }
}
