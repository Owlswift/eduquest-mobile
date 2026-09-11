import 'dart:async';

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

final _otpLoadingProvider = StateProvider<bool>((ref) => false);
final _otpErrorProvider = StateProvider<String?>((ref) => null);

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  Future<void> _handleVerify() async {
    if (_otp.length < 6) return;
    ref.read(_otpLoadingProvider.notifier).state = true;
    ref.read(_otpErrorProvider.notifier).state = null;

    try {
      final resetToken = await AuthService().verifyOtp(widget.email, _otp);
      ref.read(_otpLoadingProvider.notifier).state = false;
      if (mounted) {
        context.go(
          '${AppRoutes.newPassword}?token=${Uri.encodeComponent(resetToken)}',
        );
      }
    } on DioException catch (e) {
      ref.read(_otpLoadingProvider.notifier).state = false;
      final message = (e.response?.data is Map)
          ? (e.response?.data['message']?.toString())
          : null;
      ref.read(_otpErrorProvider.notifier).state = message ?? 'Invalid or expired code.';
      for (final c in _controllers) c.clear();
      if (_controllers.isNotEmpty) _focusNodes.first.requestFocus();
      setState(() {});
    } catch (_) {
      ref.read(_otpLoadingProvider.notifier).state = false;
      ref.read(_otpErrorProvider.notifier).state = "Couldn't verify right now - try again.";
    }
  }

  Future<void> _handleResend() async {
    if (_resendSeconds > 0) return;
    try {
      await AuthService().forgotPassword(widget.email);
    } catch (_) {
      // Best-effort - the resend cooldown UI still restarts below, and if
      // this silently failed the user can just tap Resend again once the
      // timer clears.
    }
    if (mounted) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(_otpLoadingProvider);
    final error = ref.watch(_otpErrorProvider);
    final maskedEmail = _maskEmail(widget.email);

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
              'assets/animations/auth_otp.json',
              height: 200,
              fit: BoxFit.contain,
            ),

            const Gap(24),

            Text(
              'Verify Your Email',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),

            const Gap(8),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.body.copyWith(fontSize: 14),
                children: [
                  const TextSpan(text: 'We sent a 6-digit code to\n'),
                  TextSpan(
                    text: maskedEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            const Gap(36),

            // OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _OtpBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (v) => _onDigitEntered(index, v),
                  onBackspace: () => _onBackspace(index),
                );
              }),
            ),

            const Gap(32),

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
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(16),
            ],

            PrimaryButton(
              text: 'Verify Code',
              icon: Icons.verified_rounded,
              loading: loading,
              onPressed: _otp.length == 6 ? _handleVerify : null,
            ),

            const Gap(20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
                _resendSeconds > 0
                    ? Text(
                        'Resend (${_resendSeconds}s)',
                        style: AppTextStyles.body
                            .copyWith(fontSize: 14, color: AppColors.subtitle),
                      )
                    : GestureDetector(
                        onTap: _handleResend,
                        child: Text(
                          'Resend',
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

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length > 2 ? name.substring(0, 2) : name[0];
    return '$visible****@${parts[1]}';
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event.character == null && controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.title.copyWith(fontSize: 22),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.subtitle.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.subtitle.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}