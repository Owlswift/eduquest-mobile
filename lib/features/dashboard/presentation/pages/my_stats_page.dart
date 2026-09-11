import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../controllers/leaderboard_provider.dart';
import '../../controllers/subject_progress_provider.dart';
import '../../controllers/subjects_provider.dart';
import '../../controllers/user_profile_provider.dart';
import '../../models/dashboard_models.dart';

/// A fuller breakdown of the student's progress than the Profile tab's
/// compact stats row - all sourced from data already fetched elsewhere
/// (no new backend endpoint needed).
class MyStatsPage extends ConsumerWidget {
  const MyStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final subjectProgress = ref.watch(subjectProgressProvider).valueOrNull ?? const [];
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? const <SubjectModel>[];
    final leaderboard = ref.watch(leaderboardProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'My Stats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userProfileProvider);
                ref.invalidate(subjectProgressProvider);
                ref.invalidate(leaderboardProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // XP / level card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Level ${profile.level}',
                                style: AppTextStyles.title.copyWith(fontSize: 18)),
                            if (leaderboard?.me != null)
                              Text('Rank #${leaderboard!.me!.rank}',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const Gap(10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: profile.levelProgress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFEDF0F4),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const Gap(6),
                        Text('${profile.xp} / ${profile.maxXp} XP',
                            style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // Core stat grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _StatTile(icon: Icons.monetization_on_rounded, color: const Color(0xFFFBBF24),
                          label: 'Coins', value: '${profile.coins}'),
                      _StatTile(icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF7C00),
                          label: 'Streak', value: '${profile.streak} days'),
                      _StatTile(icon: Icons.military_tech_rounded, color: const Color(0xFF7C3AED),
                          label: 'Badges', value: '${profile.badges}'),
                      _StatTile(icon: Icons.workspace_premium_rounded, color: const Color(0xFF059669),
                          label: 'Certificates', value: '${profile.certificates}'),
                      _StatTile(icon: Icons.quiz_rounded, color: const Color(0xFF2563EB),
                          label: 'Questions', value: '${profile.questionsAnswered}'),
                      _StatTile(icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A),
                          label: 'Accuracy', value: '${(profile.accuracy * 100).round()}%'),
                    ],
                  ),
                  const Gap(24),

                  Text('Subject Mastery', style: AppTextStyles.title.copyWith(fontSize: 17)),
                  const Gap(12),
                  if (subjectProgress.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        boxShadow: AppShadows.card,
                      ),
                      child: Text(
                        "You haven't studied with the AI Tutor yet - mastery per "
                        "subject will show up here once you do.",
                        style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 13),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: subjectProgress.map((s) {
                          final matches = subjects.where((sub) => sub.id == s.subjectId);
                          final color = matches.isEmpty ? AppColors.primary : matches.first.color;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(s.subjectName,
                                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('${(s.progress * 100).round()}%',
                                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ],
                                ),
                                const Gap(6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: s.progress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFEDF0F4),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const Gap(24),
                ],
              ),
            ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const Gap(8),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 17)),
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 11)),
        ],
      ),
    );
  }
}
