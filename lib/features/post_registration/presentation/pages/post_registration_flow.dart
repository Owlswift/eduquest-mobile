import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../../../../core/routes/routes.dart';
import '../providers/post_registration_notifier.dart';
import 'starter_challenge_screen.dart';

const _blue = Color(0xFF2B5CE6);
const _darkText = Color(0xFF0D1B3E);
const _greyText = Color(0xFF6B7280);
const _borderGrey = Color(0xFFE5E7EB);

const _nigerianStates = [
  'Abia','Adamawa','Akwa Ibom','Anambra','Bauchi','Bayelsa','Benue','Borno',
  'Cross River','Delta','Ebonyi','Edo','Ekiti','Enugu','FCT','Gombe','Imo',
  'Jigawa','Kaduna','Kano','Katsina','Kebbi','Kogi','Kwara','Lagos','Nasarawa',
  'Niger','Ogun','Ondo','Osun','Oyo','Plateau','Rivers','Sokoto','Taraba',
  'Yobe','Zamfara',
];

const _subjects = [
  ('Mathematics', Icons.functions_rounded, Color(0xFF4F46E5)),
  ('English', Icons.menu_book_rounded, Color(0xFF7C3AED)),
  ('Physics', Icons.science_rounded, Color(0xFF0EA5E9)),
  ('Chemistry', Icons.biotech_rounded, Color(0xFF8B5CF6)),
  ('Biology', Icons.eco_rounded, Color(0xFF22C55E)),
  ('Economics', Icons.trending_up_rounded, Color(0xFFF97316)),
  ('Government', Icons.account_balance_rounded, Color(0xFF3B82F6)),
  ('Literature', Icons.auto_stories_rounded, Color(0xFFEF4444)),
  ('Further Math', Icons.calculate_rounded, Color(0xFF6366F1)),
];

// ─── Shell ────────────────────────────────────────────────────────────────────

class PostRegistrationFlow extends ConsumerWidget {
  const PostRegistrationFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(postRegProvider).step;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _stepWidget(step),
        ),
      ),
    );
  }

  Widget _stepWidget(int step) {
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

class _Header extends ConsumerWidget {
  final int step;
  final bool showBack;
  const _Header({required this.step, this.showBack = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showBack && step > 0)
                GestureDetector(
                  onTap: () => ref.read(postRegProvider.notifier).previousStep(),
                  child: const Icon(Icons.arrow_back_rounded, color: _darkText, size: 22),
                )
              else
                const SizedBox(width: 22),
              const Spacer(),
              Text(
                'Step ${step + 1} of 6',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _greyText),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (step + 1) / 6,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      color: Colors.white,
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            elevation: 0,
            disabledBackgroundColor: _blue.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── STEP 1 — Welcome to EduQuest ────────────────────────────────────────────
// Layout: Header → Title+subtitle → Illustration (Expanded) → Button

class _Step1Welcome extends ConsumerWidget {
  const _Step1Welcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Header(step: 0, showBack: false),
        const Gap(24),

        // Title + subtitle (fixed, not scrollable)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _darkText, height: 1.2),
                  children: [
                    TextSpan(text: 'Welcome to\n'),
                    TextSpan(text: 'EduQuest 🎉', style: TextStyle(color: _blue)),
                  ],
                ),
              ),
              const Gap(10),
              const Text(
                "Let's set up your competition profile\nand get you started.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: _greyText, height: 1.5),
              ),
            ],
          ),
        ),

        // Illustration — Expanded fills remaining space between subtitle and button
        Expanded(
          child: Image.asset(
            'assets/illustrations/post_registration_screen1.png',
            fit: BoxFit.cover,
          ),
        ),

        _PrimaryButton(
          label: 'Continue',
          onTap: () => ref.read(postRegProvider.notifier).nextStep(),
        ),
      ],
    );
  }
}

// ─── STEP 2 — Choose Your Arena ───────────────────────────────────────────────
// Layout: Header → ScrollView(Title + subtitle + 3 cards + illustration) → Button

