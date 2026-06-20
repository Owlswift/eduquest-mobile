import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/routes/routes.dart';
import '../../data/mock_data.dart';
import '../../models/dashboard_models.dart';
import '../../../auth/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ───────────────────────────────────────────────────
          SliverToBoxAdapter(child: _ProfileHeader()),

          // ── Stats Row ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _StatsRow(),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(20)),

          // ── Badges preview ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _BadgesPreview(),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(20)),

          // ── Study Progress ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StudyProgressCard(),
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
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
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
                    color: Colors.white.withOpacity(0.2),
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
                        mockUser.name
                            .split(' ')
                            .map((e) => e[0].toUpperCase())
                            .take(2)
                            .join(),
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
                      'Lv ${mockUser.level}',
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
                mockUser.name
                    .split(' ')
                    .map((e) => e[0].toUpperCase() + e.substring(1))
                    .join(' '),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Gap(2),
              Text(
                mockUser.username,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),

              const Gap(14),

              // XP progress bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${mockUser.xp} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${mockUser.maxXp} XP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: mockUser.xpProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
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
              value: '${mockUser.coins}',
              label: 'Coins',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFFFBBF24),
            ),
            _Divider(),
            _StatItem(
              value: '${mockUser.badges}',
              label: 'Badges',
              icon: Icons.military_tech_rounded,
              color: AppColors.primary,
            ),
            _Divider(),
            _StatItem(
              value: '${mockUser.certificates}',
              label: 'Certificates',
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFF059669),
            ),
            _Divider(),
            _StatItem(
              value: '${mockUser.streak}',
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
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: AppColors.subtitle.withOpacity(0.15));
  }
}

// ─── Badges Preview ───────────────────────────────────────────────────────────

class _BadgesPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final earned =
        mockBadges.where((b) => b.status == BadgeStatus.earned).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Badges',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontSize: 15,
                ),
              ),
              Text(
                '${earned.length}/${mockBadges.length} earned',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Gap(14),
          Row(
            children: mockBadges.take(5).map((badge) {
              final isEarned = badge.status == BadgeStatus.earned;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? badge.color.withOpacity(0.12)
                            : AppColors.subtitle.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge.icon,
                        color: isEarned
                            ? badge.color
                            : AppColors.subtitle.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      badge.title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 10,
                        color: isEarned
                            ? AppColors.text
                            : AppColors.subtitle.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Study Progress ───────────────────────────────────────────────────────────

class _StudyProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Study Progress',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Month',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Gap(16),

          // Top stats
          Row(
            children: [
              _MiniStat(
                label: 'Questions Answered',
                value: '${mockUser.questionsAnswered}',
                color: AppColors.primary,
              ),
              _MiniStat(
                label: 'Accuracy',
                value: '${(mockUser.accuracy * 100).toInt()}%',
                color: const Color(0xFF059669),
              ),
              _MiniStat(
                label: 'Time Spent',
                value: mockUser.timeSpent,
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

          ...mockSubjectProgress.map((sp) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sp.subject,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${(sp.progress * 100).toInt()}%',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sp.color,
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: sp.progress,
                        backgroundColor:
                            AppColors.subtitle.withOpacity(0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(sp.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              )),
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
                      color: color.withOpacity(0.12),
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
                      : () {},
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.subtitle.withOpacity(0.1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}