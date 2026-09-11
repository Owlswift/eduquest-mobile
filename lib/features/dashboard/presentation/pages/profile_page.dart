import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/routes/routes.dart';
import '../../controllers/subject_progress_provider.dart';
import '../../controllers/subjects_provider.dart';
import '../../controllers/user_profile_provider.dart';
import '../../models/subject_progress_entry.dart';
import '../../models/user_profile.dart';
import '../../../auth/controllers/auth_controller.dart';
import 'rewards_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull ?? UserProfile.empty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(subjectProgressProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Profile Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _ProfileHeader(profile: profile)),

            // ── Stats Row ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _StatsRow(profile: profile),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(20)),

            // ── Study Progress ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StudyProgressCard(profile: profile),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(20)),

            // ── Menu items ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProfileMenu(),
              ),
            ),

            const SliverToBoxAdapter(child: Gap(100)),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              // Settings icon
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings_rounded,
                      color: Colors.white, size: 20),
                ),
              ),

              const Gap(12),

              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Lv ${profile.level}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(12),

              Text(
                profile.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Gap(2),
              Text(
                profile.username.isEmpty ? '' : '@${profile.username}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
              ),

              const Gap(14),

              // XP progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${profile.xp} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${profile.maxXp} XP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: profile.levelProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFBBF24)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UserProfile profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            _StatItem(
              value: '${profile.coins}',
              label: 'Coins',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFFFBBF24),
            ),
            const _Divider(),
            _StatItem(
              value: '${profile.badges}',
              label: 'Badges',
              icon: Icons.military_tech_rounded,
              color: AppColors.primary,
            ),
            const _Divider(),
            _StatItem(
              value: '${profile.certificates}',
              label: 'Certificates',
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFF059669),
            ),
            const _Divider(),
            _StatItem(
              value: '${profile.streak}',
              label: 'Streak',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFFB923C),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const Gap(4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1,
        height: 40,
        color: AppColors.subtitle.withValues(alpha: 0.15));
  }
}

// ─── Study Progress ───────────────────────────────────────────────────────────

class _StudyProgressCard extends ConsumerWidget {
  final UserProfile profile;
  const _StudyProgressCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectProgress = ref.watch(subjectProgressProvider).valueOrNull;
    final colorsById = {
      for (final s in ref.watch(subjectsProvider).valueOrNull ?? const [])
        s.id: s.color,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Progress',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              fontSize: 15,
            ),
          ),

          const Gap(16),

          // Top stats
          Row(
            children: [
              _MiniStat(
                label: 'Questions Answered',
                value: '${profile.questionsAnswered}',
                color: AppColors.primary,
              ),
              _MiniStat(
                label: 'Accuracy',
                value: '${(profile.accuracy * 100).toInt()}%',
                color: const Color(0xFF059669),
              ),
              _MiniStat(
                label: 'Time Spent',
                value: profile.timeSpentLabel,
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),

          const Gap(20),

          Text(
            'Subject Performance',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              fontSize: 14,
            ),
          ),

          const Gap(12),

          if (subjectProgress == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (subjectProgress.isEmpty)
            Text(
              'Start a lesson to see your subject progress here.',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.subtitle,
              ),
            )
          else
            ...subjectProgress.map((sp) => _SubjectProgressRow(
                  entry: sp,
                  color: colorsById[sp.subjectId] ?? AppColors.primary,
                )),
        ],
      ),
    );
  }
}

class _SubjectProgressRow extends StatelessWidget {
  final SubjectProgressEntry entry;
  final Color color;
  const _SubjectProgressRow({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.subjectName,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${(entry.progress * 100).toInt()}%',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const Gap(6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: entry.progress,
              backgroundColor: AppColors.subtitle.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Profile Menu ─────────────────────────────────────────────────────────────

class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      (Icons.edit_rounded, 'Edit Profile', AppColors.primary),
      (Icons.bar_chart_rounded, 'My Stats', const Color(0xFF059669)),
      (Icons.card_giftcard_rounded, 'My Rewards', const Color(0xFFF59E0B)),
      (Icons.workspace_premium_rounded, 'My Certificates',
          const Color(0xFF7C3AED)),
      (Icons.settings_rounded, 'Settings', AppColors.subtitle),
      (Icons.logout_rounded, 'Logout', AppColors.danger),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final (icon, label, color) = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.large),
                child: ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: label == 'Logout' ? AppColors.danger : AppColors.text,
                      fontSize: 14,
                    ),
                  ),
                  trailing: label == 'Logout'
                      ? const Icon(
                          Icons.logout_rounded,
                          color: AppColors.danger,
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.subtitle,
                        ),
                  onTap: label == 'Logout'
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => ctx.pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => ctx.pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            await ref.read(authControllerProvider.notifier).logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          }
                        }
                      : label == 'My Rewards'
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RewardsPage(),
                                ),
                              )
                          : () {},
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.subtitle.withValues(alpha: 0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
