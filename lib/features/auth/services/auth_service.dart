import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/dio_client.dart';

class AuthService {
  final _dio = DioClient().dio;

  final _googleSignIn = GoogleSignIn.instance;
  
  GoogleSignInAccount? _currentGoogleUser;
  
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;

  // ─── Email/Password Login ───────────────────────────────────────────────────

  Future<String> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data['accessToken'];
  }

  // ─── Email/Password Register ────────────────────────────────────────────────

  Future<String> register(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '/auth/register',
      data: data,
    );
    return response.data['accessToken'];
  }

  // ─── Google Sign-In ─────────────────────────────────────────────────────────

  Future<String> googleLogin() async {
    // Initialize with server client ID for backend token verification
    await _googleSignIn.initialize(
      serverClientId: '108767173452-hdfi3kjhutv37somf60r50keo9kj66ju.apps.googleusercontent.com',
    );

    // 1. Trigger the Google sign-in flow
    final googleUser = await _googleSignIn.authenticate(
      scopeHint: ['email', 'profile']
    );

    // Store the Google user for later use
    _currentGoogleUser = googleUser;

    // 2. Get authentication tokens
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('Failed to get Google ID token');

    // 3. Send ID token to your backend for verification
    final response = await _dio.post(
      '/auth/google',
      data: {'idToken': idToken},
    );

    return response.data['accessToken'];
  }

  // ─── Get User Profile ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/me');
    return response.data;
  }

  // ─── Sign out from Google ───────────────────────────────────────────────────

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
  }
}
