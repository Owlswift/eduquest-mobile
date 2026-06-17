import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../../core/storage/token_storage.dart';

class AuthState {
  final bool loading;
  final String? token;
  final String? error;

  const AuthState({
    this.loading = false,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    String? token,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      token: token ?? this.token,
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
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final token = await _service.login(email, password);
      await _storage.saveToken(token);
      state = state.copyWith(loading: false, token: token);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final token = await _service.register(data);
      await _storage.saveToken(token);
      state = state.copyWith(loading: false, token: token);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}