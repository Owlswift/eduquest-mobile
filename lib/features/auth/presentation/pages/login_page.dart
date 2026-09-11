import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/animations/floating_bubble.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/common/decorative_background.dart';
import '../../../../core/routes/routes.dart';
import '../../controllers/auth_controller.dart';

/// EduQuest "EQ" mark - graduation-cap Q + block E. Inlined so the login
/// screen has no external asset dependency.
const _brandMarkSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 366 322">
  <path d="M21 101 H150 C152 101 153 103 153 105 V131 C153 133 152 134 150 134 H53 V174 H132 C134 174 135 176 135 178 V204 C135 206 134 207 132 207 H53 V248 H150 C152 248 153 250 153 252 V278 C153 280 152 282 150 282 H21 C19 282 18 280 18 278 V105 C18 103 19 101 21 101 Z" fill="#1557E8"/>
  <path fill="#1557E8" fill-rule="evenodd" d="M235 98 C185 98 145 138 145 190 C145 242 184 282 235 282 C286 282 325 242 325 190 C325 138 286 98 235 98 Z M235 133 C268 133 291 157 291 190 C291 224 268 247 235 247 C202 247 179 224 179 190 C179 157 202 133 235 133 Z"/>
  <path d="M221 204 H259 L331 282 C332 284 331 286 328 287 H295 C293 287 291 286 290 285 L221 211 C219 208 220 206 221 204 Z" fill="#FFB900"/>
  <path d="M187 64 L258 45 C260 45 262 45 264 46 L331 78 C334 79 334 82 331 83 L263 101 C261 102 259 102 257 101 L188 70 C185 69 185 66 187 64 Z" fill="#1557E8"/>
  <path d="M213 76 L295 91 V99 C295 102 293 104 290 103 L267 98 C265 98 263 99 263 101 V106 H214 V88 C214 84 213 80 213 76 Z" fill="#1557E8"/>
  <path d="M321 82 H327 V119 C327 121 326 122 325 122 H323 C322 122 321 121 321 119 Z" fill="#FFB900"/>
  <path d="M320 119 H328 V130 C328 133 326 135 324 135 C321 135 319 133 319 130 V122 C319 120 320 119 320 119 Z" fill="#FFB900"/>
</svg>
''';

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

    await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

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
    final isExistingUser = await ref
        .read(authControllerProvider.notifier)
        .googleLogin();

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
      // If user exists in DB, go straight to dashboard
      // If user is new, go to post-registration flow
      if (isExistingUser) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.postRegistration);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppScaffold(
      body: Stack(
        children: [
          // Decorative background — layered (3D) depth that matches the
          // onboarding screen's visual style.
          DecorativeBackground(
            color: AppColors.primary.withValues(alpha: 0.06),
          ),

          // Floating bubbles around the animation area.
          Positioned(
            top: 20,
            right: 36,
            child: FloatingBubble(
              icon: Icons.star_rounded,
              color: Colors.orange,
              phase: 0,
            ),
          ),
          Positioned(
            top: 120,
            left: 22,
            child: FloatingBubble(
              icon: Icons.lightbulb_rounded,
              color: Colors.amber,
              phase: 0.4,
            ),
          ),
          Positioned(
            top: 185,
            right: 18,
            child: FloatingBubble(
              icon: Icons.school_rounded,
              color: AppColors.primary,
              phase: 0.8,
            ),
          ),

          // Scrollable form content (sits above the decorative layers).
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(16),

                    // ── Brand mark ──────────────────────────────────────────────────
                    SvgPicture.string(
                      _brandMarkSvg,
                      height: 150,
                      fit: BoxFit.contain,
                    ),

                    const Gap(8),

                    // ── Brand ───────────────────────────────────────────────────────
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
                      child: Text(
                        'Welcome Back! 👋',
                        style: AppTextStyles.title,
                      ),
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
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.subtitle,
                        ),
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
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.subtitle,
                        ),
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
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 18,
                            ),
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: auth.loading ? null : _handleLogin,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login',
                                      style: AppTextStyles.button.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
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
                          child: Text(
                            'OR',
                            style: AppTextStyles.body.copyWith(fontSize: 13),
                          ),
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
                        onPressed: auth.googleLoading
                            ? null
                            : _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.subtitle.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(
                            alpha: 0.20,
                          ),
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
                                      fontWeight: FontWeight.w700,
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
          ),
        ],
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
    Canvas canvas,
    Rect rect,
    double startDeg,
    double sweepDeg,
    Color color,
  ) {
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
