import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _DashboardHeader(),
              SizedBox(height: 20),
              _LevelCard(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      iconAsset: 'assets/illustrations/xp_coin.png',
                      label: '⭐ XP Earned',
                      value: '100',
                      subtitle: 'Entrance Test',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      iconAsset: 'assets/illustrations/gold_coin.png',
                      label: '🪙 Coins',
                      value: '50',
                      subtitle: 'Ready to spend',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _ArenaBanner(),
              SizedBox(height: 20),
              _RecommendedSection(),
              SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _TodayChallengeCard()),
                    SizedBox(width: 12),
                    Expanded(flex: 6, child: _LeaderboardCard()),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _RewardsProgressCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good Morning 👋',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff6B7280),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ola',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0F172A),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black12,
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 24),
        ),

        const SizedBox(width: 12),

        const CircleAvatar(
          radius: 26,
          backgroundImage:
              AssetImage('assets/illustrations/avatar_student.png'),
        ),
      ],
    );
  }
}

// ─── Level Card ────────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context) {
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
                width: 75,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Level 1 • Explorer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "You've completed your first challenge and joined the academy.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/illustrations/school_bag.png',
                width: 85,
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Text(
                'Progress to Level 2',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Text(
                '100 / 300 XP',
                style: TextStyle(
                  color: Color(0xff2563EB),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.33,
              minHeight: 12,
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
            width: 40,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff64748B),
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
      // The left column's fixed-size content (icon + title + button) alone
      // is ~140px tall before the flexible description/spacer even factor
      // in - 170 wasn't enough room and overflowed by 16px.
      height: 196,
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/illustrations/crossed_swords.png',
                  width: 50,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Enter the Arena',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                const Expanded(
                  child: Text(
                    'Compete with other students and win XP, coins, airtime, scholarships and devices.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff0047D9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Choose Arena',
                      style: TextStyle(
                        fontSize: 15,
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
            height: 120,
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

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recommended',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xff0F172A),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2563EB),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _SubjectCard(
                icon: Icons.calculate_rounded,
                title: 'Mathematics',
                subtitle: 'Based on your test',
                bgColor: Color(0xffEDF5FF),
                iconColor: Color(0xff2563EB),
              ),
              SizedBox(width: 12),
              _SubjectCard(
                icon: Icons.menu_book_rounded,
                title: 'English',
                subtitle: 'Recommended',
                bgColor: Color(0xffF4F0FF),
                iconColor: Color(0xff7C3AED),
              ),
              SizedBox(width: 12),
              _SubjectCard(
                icon: Icons.science_rounded,
                title: 'Physics',
                subtitle: 'Recommended',
                bgColor: Color(0xffEDFDF6),
                iconColor: Color(0xff10B981),
              ),
              SizedBox(width: 12),
              _SubjectCard(
                icon: Icons.biotech_rounded,
                title: 'Chemistry',
                subtitle: 'Recommended',
                bgColor: Color(0xffFFF1F2),
                iconColor: Color(0xffE11D48),
              ),
              SizedBox(width: 12),
              _SubjectCard(
                icon: Icons.eco_rounded,
                title: 'Biology',
                subtitle: 'Recommended',
                bgColor: Color(0xffF0FDF4),
                iconColor: Color(0xff16A34A),
              ),
            ],
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

  const _SubjectCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff64748B),
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

// ======================================================
// TODAY'S CHALLENGE
// ======================================================

class _TodayChallengeCard extends StatelessWidget {
  const _TodayChallengeCard();

  @override
  Widget build(BuildContext context) {
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
            width: 24,
            height: 24,
          ),

          const SizedBox(height: 8),

          const Text(
            'Today\'s Challenge',
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Answer 10 questions and keep your streak alive.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xff64748B),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⭐ +20 XP',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🪙 +10 Coins',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Challenge',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
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

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard();

  @override
  Widget build(BuildContext context) {
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
              const Expanded(
                child: Text(
                  'Leaderboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff2563EB),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          _leaderRow('🥇', 'Aisha', '3420 XP'),
          _leaderRow('🥈', 'David', '3180 XP'),
          _leaderRow('🥉', 'Grace', '2940 XP'),

          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffEDF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xffCFE1FF),
              ),
            ),
            child: _leaderRow(
              '👤',
              'You',
              '100 XP',
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaderRow(
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
            style: const TextStyle(fontSize: 15),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 4),

          Text(
            score,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              fontSize: 11,
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

class _RewardsProgressCard extends StatelessWidget {
  const _RewardsProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffECFDF5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎁 Rewards Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Next Reward',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff16A34A),
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Airtime',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff0F172A),
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.5,
              minHeight: 12,
              backgroundColor: Colors.white,
              color: const Color(0xff16A34A),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            '50 / 100 Coins',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

