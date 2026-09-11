import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // A ConsumerWidget's build() re-runs on every rebuild (e.g. the router
    // rebuilding this route), which used to schedule a fresh Future.delayed
    // each time - stale timers could then fire ref.read() after this widget
    // had already navigated away and been disposed. initState() runs once,
    // and the mounted check below guards the one case that still matters:
    // the app being backgrounded/torn down during the delay.
    Future.delayed(
      const Duration(seconds: AppConstants.splashDuration),
      () async {
        if (!mounted) return;
        // Storage is the source of truth for "is there a session"; the
        // auth provider populates it asynchronously and could still be
        // mid-flight here.
        final token = ref.read(authControllerProvider).token ??
            await TokenStorage().getToken();
        if (!mounted) return;
        context.go(token != null ? '/home' : '/onboarding');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 40),

                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: 'Edu',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Quest',
                        style: TextStyle(color: Color(0xFFFBBF24)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Learn • Practice • Succeed",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 80),

                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Preparing your learning journey...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
