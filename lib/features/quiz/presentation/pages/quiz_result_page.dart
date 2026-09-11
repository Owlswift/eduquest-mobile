import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';

class QuizResultPage extends StatelessWidget {
  final String subjectName;
  final int totalQuestions;
  final int correctAnswers;
  final int earnedCoins;
  final int earnedXp;

  const QuizResultPage({
    super.key,
    required this.subjectName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.earnedCoins,
    required this.earnedXp,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100).round();
    final good = percent >= 70;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: (good ? AppColors.success : AppColors.warning).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  good ? Icons.emoji_events_rounded : Icons.school_rounded,
                  color: good ? AppColors.success : AppColors.warning,
                  size: 48,
                ),
              ),
              const Gap(20),
              Text(
                good ? 'Great job!' : 'Quiz Complete',
                style: AppTextStyles.title.copyWith(fontSize: 24),
              ),
              const Gap(6),
              Text(
                '$subjectName · $correctAnswers of $totalQuestions correct ($percent%)',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
              ),
              const Gap(28),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.monetization_on_rounded,
                      color: const Color(0xFFFBBF24),
                      label: 'Coins earned',
                      value: '+$earnedCoins',
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.bolt_rounded,
                      color: AppColors.primary,
                      label: 'XP earned',
                      value: '+$earnedXp',
                    ),
                  ),
                ],
              ),
              const Gap(32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Gap(10),
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          const Gap(2),
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
