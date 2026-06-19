import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';

class DashboardState {
  final bool loading;
  final Map<String, dynamic>? user;
  final String? error;

  const DashboardState({
    this.loading = false,
    this.user,
    this.error,
  });

  DashboardState copyWith({
    bool? loading,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return DashboardState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(DashboardController.new);

class DashboardController extends Notifier<DashboardState> {
  final AuthService _authService = AuthService();

  @override
  DashboardState build() => const DashboardState();

  Future<void> loadUserProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(loading: false, user: user);
    } on Exception catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}