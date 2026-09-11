import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../network/dio_client.dart';
import '../storage/token_storage.dart';

/// Wires the device up for push notifications: initializes Firebase,
/// requests permission, and registers the FCM token with the backend
/// (POST /push/register-token) - re-registering whenever FCM rotates it.
///
/// Every step is wrapped so a missing/misconfigured Firebase project on
/// either platform (e.g. no GoogleService-Info.plist yet on iOS) just
/// skips push silently instead of crashing app startup - the rest of the
/// app, including the in-app notification center, works either way.
class PushRegistrationService {
  static final PushRegistrationService _instance = PushRegistrationService._internal();
  factory PushRegistrationService() => _instance;
  PushRegistrationService._internal();

  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  bool _firebaseReady = false;
  bool _listening = false;

  Future<void> _ensureFirebase() async {
    if (_firebaseReady) return;
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
    } catch (e) {
      developer.log('Firebase init failed - push disabled for this session: $e');
    }
  }

  /// Call after a successful login/register/session-restore. No-ops
  /// quietly if Firebase isn't configured on this platform yet.
  Future<void> registerThisDevice() async {
    await _ensureFirebase();
    if (!_firebaseReady) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) return;

      final token = await messaging.getToken();
      if (token != null) await _sendToken(token);

      if (!_listening) {
        _listening = true;
        messaging.onTokenRefresh.listen(_sendToken);
      }
    } catch (e) {
      developer.log('Push registration failed: $e');
    }
  }

  Future<void> _sendToken(String token) async {
    try {
      final authToken = await _storage.getToken();
      if (authToken == null) return; // not logged in - nothing to attach it to
      await _dio.post(
        '/push/register-token',
        data: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
    } catch (e) {
      developer.log('Sending push token to backend failed: $e');
    }
  }

  /// Best-effort: call on logout, BEFORE the auth token is cleared from
  /// storage (the endpoint requires it), so this device stops receiving
  /// pushes meant for the account that just signed out.
  Future<void> unregisterThisDevice() async {
    if (!_firebaseReady) return;
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final authToken = await _storage.getToken();
      if (fcmToken == null || authToken == null) return;
      await _dio.delete(
        '/push/register-token/$fcmToken',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );
    } catch (e) {
      developer.log('Push unregister failed: $e');
    }
  }
}
