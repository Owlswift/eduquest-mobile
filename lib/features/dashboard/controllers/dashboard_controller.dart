import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  DashboardState build() => const DashboardState();

  Future<void> loadUserProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _authService.getProfile();
      state = state.copyWith(loading: false, user: user);
    } on Exception catch (e) {
      // If API fails, try to get user data from currently signed-in Google user
      try {
        // Initialize Google Sign-In to ensure currentUser is available
        await _googleSignIn.initialize(
          serverClientId: '108767173452-hdfi3kjhutv37somf60r50keo9kj66ju.apps.googleusercontent.com',
        );
        
        final googleUser = _googleSignIn.currentUser;
        
        if (googleUser != null) {
          // Create a minimal user profile from Google data
          final fallbackUser = {
            'fullName': googleUser.displayName ?? 'User',
            'email': googleUser.email,
            'coins': 0,
            'xp': 0,
            'streak': 0,
          };
          state = state.copyWith(loading: false, user: fallbackUser);
        } else {
          state = state.copyWith(loading: false, error: e.toString());
        }
      } catch (googleError) {
        // Both API and Google fallback failed
        state = state.copyWith(loading: false, error: e.toString());
      }
    }
  }
}
