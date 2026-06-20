import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/routes/routes.dart';
import '../providers/post_registration_notifier.dart';

// ─── Nigerian States ──────────────────────────────────────────────────────────

const _nigerianStates = [
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
  'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti',
  'Enugu', 'FCT', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
  'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo',
  'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
];

const _subjects = [
  ('Mathematics', Icons.functions_rounded, Color(0xFF2563EB)),
  ('English', Icons.menu_book_rounded, Color(0xFF7C3AED)),
  ('Physics', Icons.science_rounded, Color(0xFF059669)),
  ('Chemistry', Icons.biotech_rounded, Color(0xFFDC2626)),
  ('Biology', Icons.eco_rounded, Color(0xFF16A34A)),
  ('Economics', Icons.trending_up_rounded, Color(0xFFF59E0B)),
  ('Government', Icons.account_balance_rounded, Color(0xFF0891B2)),
  ('Literature', Icons.auto_stories_rounded, Color(0xFFDB2777)),
  ('Further Math', Icons.calculate_rounded, Color(0xFF7C3AED)),
];

// ─── Main Shell ───────────────────────────────────────────────────────────────

class PostRegistrationFlow extends ConsumerWidget {
  const PostRegistrationFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar (steps 1-6, hidden on step 7) ──────────────────
            if (state.step < 6) _ProgressHeader(step: state.step),

            // ── Pages ────────────────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _pageForStep(state.step),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageForStep(int step) {
    switch (step) {
      case 0: return const _Step1Welcome(key: ValueKey(0));
      case 1: return const _Step2Arena(key: ValueKey(1));
      case 2: return const _Step3State(key: ValueKey(2));
      case 3: return const _Step4Subjects(key: ValueKey(3));
      case 4: return const _Step5Bonus(key: ValueKey(4));
      case 5: return const _Step6Challenge(key: ValueKey(5));
      case 6: return const _Step7GreatStart(key: ValueKey(6));
      default: return const _Step1Welcome(key: ValueKey(0));
    }
  }
}

// ─── Progress Header ──────────────────────────────────────────────────────────

class _ProgressHeader extends ConsumerWidget {
  final int step;
  const _ProgressHeader({required this.step});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (step > 0)
                GestureDetector(
                  onTap: () =>
                      ref.read(postRegProvider.notifier).previousStep(),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF1E293B), size: 24),
                )
              else
                const SizedBox(width: 24),
              const Spacer(),
              Text(
                'Step ${step + 1} of 6',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2563EB)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Welcome to EduQuest
// ─────────────────────────────────────────────────────────────────────────────

