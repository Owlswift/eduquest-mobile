import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/responsive.dart';
import '../../controllers/daily_summary_provider.dart';
import '../../controllers/leaderboard_provider.dart';
import '../../controllers/subjects_provider.dart';
import '../../controllers/user_profile_provider.dart';
import '../../models/leaderboard.dart';
import '../../../tutor/presentation/pages/tutor_topics_page.dart';
import 'competitions_page.dart';
import 'leaderboard_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = context.isTablet ? 40.0 : 20.0;
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(userProfileProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const _DashboardHeader(),
              const SizedBox(height: 20),
              const _LevelCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      iconAsset: 'assets/illustrations/xp_coin.png',
                      label: '⭐ XP Earned',
                      value: '${profile?.xp ?? 0}',
                      subtitle: 'Keep it growing',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      iconAsset: 'assets/illustrations/gold_coin.png',
                      label: '🪙 Coins',
                      value: '${profile?.coins ?? 0}',
                      subtitle: 'Ready to spend',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _ArenaBanner(),
              const SizedBox(height: 20),
              const _RecommendedSection(),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(flex: 5, child: _TodayChallengeCard()),
                    SizedBox(width: 12),
                    Expanded(flex: 6, child: _LeaderboardCard()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _RewardsProgressCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final name = profile?.firstName ?? '';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()} 👋',
                style: TextStyle(
                  fontSize: context.rs(16),
                  color: const Color(0xff6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name.isEmpty ? '—' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(36),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff0F172A),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: context.isTablet ? 56 : 48,
          height: context.isTablet ? 56 : 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black12,
              ),
            ],
          ),
          child: Icon(Icons.notifications_none_rounded,
              size: context.isTablet ? 28 : 24),
        ),

        const SizedBox(width: 12),

        CircleAvatar(
          radius: context.isTablet ? 30 : 26,
          backgroundImage:
              const AssetImage('assets/illustrations/avatar_student.png'),
        ),
      ],
    );
  }
}

// ─── Level Card ────────────────────────────────────────────────────────────────

const _levelTitles = {
  1: 'Explorer',
  2: 'Scholar',
  3: 'Achiever',
  4: 'Champion',
  5: 'Legend',
};

