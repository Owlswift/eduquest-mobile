import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/storage/token_storage.dart';

class AuthState {
  final bool loading;
  final bool googleLoading;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.loading = false,
    this.googleLoading = false,
    this.token,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    bool? googleLoading,
    String? token,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      googleLoading: googleLoading ?? this.googleLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  final AuthService _service = AuthService();
  final TokenStorage _storage = TokenStorage();

  @override
  AuthState build() {
    // Restore session on app startup
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final token = await _storage.getToken();
    if (token != null) {
      try {
        final user = await _service.getProfile();
        state = state.copyWith(token: token, user: user);
      } catch (e) {
        state = state.copyWith(token: token);
      }
    }
  }

  // ─── Email/Password Login ──────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.login(email, password);
      await _storage.saveToken(token);
      final user = await _service.getProfile();
      if (user == null) {
        await logout();
        state = state.copyWith(loading: false, error: 'Failed to load user profile');
        return;
      }
      state = state.copyWith(loading: false, token: token, user: user);
    } on Exception catch (e) {
      final message = _parseError(e);
      state = state.copyWith(loading: false, error: message);
    }
  }

  // ─── Email/Password Register ───────────────────────────────────────────────

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final token = await _service.register(data);
      await _storage.saveToken(token);
      final user = await _service.getProfile();
      if (user == null) {
        await logout();
        state = state.copyWith(loading: false, error: 'Failed to load user profile');
        return;
      }
      state = state.copyWith(loading: false, token: token, user: user);
    } on Exception catch (e) {
      final message = _parseError(e);
      state = state.copyWith(loading: false, error: message);
    }
  }

  // ─── Google Login ──────────────────────────────────────────────────────────

  Future<void> googleLogin() async {
    state = state.copyWith(googleLoading: true, error: null);
    try {
      final token = await _service.googleLogin();
      await _storage.saveToken(token);
      final user = await _service.getProfile();
      if (user == null) {
        await logout();
        state = state.copyWith(googleLoading: false, error: 'Failed to load user profile');
        return;
      }
      state = state.copyWith(googleLoading: false, token: token, user: user);
    } on Exception catch (e) {
      final message = _parseError(e);
      state = state.copyWith(googleLoading: false, error: message);
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _service.googleSignOut(); // also clears Google session
    await _storage.deleteToken();
    state = const AuthState();
  }

  // ─── Error parser ──────────────────────────────────────────────────────────

  String _parseError(Exception e) {
    final raw = e.toString();

    // Dio errors from backend
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return 'Invalid email or password.';
    }
    if (raw.contains('404')) {
      return 'Account not found.';
    }
    if (raw.contains('409') || raw.contains('Conflict')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('Google sign-in cancelled')) {
      return 'Google sign-in was cancelled.';
    }
    if (raw.contains('Failed to get Google ID token')) {
      return 'Could not get Google credentials. Try again.';
    }
    if (raw.contains('SocketException') ||
        raw.contains('Connection refused') ||
        raw.contains('Network')) {
      return 'No internet connection. Please check your network.';
    }
    if (raw.contains('timeout') || raw.contains('Timeout')) {
      return 'Request timed out. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}