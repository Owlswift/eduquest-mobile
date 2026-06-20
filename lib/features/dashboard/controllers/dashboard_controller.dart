import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
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
  final AuthService _service = AuthService();

  @override
  DashboardState build() => const DashboardState();

  Future<void> loadUserProfile() async {
    // First check if we already have user data from auth state
    final authState = ref.read(authControllerProvider);
    if (authState.user != null) {
      state = state.copyWith(user: authState.user);
      return;
    }

    if (authState.token == null) {
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _service.getProfile();
      state = state.copyWith(loading: false, user: user);
    } on Exception catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