class _Step2Arena extends ConsumerWidget {
  const _Step2Arena({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    final levels = [
      ('SS1', 'assets/illustrations/bronze_medal.png', const Color(0xFFFFF7ED)),
      ('SS2', 'assets/illustrations/silver.png', const Color(0xFFF1F5F9)),
      ('SS3', 'assets/illustrations/gold_medal.png', const Color(0xFFFFF7ED)),
    ];

    return Column(
      children: [
        _Header(step: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _darkText, height: 1.2),
                    children: [
                      TextSpan(text: 'Choose Your\n'),
                      TextSpan(text: 'Arena', style: TextStyle(color: _blue)),
                    ],
                  ),
                ),
                const Gap(6),
                const Text(
                  "You'll compete with students\nin the same level.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: _greyText, height: 1.5),
                ),
                const Gap(20),

                // 3 level cards
                ...levels.map((level) {
                  final (id, medalPath, iconBg) = level;
                  final selected = state.classLevel == id;
                  return GestureDetector(
                    onTap: () => notifier.setClassLevel(id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selected ? _blue : _borderGrey, width: selected ? 2 : 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                            child: Image.asset(
                              medalPath,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(id, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: selected ? _blue : _darkText)),
                          ),
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? _blue : Colors.transparent,
                              border: Border.all(color: selected ? _blue : _borderGrey, width: 2),
                            ),
                            child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Podium illustration — fixed height, no Expanded
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: SizedBox(
                    height: 500,
                    child: Image.asset(
                      'assets/illustrations/post_registration_screen2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _PrimaryButton(label: 'Continue', onTap: () => notifier.nextStep()),
      ],
    );
  }
}

// ─── STEP 3 — Represent Your State ───────────────────────────────────────────
// Layout: Header → ScrollView(Title + Map illustration) → Fixed bottom(dropdown + rankings card) → Button

class _Step3State extends ConsumerWidget {
  const _Step3State({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return Column(
      children: [
        _Header(step: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _darkText, height: 1.2),
                    children: [
                      TextSpan(text: 'Represent Your\n'),
                      TextSpan(text: 'State', style: TextStyle(color: _blue)),
                    ],
                  ),
                ),
                const Gap(8),
                const Text(
                  'Compete in state and national rankings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: _greyText),
                ),
                const Gap(12),

                // Nigeria map — fixed height
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: SizedBox(
                    height: 440,
                    child: Image.asset(
                      'assets/illustrations/post_registration_screen3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Gap(8),
              ],
            ),
          ),
        ),

        // Fixed bottom section — dropdown + rankings card
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select State',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _darkText)),
              const Gap(8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderGrey),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedState.isEmpty ? null : state.selectedState,
                    hint: Row(
                      children: const [
                        Icon(Icons.location_on_rounded, color: _blue, size: 18),
                        SizedBox(width: 8),
                        Text('Select State', style: TextStyle(color: _greyText)),
                      ],
                    ),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _darkText),
                    borderRadius: BorderRadius.circular(12),
                    items: _nigerianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) { if (v != null) notifier.setSelectedState(v); },
                  ),
                ),
              ),
              const Gap(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("You'll be ranked in:", style: TextStyle(fontSize: 13, color: _greyText)),
                    const Gap(12),
                    Row(
                      children: [
                        _RankingBadge(
                          icon: Icons.account_balance_rounded,
                          iconColor: _blue,
                          label: state.selectedState.isEmpty ? 'State Rankings' : '${state.selectedState} Rankings',
                        ),
                        const SizedBox(width: 24),
                        const _RankingBadge(
                          icon: Icons.emoji_events_rounded,
                          iconColor: Color(0xFFF59E0B),
                          label: 'National Rankings',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(4),
            ],
          ),
        ),

        _PrimaryButton(
          label: 'Continue',
          onTap: state.selectedState.isEmpty ? null : () => notifier.nextStep(),
        ),
      ],
    );
  }
}

