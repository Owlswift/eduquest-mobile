import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      bottomNavigationBar: const _BottomNav(),
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
              _StatsRow(),
              SizedBox(height: 20),
              _ArenaBanner(),
              SizedBox(height: 24),
              _RecommendedSection(),
              SizedBox(height: 20),
              _ChallengeLeaderboardRow(),
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
                  fontSize: 18,
                  color: Color(0xff6B7280),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ola',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0F172A),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black12,
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),

        const SizedBox(width: 12),

        const CircleAvatar(
          radius: 28,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffEEF6FF),
        borderRadius: BorderRadius.circular(28),
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
                width: 95,
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level 1 • Explorer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You've completed your first challenge and joined the academy.",
                    ),
                  ],
                ),
              ),

              Image.asset(
                'assets/illustrations/school_bag.png',
                width: 110,
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Text(
                'Progress to Level 2',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '100 / 300 XP',
                style: TextStyle(
                  color: Color(0xff2563EB),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.33,
              minHeight: 16,
              backgroundColor: Colors.white,
              color: const Color(0xff2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP + Coins ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: 'assets/illustrations/xp_coin.png',
            title: 'XP Earned',
            value: '100',
            subtitle: 'From your entrance test',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _StatCard(
            icon: 'assets/illustrations/gold_coin.png',
            title: 'Coins',
            value: '50',
            subtitle: 'Ready to spend',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 64),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(subtitle),
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
      height: 240,
      padding: const EdgeInsets.all(24),
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
                  width: 70,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Enter the Arena',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Compete with other students and win XP, coins, airtime, scholarships and devices.',
                  style: TextStyle(color: Colors.white),
                ),

                const Spacer(),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Choose Arena'),
                  ),
                ),
              ],
            ),
          ),

          Image.asset(
            'assets/illustrations/arena_trophy.png',
            width: 170,
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
              'Recommended for You',
              style: TextStyle(
                fontSize: 24,
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
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _SubjectCard(
                icon: Icons.calculate_rounded,
                title: 'Mathematics',
                subtitle: 'Based on your test',
                bgColor: const Color(0xffEDF5FF),
                iconColor: const Color(0xff2563EB),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _SubjectCard(
                icon: Icons.menu_book_rounded,
                title: 'English',
                subtitle: 'Recommended',
                bgColor: const Color(0xffF4F0FF),
                iconColor: const Color(0xff7C3AED),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _SubjectCard(
                icon: Icons.science_rounded,
                title: 'Physics',
                subtitle: 'Recommended',
                bgColor: const Color(0xffEDFDF6),
                iconColor: const Color(0xff10B981),
              ),
            ),
          ],
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
      height: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),

          const SizedBox(width: 12),

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
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),

          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xff2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CHALLENGE + LEADERBOARD
// ======================================================

class _ChallengeLeaderboardRow extends StatelessWidget {
  const _ChallengeLeaderboardRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: _TodayChallengeCard(),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _LeaderboardCard(),
        ),
      ],
    );
  }
}

class _TodayChallengeCard extends StatelessWidget {
  const _TodayChallengeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffFFF9EC),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'assets/illustrations/challenge_target.png',
              width: 110,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Today's Challenge",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Answer 10 questions and keep your streak alive.",
            style: TextStyle(
              color: Color(0xff64748B),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "⭐ +20 XP",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "🪙 +10 Coins",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Start Challenge',
                style: TextStyle(
                  fontSize: 17,
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

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xffFBF7FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Leaderboard Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _leaderRow('🥇', 'Aisha', '3420 XP'),
          _leaderRow('🥈', 'David', '3180 XP'),
          _leaderRow('🥉', 'Grace', '2940 XP'),

          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffEDF5FF),
              borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            medal,
            style: const TextStyle(fontSize: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight:
                    highlight ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),

          Text(
            score,
            style: TextStyle(
              fontWeight:
                  highlight ? FontWeight.w800 : FontWeight.w600,
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
      child: Row(
        children: [
          Image.asset(
            'assets/illustrations/gift_box.png',
            width: 90,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rewards Progress',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Next reward: Airtime',
                  style: TextStyle(
                    color: Color(0xff16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 14,
                    backgroundColor: Colors.white,
                    color: const Color(0xff16A34A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '50 / 100 Coins',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
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
// BOTTOM NAVIGATION
// ======================================================

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: true,
          ),
          _NavItem(
            icon: Icons.menu_book_rounded,
            label: 'Learn',
          ),
          _NavItem(
            icon: Icons.sports_martial_arts,
            label: 'Arena',
          ),
          _NavItem(
            icon: Icons.card_giftcard_rounded,
            label: 'Rewards',
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xff2563EB)
        : const Color(0xff94A3B8);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}