class _LevelCard extends ConsumerWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final maxXp = profile?.maxXp ?? 500;
    final title = _levelTitles[level] ?? 'Level $level';
    final blurb = level <= 1
        ? "You've completed your first challenge and joined the academy."
        : 'Keep learning to climb to the next level.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEEF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffD7E8FF),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/illustrations/level1_badge.png',
                width: context.isTablet ? 90 : 75,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level • $title',
                      style: TextStyle(
                        fontSize: context.rs(18),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      blurb,
                      style: TextStyle(fontSize: context.rs(13)),
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/illustrations/school_bag.png',
                width: context.isTablet ? 100 : 85,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'Progress to Level ${level + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: context.rs(14),
                ),
              ),
              const Spacer(),
              Text(
                '$xp / $maxXp XP',
                style: TextStyle(
                  color: const Color(0xff2563EB),
                  fontWeight: FontWeight.w800,
                  fontSize: context.rs(14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: maxXp <= 0 ? 0 : (xp / maxXp).clamp(0.0, 1.0),
              minHeight: context.isTablet ? 14 : 12,
              backgroundColor: Colors.white,
              color: const Color(0xff2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card (XP / Coins) ─────────────────────────────────────────────────────
// Sized to stay legible in a 2-up Row down to a 375pt-wide screen (iPhone SE).

class _StatCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: context.isTablet ? 48 : 40,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.rs(13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.rs(26),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.rs(12),
                    color: const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Arena Banner ──────────────────────────────────────────────────────────────

class _ArenaBanner extends StatelessWidget {
  const _ArenaBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Sized by content (no fixed height) so the description always has
      // room to render regardless of font-scale factor or screen size.
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xff0F5DFF),
            Color(0xff0047D9),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/illustrations/crossed_swords.png',
                  width: context.isTablet ? 58 : 50,
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter the Arena',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rs(24),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Compete with other students and win XP, coins, airtime, scholarships and devices.',
                  style: TextStyle(
                      color: Colors.white, fontSize: context.rs(13)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: context.isTablet ? 48 : 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CompetitionsPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff0047D9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Choose Arena',
                      style: TextStyle(
                        fontSize: context.rs(15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            'assets/illustrations/trophy.png',
            // trophy.png is a tall asset (~752x1395) - constrain by height,
            // not width, so it doesn't overflow this banner's fixed height.
            height: context.isTablet ? 140 : 120,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ======================================================
// RECOMMENDED SUBJECTS
// ======================================================

class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(subjectsProvider).valueOrNull ?? const [];
    final enrolled = ref.watch(userProfileProvider).valueOrNull?.subjects ?? const [];

    // Prefer the student's enrolled subjects, in the catalogue's order;
    // fall back to the whole catalogue if we don't know their enrolment.
    final enrolledSet = enrolled.toSet();
    var subjects = all.where((s) => enrolledSet.contains(s.id)).toList();
    if (subjects.isEmpty) subjects = all;
    subjects = subjects.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recommended',
              style: TextStyle(
                fontSize: context.rs(20),
                fontWeight: FontWeight.w800,
                color: const Color(0xff0F172A),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TutorTopicsPage()),
              ),
              child: Text(
                'See all',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff2563EB),
                  fontSize: context.rs(14),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: context.isTablet ? 112 : 100,
          child: subjects.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final s = subjects[i];
                    return _SubjectCard(
                      icon: s.icon,
                      title: s.name,
                      subtitle: 'Tap to learn',
                      bgColor: s.color.withValues(alpha: 0.10),
                      iconColor: s.color,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TutorTopicsPage(initialSubjectName: s.name),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SubjectCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: context.isTablet ? 160 : 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: context.isTablet ? 54 : 48,
              height: context.isTablet ? 54 : 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: context.isTablet ? 30 : 26,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: context.rs(14),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.rs(11),
                      color: const Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// TODAY'S CHALLENGE
// ======================================================

class _TodayChallengeCard extends ConsumerWidget {
  const _TodayChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySummaryProvider).valueOrNull;
    final target = summary?.goalTarget ?? 20;
    final answered = summary?.goalAnswered ?? 0;
    final remaining = (target - answered).clamp(0, target);
    final done = remaining == 0;
    final progress = target <= 0 ? 0.0 : (answered / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFFF9EC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/illustrations/today_target.png',
            width: context.isTablet ? 28 : 24,
            height: context.isTablet ? 28 : 24,
          ),

          const SizedBox(height: 8),

          Text(
            "Today's Challenge",
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: context.rs(15),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            done
                ? "Nice - today's goal is done. Keep the streak going!"
                : 'Answer $remaining more question${remaining == 1 ? '' : 's'} to hit today’s goal.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xff64748B),
              fontSize: context.rs(12),
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xffF59E0B)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$answered / $target',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: context.rs(11),
              color: const Color(0xff92400E),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: context.isTablet ? 46 : 42,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TutorTopicsPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                done ? 'Keep Learning' : 'Start a Lesson',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// LEADERBOARD
// ======================================================

const _medals = ['🥇', '🥈', '🥉'];

class _LeaderboardCard extends ConsumerWidget {
  const _LeaderboardCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(leaderboardProvider).valueOrNull;
    final top = data?.top.take(3).toList() ?? const <LeaderboardEntry>[];
    final me = data?.me;
    // Only show the "You" row when the student isn't already in the top 3.
    final showMeRow =
        me != null && !top.any((e) => e.isMe);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFBF7FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leaderboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: context.rs(15),
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff2563EB),
                    fontSize: context.rs(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No rankings yet.',
                style: TextStyle(
                  fontSize: context.rs(12),
                  color: const Color(0xff94A3B8),
                ),
              ),
            ),
          for (final e in top)
            _leaderRow(context, _medals[e.rank - 1], e.name, '${e.xp} XP',
                highlight: e.isMe),

          if (showMeRow)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xffEDF5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffCFE1FF)),
              ),
              child: _leaderRow(
                context,
                '#${me.rank}',
                'You',
                '${me.xp} XP',
                highlight: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _leaderRow(
    BuildContext context,
    String medal,
    String name,
    String score, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            medal,
            style: TextStyle(fontSize: context.rs(15)),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: context.rs(12),
              ),
            ),
          ),

          const SizedBox(width: 4),

          Text(
            score,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              fontSize: context.rs(11),
              color: highlight
                  ? const Color(0xff2563EB)
                  : const Color(0xff475569),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// REWARD PROGRESS
// ======================================================

class _RewardsProgressCard extends ConsumerWidget {
  const _RewardsProgressCard();

  // Cheapest reward in the catalogue (Airtime, 500 coins) - the next thing
  // the student is working toward.
  static const _nextReward = 'Airtime';
  static const _nextRewardCost = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(userProfileProvider).valueOrNull?.coins ?? 0;
    final progress = (coins / _nextRewardCost).clamp(0.0, 1.0);
    final remaining = (_nextRewardCost - coins).clamp(0, _nextRewardCost);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffECFDF5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎁 Rewards Progress',
            style: TextStyle(
              fontSize: context.rs(18),
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            remaining == 0 ? 'Ready to claim' : 'Next Reward',
            style: TextStyle(
              fontSize: context.rs(14),
              fontWeight: FontWeight.w600,
              color: const Color(0xff16A34A),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _nextReward,
            style: TextStyle(
              fontSize: context.rs(16),
              fontWeight: FontWeight.w700,
              color: const Color(0xff0F172A),
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.isTablet ? 14 : 12,
              backgroundColor: Colors.white,
              color: const Color(0xff16A34A),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$coins / $_nextRewardCost Coins',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: context.rs(14),
                ),
              ),
              if (remaining > 0)
                Text(
                  '$remaining coins away',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.rs(12),
                    color: const Color(0xff16A34A),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
