import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../models/dashboard_models.dart';
import '../../data/mock_data.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final userName = user?['fullName'] ?? 'Student';
    final firstName = userName.split(' ').first;
    final coins = user?['coins'] ?? 0;
    final xp = user?['xp'] ?? 0;
    final streak = user?['streak'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _HomeHeader(
            userName: userName,
            firstName: firstName,
            coins: coins,
            xp: xp,
            streak: streak,
          )),

          // ── Streak card ─────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _StreakCard(),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(20)),

          // ── Continue Learning ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Continue Learning',
                      style: AppTextStyles.title.copyWith(fontSize: 18)),
                  Text(
                    'View All',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(12)),

          SliverToBoxAdapter(
            child: _ContinueLearningCard(subject: const SubjectModel(
              id: 'math',
              name: 'Mathematics',
              icon: Icons.functions_rounded,
              color: Color(0xFF2563EB),
              currentTopic: 'Algebra • Linear Equations',
              progress: 0.72,
            )),
          ),

          const SliverToBoxAdapter(child: Gap(24)),

          // ── Subjects ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subjects',
                      style: AppTextStyles.title.copyWith(fontSize: 18)),
                  Text(
                    'View All',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(12)),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 96,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: mockSubjects.length,
                itemBuilder: (context, index) {
                  final s = mockSubjects[index];
                  return _SubjectChip(subject: s);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(24)),

          // ── Today's Goal ─────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _TodayGoalCard(),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(100)),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String userName;
  final String firstName;
  final int coins;
  final int xp;
  final int streak;

  const _HomeHeader({
    required this.userName,
    required this.firstName,
    required this.coins,
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $firstName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to study today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_rounded,
                            color: Colors.white, size: 22),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        userName.split(' ').map((e) => e[0]).take(2).join(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Chips row
              Row(
                children: [
                  _HeaderChip(
                    icon: Icons.monetization_on_rounded,
                    label: '$coins',
                    color: const Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 10),
                  _HeaderChip(
                    icon: Icons.star_rounded,
                    label: '$xp XP',
                    color: const Color(0xFF34D399),
                  ),
                  const SizedBox(width: 10),
                  _HeaderChip(
                    icon: Icons.local_fire_department_rounded,
                    label: '$streak Day Streak',
                    color: const Color(0xFFFB923C),
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

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak Card ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
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
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFFB923C), size: 20),
                const SizedBox(width: 6),
                Text(
                  '7 Day Streak',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'Keep it up! You\'re doing great.',
                  style: AppTextStyles.body.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: mockStreakDays.map((entry) {
                final (day, done) = entry;
                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.primary
                            : AppColors.subtitle.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        done
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        color: done
                            ? Colors.white
                            : AppColors.subtitle.withOpacity(0.4),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: done
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: done ? AppColors.text : AppColors.subtitle,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Continue Learning Card ────────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  final SubjectModel subject;

  const _ContinueLearningCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(subject.icon, color: subject.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subject.currentTopic,
                    style: AppTextStyles.body.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: subject.progress,
                      backgroundColor: AppColors.subtitle.withOpacity(0.15),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(subject.color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(subject.progress * 100).toInt()}% complete',
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: subject.color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subject Chip ─────────────────────────────────────────────────────────────

class _SubjectChip extends StatelessWidget {
  final SubjectModel subject;

  const _SubjectChip({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: subject.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(subject.icon, color: subject.color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            subject.name,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Today's Goal Card ────────────────────────────────────────────────────────

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard();

  @override
  Widget build(BuildContext context) {
    const answered = 16;
    const total = 20;
    const progress = answered / total;

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
                'Today\'s Goal',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontSize: 15,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.subtitle.withOpacity(0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Answer $total questions  •  $answered / $total done',
            style: AppTextStyles.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}