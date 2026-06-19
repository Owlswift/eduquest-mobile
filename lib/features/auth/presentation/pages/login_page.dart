import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/routes/routes.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    final auth = ref.read(authControllerProvider);
    if (auth.token != null && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(16),

            // Lottie animation
            Lottie.asset(
              'assets/animations/auth_login.json',
              height: 200,
              fit: BoxFit.contain,
            ),

            const Gap(8),

            // Brand name
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Edu',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  TextSpan(
                    text: 'Quest',
                    style: AppTextStyles.headline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const Gap(4),

            Text(
              'Learn • Practice • Succeed',
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),

            const Gap(32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Welcome Back! 👋', style: AppTextStyles.title),
            ),

            const Gap(4),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Login to continue your learning journey.',
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),

            const Gap(28),

            AppTextField(
              hint: 'Email or Username',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColors.subtitle,
              ),
            ),

            const Gap(16),

            PasswordField(controller: _passwordController),

            const Gap(12),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.forgotPassword),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const Gap(24),

            // Error message
            if (auth.error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  auth.error!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ),
              const Gap(16),
            ],

            PrimaryButton(
              text: 'Login',
              icon: Icons.arrow_forward_rounded,
              loading: auth.loading,
              onPressed: _handleLogin,
            ),

            const Gap(20),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const Gap(20),

            SecondaryButton(
              text: 'Continue with Google',
              onPressed: () {},
            ),

            const Gap(28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.register),
                  child: Text(
                    'Create Account',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}