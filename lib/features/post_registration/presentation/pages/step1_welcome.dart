import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../providers/post_registration_notifier.dart';

class Step1Welcome extends ConsumerWidget {
  const Step1Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Step counter and progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Step 1 of 6',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 1 / 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2563EB)),
              minHeight: 4,
            ),
          ),

          const Gap(24),

          // Title - left aligned
          const Text(
            'Welcome to',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),

          const Gap(8),

          // EduQuest with emoji - left aligned
          Row(
            children: [
              const Text(
                'EduQuest',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🎉',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.2,
                ),
              ),
            ],
          ),

          const Gap(12),

          // Subtitle - left aligned
          const Text(
            "Let's set up your competition profile\nand get you started.",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),

          const Gap(24),

          // Large Illustration
          Image.asset(
            'assets/illustrations/post_registration_screen1.png',
            height: 280,
            fit: BoxFit.contain,
          ),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () =>
                  ref.read(postRegProvider.notifier).nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  final Color color;
  const _ConfettiDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
