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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Email Login ────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (auth.token != null) {
      context.go(AppRoutes.home);
    }
  }

  // ─── Google Login ───────────────────────────────────────────────────────────

  Future<void> _handleGoogleLogin() async {
    await ref.read(authControllerProvider.notifier).googleLogin();

    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    if (auth.token != null) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(16),

              // ── Lottie ──────────────────────────────────────────────────────
              Lottie.asset(
                'assets/animations/auth_login.json',
                height: 180,
                fit: BoxFit.contain,
              ),

              const Gap(8),

              // ── Brand ───────────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Edu',
                      style: AppTextStyles.headline
                          .copyWith(color: AppColors.text),
                    ),
                    TextSpan(
                      text: 'Quest',
                      style: AppTextStyles.headline
                          .copyWith(color: AppColors.primary),
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
                child:
                    Text('Welcome Back! 👋', style: AppTextStyles.title),
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

               // ── Email/Username ───────────────────────────────────────────────
               TextFormField(
                 controller: _emailController,
                 keyboardType: TextInputType.emailAddress,
                 decoration: InputDecoration(
                   hintText: 'Email or Username',
                   prefixIcon: const Icon(Icons.email_outlined,
                       color: AppColors.subtitle),
                 ),
                 validator: (v) {
                   if (v == null || v.trim().isEmpty) {
                     return 'Please enter your email or username';
                   }
                   return null;
                 },
               ),

              const Gap(16),

              // ── Password ────────────────────────────────────────────────────
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.subtitle),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const Gap(12),

              // ── Forgot password ─────────────────────────────────────────────
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

              // ── Error banner ────────────────────────────────────────────────
              if (auth.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.danger.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.error!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],

              // ── Login button ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: auth.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: AppTextStyles.button
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 20),
                          ],
                        ),
                ),
              ),

              const Gap(20),

              // ── OR divider ──────────────────────────────────────────────────
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

              // ── Google button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed:
                      auth.googleLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.subtitle.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: auth.googleLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google 'G' logo using colored text
                            const _GoogleLogo(),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const Gap(28),

              // ── Register link ───────────────────────────────────────────────
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
      ),
    );
  }
}

// ─── Google Logo Widget ───────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Blue segment
    _drawArc(canvas, rect, -10, 90, const Color(0xFF4285F4));
    // Red segment
    _drawArc(canvas, rect, 80, 90, const Color(0xFFEA4335));
    // Yellow segment
    _drawArc(canvas, rect, 170, 90, const Color(0xFFFBBC05));
    // Green segment
    _drawArc(canvas, rect, 260, 90, const Color(0xFF34A853));

    // White center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.3,
      Paint()..color = Colors.white,
    );

    // Blue 'G' bar
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2,
        size.height * 0.35,
        size.width * 0.45,
        size.height * 0.3,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  void _drawArc(
      Canvas canvas, Rect rect, double startDeg, double sweepDeg, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(rect.center.dx, rect.center.dy)
      ..arcTo(
        rect,
        startDeg * (3.14159265 / 180),
        sweepDeg * (3.14159265 / 180),
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}