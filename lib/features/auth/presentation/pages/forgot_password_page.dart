import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/routes/routes.dart';

// Local state for forgot password (not part of AuthController)
final _forgotLoadingProvider = StateProvider<bool>((ref) => false);
final _forgotSuccessProvider = StateProvider<bool>((ref) => false);
final _forgotErrorProvider = StateProvider<String?>((ref) => null);

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    ref.read(_forgotLoadingProvider.notifier).state = true;
    ref.read(_forgotErrorProvider.notifier).state = null;

    // Simulate API call — replace with real service call
    await Future.delayed(const Duration(seconds: 2));

    ref.read(_forgotLoadingProvider.notifier).state = false;
    ref.read(_forgotSuccessProvider.notifier).state = true;

    if (mounted) {
      context.push(
        '${AppRoutes.otpVerification}?email=${Uri.encodeComponent(email)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(_forgotLoadingProvider);
    final success = ref.watch(_forgotSuccessProvider);
    final error = ref.watch(_forgotErrorProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(8),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.text,
                padding: EdgeInsets.zero,
              ),
            ),

            const Gap(8),

            Lottie.asset(
              'assets/animations/auth_forgot.json',
              height: 200,
              fit: BoxFit.contain,
            ),

            const Gap(24),

            Text(
              'Forgot Password?',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),

            const Gap(8),

            Text(
              'No worries! Enter your email and\nwe\'ll send you a reset link.',
              style: AppTextStyles.body.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const Gap(32),

            AppTextField(
              hint: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.subtitle,
              ),
            ),

            const Gap(16),

            if (success) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 18),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Reset link sent! Check your inbox.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
            ],

            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ),
              const Gap(16),
            ],

            PrimaryButton(
              text: 'Send Reset Link',
              icon: Icons.send_rounded,
              loading: loading,
              onPressed: _handleSendLink,
            ),

            const Gap(20),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OR',
                      style: AppTextStyles.body.copyWith(fontSize: 13)),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const Gap(20),

            GestureDetector(
              onTap: () => context.go(AppRoutes.login),
              child: Text(
                'Back to Login',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}