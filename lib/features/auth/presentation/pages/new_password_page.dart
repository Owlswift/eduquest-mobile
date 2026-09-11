import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/routes/routes.dart';
import '../../services/auth_service.dart';

final _newPasswordLoadingProvider = StateProvider<bool>((ref) => false);
final _newPasswordErrorProvider = StateProvider<String?>((ref) => null);

/// Last step of the forgot-password flow: set a new password using the
/// short-lived token returned by OtpVerificationPage after a correct code.
class NewPasswordPage extends ConsumerStatefulWidget {
  final String resetToken;

  const NewPasswordPage({super.key, required this.resetToken});

  @override
  ConsumerState<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends ConsumerState<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(_newPasswordLoadingProvider.notifier).state = true;
    ref.read(_newPasswordErrorProvider.notifier).state = null;

    try {
      await AuthService().resetPassword(widget.resetToken, _passwordController.text);
      ref.read(_newPasswordLoadingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset - please log in.')),
        );
        context.go(AppRoutes.login);
      }
    } on DioException catch (e) {
      ref.read(_newPasswordLoadingProvider.notifier).state = false;
      final message = (e.response?.data is Map)
          ? (e.response?.data['message']?.toString())
          : null;
      ref.read(_newPasswordErrorProvider.notifier).state = message ??
          "Couldn't reset your password - your session may have expired, please start again.";
    } catch (_) {
      ref.read(_newPasswordLoadingProvider.notifier).state = false;
      ref.read(_newPasswordErrorProvider.notifier).state =
          "Couldn't reset your password - try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(_newPasswordLoadingProvider);
    final error = ref.watch(_newPasswordErrorProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(8),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.text,
                  padding: EdgeInsets.zero,
                ),
              ),

              const Gap(8),

              Lottie.asset(
                'assets/animations/auth_forgot.json',
                height: 180,
                fit: BoxFit.contain,
              ),

              const Gap(24),

              Text(
                'Set a New Password',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),

              const Gap(8),

              Text(
                'Choose a new password for your account.',
                style: AppTextStyles.body.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const Gap(32),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.subtitle),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a new password';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),

              const Gap(16),

              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.subtitle),
                ),
                validator: (v) {
                  if (v != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const Gap(16),

              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    error,
                    style: AppTextStyles.body.copyWith(color: AppColors.danger, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(16),
              ],

              PrimaryButton(
                text: 'Reset Password',
                icon: Icons.check_circle_outline_rounded,
                loading: loading,
                onPressed: _handleReset,
              ),

              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}
