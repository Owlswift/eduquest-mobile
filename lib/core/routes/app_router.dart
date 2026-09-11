import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/new_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_shell.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/post_registration/presentation/pages/post_registration_flow.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'routes.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return NewPasswordPage(resetToken: token);
        },
      ),
      GoRoute(
        path: AppRoutes.postRegistration,
        builder: (context, state) => const PostRegistrationFlow(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DashboardShell(),
      ),
    ],
  );
}