class _Step1Welcome extends ConsumerWidget {
  const _Step1Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/post_reg_welcome.json',
            height: 260,
            fit: BoxFit.contain,
          ),

          const Gap(24),

          _RichTitle(
            prefix: 'Welcome to ',
            colored: 'EduQuest',
            suffix: ' 🎉',
          ),

          const Gap(12),

          const Text(
            "Let's set up your competition profile\nand get you started.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),

          const Gap(48),

          // Confetti decoration dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ConfettiDot(color: const Color(0xFFFBBF24)),
              const SizedBox(width: 8),
              _ConfettiDot(color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              _ConfettiDot(color: const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _ConfettiDot(color: const Color(0xFFEF4444)),
            ],
          ),

          const Gap(48),

          _BigButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onTap: () =>
                ref.read(postRegProvider.notifier).nextStep(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Choose Your Arena (Class Level)
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Arena extends ConsumerWidget {
  const _Step2Arena({super.key});

  static const _levels = [
    ('SS1', 'Secondary School 1', Icons.looks_one_rounded, Color(0xFFFBBF24)),
    ('SS2', 'Secondary School 2', Icons.looks_two_rounded, Color(0xFF94A3B8)),
    ('SS3', 'Secondary School 3', Icons.looks_3_rounded, Color(0xFFCD7C2F)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RichTitle(prefix: 'Choose Your ', colored: 'Arena'),

          const Gap(8),

          const Text(
            "You'll compete with students in the same level.",
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),

          const Gap(24),

          // Arena selector cards
          ..._levels.map((level) {
            final (id, label, icon, color) = level;
            final selected = state.classLevel == id;

            return GestureDetector(
              onTap: () => notifier.setClassLevel(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: selected ? 2 : 1.5,
                  ),
                  boxShadow: selected ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ] : AppShadows.soft,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? const Color(0xFF2563EB)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const Gap(16),

          Lottie.asset(
            'assets/animations/post_reg_arena.json',
            height: 160,
            fit: BoxFit.contain,
          ),

          const Gap(16),

          _BigButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onTap: () => notifier.nextStep(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Represent Your State
// ─────────────────────────────────────────────────────────────────────────────

class _Step3State extends ConsumerWidget {
  const _Step3State({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RichTitle(prefix: 'Represent Your ', colored: 'State'),

          const Gap(8),

          const Text(
            'Compete in state and national rankings.',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),

          const Gap(24),

          // Nigeria map placeholder (Lottie)
          Center(
            child: Lottie.asset(
              'assets/animations/post_reg_map.json',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),

          const Gap(24),

          // State dropdown
          const Text(
            'Select State',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const Gap(8),

          DropdownButtonFormField<String>(
            value: state.selectedState.isEmpty
                ? null
                : state.selectedState,
            hint: const Text('Choose your state'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_rounded,
                  color: Color(0xFF2563EB)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                borderSide: const BorderSide(
                    color: Color(0xFF2563EB), width: 2),
              ),
            ),
            items: _nigerianStates
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) notifier.setSelectedState(v);
            },
          ),

          const Gap(20),

          // Rankings preview card
          if (state.selectedState.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You'll be ranked in:",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      _RankBadge(
                        icon: Icons.account_balance_rounded,
                        label: '${state.selectedState}\nRankings',
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 16),
                      _RankBadge(
                        icon: Icons.emoji_events_rounded,
                        label: 'National\nRankings',
                        color: const Color(0xFFFBBF24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const Gap(24),

          _BigButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onTap: state.selectedState.isEmpty
                ? null
                : () => notifier.nextStep(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Choose Your Subjects
// ─────────────────────────────────────────────────────────────────────────────

class _Step4Subjects extends ConsumerWidget {
  const _Step4Subjects({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RichTitle(prefix: 'Choose Your ', colored: 'Subjects'),

          const Gap(8),

          const Text(
            'Pick the subjects you want to compete and improve in.',
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),

          const Gap(24),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subjects.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final (name, icon, color) = _subjects[index];
              final selected =
                  state.selectedSubjects.contains(name);

              return GestureDetector(
                onTap: () => notifier.toggleSubject(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withOpacity(0.08)
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: selected
                          ? color
                          : const Color(0xFFE2E8F0),
                      width: selected ? 2 : 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (selected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Icon(icon,
                                  color: color, size: 24),
                            ),
                            const Gap(8),
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? color
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Gap(12),

          const Text(
            'You can add or change subjects later.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(24),

          Consumer(builder: (context, ref, _) {
            final loading = ref.watch(postRegProvider).loading;
            return _BigButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              loading: loading,
              onTap: state.selectedSubjects.isEmpty
                  ? null
                  : () async {
                      final ok = await ref
                          .read(postRegProvider.notifier)
                          .saveProfile();
                      if (ok && context.mounted) {
                        ref
                            .read(postRegProvider.notifier)
                            .nextStep();
                      }
                    },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5 — Welcome Bonus
// ─────────────────────────────────────────────────────────────────────────────

class _Step5Bonus extends ConsumerWidget {
  const _Step5Bonus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          _RichTitle(
            prefix: 'Your Welcome\n',
            colored: 'Bonus ',
            suffix: '🎁',
          ),

          const Gap(8),

          const Text(
            "We've added some rewards to get you started!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),

          const Gap(32),

          // Bonus card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animations/post_reg_bonus.json',
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const Gap(20),
                _BonusRow(
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  value: '100',
                  label: 'Coins',
                ),
                const Gap(16),
                _BonusRow(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFF818CF8),
                  value: '50',
                  label: 'XP',
                  isXp: true,
                ),
              ],
            ),
          ),

          const Gap(24),

          const Text(
            'Start earning more by completing\nchallenges and climbing the leaderboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          ),

          const Gap(32),

          _BigButton(
            label: 'Claim Reward',
            icon: Icons.arrow_forward_rounded,
            loading: state.loading,
            onTap: state.bonusClaimed
                ? () => notifier.nextStep()
                : () async {
                    final ok = await notifier.claimBonus();
                    if (ok && context.mounted) {
                      notifier.nextStep();
                    }
                  },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 6 — First Challenge
// ─────────────────────────────────────────────────────────────────────────────

class _Step6Challenge extends ConsumerWidget {
  const _Step6Challenge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          _RichTitle(
            prefix: 'Your First Challenge\n',
            colored: 'Awaits! ',
            suffix: '⚡',
          ),

          const Gap(8),

          const Text(
            'Take on a short challenge to kickstart your journey.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
          ),

          const Gap(28),

          Lottie.asset(
            'assets/animations/post_reg_challenge.json',
            height: 200,
            fit: BoxFit.contain,
          ),

          const Gap(24),

          // Challenge card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const Gap(14),
                const Text(
                  'Starter Challenge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Gap(4),
                const Text(
                  'Answer 5 Questions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Gap(20),
                const Text(
                  'Reward:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RewardPill(
                      icon: Icons.monetization_on_rounded,
                      label: '+50 Coins',
                      color: const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 12),
                    _RewardPill(
                      icon: Icons.star_rounded,
                      label: '+50 XP',
                      color: const Color(0xFF818CF8),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(32),

          _BigButton(
            label: 'Start Challenge',
            icon: Icons.bolt_rounded,
            loading: state.loading,
            onTap: () async {
              final ok = await notifier.completeChallenge();
              if (ok && context.mounted) {
                notifier.nextStep();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 7 — Great Start!
// ─────────────────────────────────────────────────────────────────────────────

class _Step7GreatStart extends ConsumerWidget {
  const _Step7GreatStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/post_reg_success.json',
            height: 220,
            fit: BoxFit.contain,
          ),

          const Gap(16),

          const Text(
            'Great Start! 🎉',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(24),

          // Results card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _ResultRow(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF2563EB),
                  label: 'Questions Answered',
                  value: '${state.questionsAnswered}',
                ),
                const Divider(height: 24),
                _ResultRow(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFF818CF8),
                  label: 'XP Earned',
                  value: '${state.earnedXp}',
                ),
                const Divider(height: 24),
                _ResultRow(
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  label: 'Coins Earned',
                  value: '${state.earnedCoins}',
                ),
              ],
            ),
          ),

          const Gap(20),

          // Rankings card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Current Rankings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: _RankingCard(
                        icon: Icons.public_rounded,
                        iconColor: const Color(0xFF2563EB),
                        label: 'National Rank',
                        rank:
                            '#${state.nationalRank.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RankingCard(
                        icon: Icons.emoji_events_rounded,
                        iconColor: const Color(0xFFFBBF24),
                        label: 'State Rank',
                        rank: '#${state.stateRank}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(32),

          _BigButton(
            label: 'Go to Dashboard',
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              ref.read(postRegProvider.notifier).reset();
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RichTitle extends StatelessWidget {
  final String prefix;
  final String colored;
  final String suffix;

  const _RichTitle({
    required this.prefix,
    required this.colored,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
          height: 1.2,
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: colored,
            style: const TextStyle(color: Color(0xFF2563EB)),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;

  const _BigButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor:
              const Color(0xFF2563EB).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(icon, size: 20),
                ],
              ),
      ),
    );
  }
}

class _BonusRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isXp;

  const _BonusRow({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.isXp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _RewardPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String rank;

  const _RankingCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Gap(8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(4),
          Text(
            rank,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RankBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            height: 1.4,
          ),
        ),
      ],
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