// ─── STEP 4 — Choose Your Subjects ───────────────────────────────────────────
// Layout: Header → ScrollView(Title + subtitle + 3x3 grid + hint) → Button

class _Step4Subjects extends ConsumerWidget {
  const _Step4Subjects({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    // Load subjects when this step is displayed
    if (state.availableSubjects.isEmpty && !state.loading) {
      Future.microtask(() => notifier.loadSubjects());
    }

    return Column(
      children: [
        _Header(step: 3),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _darkText, height: 1.2),
                    children: [
                      TextSpan(text: 'Choose Your\n'),
                      TextSpan(text: 'Subjects', style: TextStyle(color: _blue)),
                    ],
                  ),
                ),
                const Gap(8),
                const Text(
                  'Pick the subjects you want to\ncompete and improve in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: _greyText, height: 1.5),
                ),
                const Gap(24),

                if (state.availableSubjects.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Loading subjects...',
                        style: TextStyle(fontSize: 14, color: _greyText),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.availableSubjects.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final subject = state.availableSubjects[index];
                      final selected = state.selectedSubjectIds.contains(subject.id);
                      return GestureDetector(
                        onTap: () => notifier.toggleSubject(subject.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? _blue : _borderGrey, width: selected ? 2 : 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Stack(
                            children: [
                              if (selected)
                                Positioned(
                                  top: 6, left: 6,
                                  child: Container(
                                    width: 20, height: 20,
                                    decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
                                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
                                  ),
                                ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(subject.icon, color: subject.color, size: 32),
                                    const Gap(8),
                                    Text(
                                      subject.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _darkText),
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

                const Gap(16),
                const Text(
                  'You can add or change subjects later.',
                  style: TextStyle(fontSize: 13, color: _greyText),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
        Consumer(builder: (context, ref, _) {
          final loading = ref.watch(postRegProvider).loading;
          return _PrimaryButton(
            label: 'Continue',
            loading: loading,
            onTap: state.selectedSubjectIds.isEmpty
                ? null
                : () async {
                    final ok = await ref.read(postRegProvider.notifier).saveProfile();
                    if (ok && context.mounted) ref.read(postRegProvider.notifier).nextStep();
                  },
          );
        }),
      ],
    );
  }
}

// ─── STEP 5 — Your Welcome Bonus ─────────────────────────────────────────────
// Layout: Header → ScrollView(Title + subtitle + blue card + text) → Button

class _Step5Bonus extends ConsumerWidget {
  const _Step5Bonus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return Column(
      children: [
        _Header(step: 4),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _darkText, height: 1.2),
                    children: [
                      TextSpan(text: 'Your Welcome\n'),
                      TextSpan(text: 'Bonus 🎁', style: TextStyle(color: _blue)),
                    ],
                  ),
                ),
                const Gap(8),
                const Text(
                  "We've added some rewards\nto get you started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: _greyText, height: 1.5),
                ),
                const Gap(24),

                // Blue gradient card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B5CE6), Color(0xFF1A3DC4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF2B5CE6).withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coins + gift illustration — fixed height
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        child: SizedBox(
                          height: 360,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/illustrations/Screenshot 2026-06-20 at 13.06.35-Photoroom.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      // 100 Coins row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 26),
                            ),
                            const SizedBox(width: 14),
                            const Text('100', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Text('Coins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70)),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 1,
                        color: Colors.white.withOpacity(0.15),
                      ),

                      // 50 XP row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Text('XP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text('50', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Text('XP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(20),
                const Text(
                  'Start earning more by completing\nchallenges and climbing the leaderboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: _greyText, height: 1.6),
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
        _PrimaryButton(
          label: 'Claim Reward',
          loading: state.loading,
          onTap: state.bonusClaimed
              ? () => notifier.nextStep()
              : () async {
                  final ok = await notifier.claimBonus();
                  if (ok && context.mounted) notifier.nextStep();
                },
        ),
      ],
    );
  }
}

// ─── STEP 6 — Your First Challenge Awaits! ───────────────────────────────────
// Layout: Header → Challenge preview card → Button

class _Step6Challenge extends ConsumerWidget {
  const _Step6Challenge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);
    final notifier = ref.read(postRegProvider.notifier);

    return Column(
      children: [
        _Header(step: 5),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                        height: 1.2),
                    children: [
                      TextSpan(text: 'Your First Challenge\n'),
                      TextSpan(text: 'Awaits! ⚡',
                          style: TextStyle(color: _blue)),
                    ],
                  ),
                ),
                const Gap(8),
                const Text(
                  'Take on a short challenge to kickstart\nyour journey.',
                  style: TextStyle(fontSize: 15, color: _greyText, height: 1.5),
                ),
                const Gap(16),

                // Boy studying illustration
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/illustrations/onboarding1.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const Gap(20),

                // Challenge info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _borderGrey),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.gps_fixed_rounded,
                                color: Color(0xFFEF4444), size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Text('Starter Challenge',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText)),
                        ],
                      ),
                      const Gap(10),
                      Row(
                        children: const [
                          Text('✦ ', style: TextStyle(color: _blue, fontSize: 14)),
                          Text('10 Questions • 30 seconds each',
                              style: TextStyle(fontSize: 15, color: _greyText)),
                        ],
                      ),
                      const Gap(14),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const Gap(10),
                      const Text('Reward:',
                          style: TextStyle(fontSize: 14, color: _greyText)),
                      const Gap(10),
                      Row(
                        children: [
                          _RewardChip(
                            icon: Icons.monetization_on_rounded,
                            label: '+10 Coins per correct',
                            iconColor: const Color(0xFFFBBF24),
                            bgColor: const Color(0xFFFFFBEB),
                          ),
                        ],
                      ),
                      const Gap(6),
                      Row(
                        children: [
                          _RewardChip(
                            icon: null,
                            xpBadge: true,
                            label: '+10 XP per correct',
                            iconColor: const Color(0xFF7C3AED),
                            bgColor: const Color(0xFFF5F3FF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
              ],
            ),
          ),
        ),

        // Start Challenge button — loads questions then pushes quiz screen
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          color: Colors.white,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
                    onPressed: state.loading
                    ? null
                    : () async {
                        final ok = await notifier.startChallenge();
                        if (ok && context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StarterChallengeScreen(),
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: _blue.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: state.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Start Challenge',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.bolt_rounded, size: 22),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Quiz Screen ──────────────────────────────────────────────────────────────

class _QuizScreen extends ConsumerStatefulWidget {
  final PostRegState state;
  final PostRegNotifier notifier;

  const _QuizScreen({required this.state, required this.notifier});

  @override
  ConsumerState<_QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<_QuizScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(_QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if question changes or time resets
    if (oldWidget.state.currentQuestionIndex != widget.state.currentQuestionIndex ||
        oldWidget.state.timeLeft != widget.state.timeLeft) {
      _timer?.cancel();
      if (widget.state.isChallengeActive && widget.state.selectedAnswerId == null) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.state.isChallengeActive && widget.state.selectedAnswerId == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          widget.notifier.tick();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Column(
      children: [
        _Header(step: 5, showBack: false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: _borderGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(_blue),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${state.currentQuestionIndex + 1}/${state.questions.length}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _darkText),
                    ),
                  ],
                ),
                const Gap(20),

                // Timer
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: state.timeLeft <= 10 ? Colors.red : _blue,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.timeLeft}s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: state.timeLeft <= 10 ? Colors.red : _darkText,
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Question
                Text(
                  currentQuestion.questionText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText, height: 1.4),
                ),
                const Gap(24),

                // Answer options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final option = currentQuestion.options[index];
                      final isSelected = state.selectedAnswerId == option.id;
                      final isCorrect = option.id == currentQuestion.correctAnswerId;
                      
                      Color? bgColor;
                      Color? borderColor;
                      
                      if (state.selectedAnswerId != null) {
                        // Show correct/wrong after answering
                        if (isCorrect) {
                          bgColor = const Color(0xFFDCFCE7);
                          borderColor = const Color(0xFF22C55E);
                        } else if (isSelected && !isCorrect) {
                          bgColor = const Color(0xFFFEE2E2);
                          borderColor = const Color(0xFFEF4444);
                        } else {
                          bgColor = Colors.grey[100];
                          borderColor = _borderGrey;
                        }
                      } else {
                        bgColor = Colors.white;
                        borderColor = _borderGrey;
                      }

                      return GestureDetector(
                        onTap: state.selectedAnswerId == null
                            ? () {
                                notifier.selectAnswer(option.id);
                                _timer?.cancel(); // Stop timer when answer is selected
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? _blue : _borderGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: state.selectedAnswerId == option.id
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                      : Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : _darkText,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: const TextStyle(fontSize: 16, color: _darkText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Gap(16),

                // Next button (shown after answering)
                if (state.selectedAnswerId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => notifier.nextQuestion(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.currentQuestionIndex < state.questions.length - 1
                                ? 'Next Question'
                                : 'See Results',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── STEP 7 — Great Start! ────────────────────────────────────────────────────
// Layout: ScrollView(illustration fills top + title + results card + rankings card) → Button

class _Step7GreatStart extends ConsumerWidget {
  const _Step7GreatStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postRegProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration fills top — fixed height
                SizedBox(
                  height: 600,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/illustrations/post_reg_success.png',
                    fit: BoxFit.fill,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text('Great Start! 🎉',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _darkText)),
                      ),
                      const Gap(24),

                      // Results card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ResultRow(
                              iconWidget: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.help_outline_rounded, color: _blue, size: 18),
                              ),
                              label: 'Questions Answered',
                              value: '${state.questionsAnswered}',
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
                            _ResultRow(
                              iconWidget: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.check_rounded, color: Color(0xFF22C55E), size: 18),
                              ),
                              label: 'Correct Answers',
                              value: '${state.correctAnswers}',
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
                            _ResultRow(
                              iconWidget: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(8)),
                                child: const Center(child: Text('XP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                              ),
                              label: 'XP Earned',
                              value: '${state.earnedXp}',
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
                            _ResultRow(
                              iconWidget: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: const Color(0xFFFBBF24).withOpacity(0.15), shape: BoxShape.circle),
                                child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24), size: 18),
                              ),
                              label: 'Coins Earned',
                              value: '${state.earnedCoins}',
                            ),
                          ],
                        ),
                      ),

                      const Gap(16),

                      // Rankings card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Current Rankings',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _darkText)),
                            const Gap(16),
                            Row(
                              children: [
                                Expanded(child: _RankBox(icon: '🌍', label: 'National Rank', rank: '#${_fmt(state.nationalRank)}', bgColor: const Color(0xFFEFF6FF))),
                                const SizedBox(width: 12),
                                Expanded(child: _RankBox(icon: '🏅', label: 'State Rank', rank: '#${state.stateRank}', bgColor: const Color(0xFFFFFBEB))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dashboard button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          color: Colors.white,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ref.read(postRegProvider.notifier).reset();
                context.go(AppRoutes.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Go to Dashboard', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _RankingBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _RankingBadge({required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _darkText)),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData? icon;
  final bool xpBadge;
  final String label;
  final Color iconColor;
  final Color bgColor;
  const _RewardChip({required this.icon, required this.label, required this.iconColor, required this.bgColor, this.xpBadge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (xpBadge)
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(6)),
              child: const Center(child: Text('XP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))),
            )
          else
            Icon(icon!, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: iconColor)),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  const _ResultRow({required this.iconWidget, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: _greyText))),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _darkText)),
        ],
      ),
    );
  }
}

class _RankBox extends StatelessWidget {
  final String icon;
  final String label;
  final String rank;
  final Color bgColor;
  const _RankBox({required this.icon, required this.label, required this.rank, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const Gap(6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: _greyText)),
          const Gap(4),
          Text(rank, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _darkText)),
        ],
      ),
    );
  }
}