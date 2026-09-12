import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/utils/responsive.dart';
import '../../controllers/daily_summary_provider.dart';
import '../../controllers/refresh.dart';
import '../../controllers/subjects_provider.dart';
import '../../controllers/user_profile_provider.dart';
import '../../models/dashboard_models.dart';
import '../../models/daily_summary.dart';
import '../../../tutor/controllers/tutor_controller.dart';
import '../../../tutor/models/tutor_models.dart';
import '../../../tutor/presentation/pages/continue_learning_page.dart';
import '../../../tutor/presentation/pages/tutor_chat_page.dart';
import '../../../tutor/presentation/pages/tutor_topics_page.dart';
import '../../../tutor/services/tutor_service.dart';
import '../../../quiz/presentation/pages/quiz_play_page.dart';
import '../../../notifications/controllers/notifications_provider.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../widgets/subject_icons.dart';

/// Picks the closest hand-authored subject icon for a backend subjectId,
/// falling back to a generic book for subjects without a bespoke icon.
String subjectIconSvg(String subjectId) {
  switch (subjectId) {
    case 'math':
    case 'further_math':
      return mathIconSvg;
    case 'english':
      return englishIconSvg;
    case 'physics':
      return physicsIconSvg;
    case 'chemistry':
      return chemistryIconSvg;
    case 'biology':
    case 'agricultural_science':
      return biologyIconSvg;
    case 'economics':
    case 'commerce':
    case 'business_studies':
    case 'accounting':
      return economicsIconSvg;
    case 'government':
    case 'civic_education':
    case 'crs':
    case 'geography':
      return governmentIconSvg;
    default:
      return englishIconSvg;
  }
}

/// Opens the AI Tutor - straight into [subjectName]'s topic list when given
/// a match, otherwise the subject picker. Refreshes the dashboard's stats
/// on return, since a lesson in there can change XP/coins/streak.
Future<void> _openTutor(
  BuildContext context,
  WidgetRef ref, {
  String? subjectName,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TutorTopicsPage(initialSubjectName: subjectName),
    ),
  );
  invalidateUserStats(ref);
}

/// Opens the full "Continue Learning" list - in-progress topics only,
/// never the full curriculum.
void _openContinueLearning(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ContinueLearningPage()),
  );
}

/// Lets the student pick a subject to practice, then starts a quiz.
Future<void> _openQuizPicker(BuildContext context, WidgetRef ref) async {
  final subjectsAsync = ref.read(subjectsProvider);
  final subjects = subjectsAsync.valueOrNull;
  if (subjects == null || subjects.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subjects are still loading - try again in a moment.')),
    );
    return;
  }

  final picked = await showModalBottomSheet<SubjectModel>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Practice which subject?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = subjects[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 32,
                        height: 32,
                        child: SvgPicture.string(subjectIconSvg(s.id)),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () => Navigator.of(sheetContext).pop(s),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (picked != null && context.mounted) {
    final myClassLevel = ref.read(userProfileProvider).valueOrNull?.classLevel;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPlayPage(
          subjectId: picked.id,
          subjectName: picked.name,
          classLevel: (myClassLevel == null || myClassLevel.isEmpty) ? 'SS1' : myClassLevel,
        ),
      ),
    );
  }
}

class SubjectsPage extends ConsumerWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = context.isTablet ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Hero(hPad: hPad),
              const Gap(24),
              _ContinueLearningSection(
                onViewAll: () => _openContinueLearning(context),
              ),
              _SectionHeader(
                title: 'Subjects',
                onViewAll: () => _openTutor(context, ref),
              ),
              const Gap(16),
              const _SubjectGrid(),
              const Gap(28),
              const _PracticeQuizCard(),
              const Gap(28),
              const _TodayGoalCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero (gradient header + overlapping streak card) ─────────────────────────

class _Hero extends StatelessWidget {
  final double hPad;
  const _Hero({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(hPad - 4, 24, hPad - 4, 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF075BF2), Color(0xFF0751DC)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Ola 👋',
                      style: TextStyle(
                        fontSize: context.rs(22),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready to study today?',
                      style: TextStyle(
                        fontSize: context.rs(14),
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const _HeroBell(),
              const SizedBox(width: 18),
              Container(
                width: context.isTablet ? 68 : 58,
                height: context.isTablet ? 68 : 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.13),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/illustrations/avatar_student.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -24),
          child: const _StreakCard(),
        ),
      ],
    );
  }
}

// ─── Hero notification bell (small white icon on the gradient header) ─────────

class _HeroBell extends ConsumerWidget {
  const _HeroBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        ref.invalidate(unreadNotificationCountProvider);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.string(bellIconSvg, width: 25, height: 25),
          if (unread > 0)
            Positioned(
              right: -1,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4338),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Streak card ──────────────────────────────────────────────────────────────

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  static const _fallbackWeek = [
    DayActivity(date: '', weekday: 'Mon', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Tue', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Wed', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Thu', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Fri', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Sat', studied: false, isToday: false),
    DayActivity(date: '', weekday: 'Sun', studied: false, isToday: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySummaryProvider).valueOrNull;
    final streak = summary?.streak ?? 0;
    final week = (summary != null && summary.week.isNotEmpty)
        ? summary.week
        : _fallbackWeek;

    final title = streak > 0
        ? '🔥 $streak Day Streak'
        : '🔥 Start your streak';
    final subtitle = streak > 0
        ? "Keep it up! You're doing great."
        : 'Study today to begin a streak.';

    return Container(
      padding: const EdgeInsets.fromLTRB(21, 18, 21, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFE5ED)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.rs(17),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
              color: const Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(fontSize: context.rs(13), color: const Color(0xFF758092)),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((d) {
              final done = d.studied;
              final today = d.isToday;
              final bg = today
                  ? const Color(0xFFFFECD0)
                  : done
                      ? const Color(0xFFD9F7E8)
                      : const Color(0xFFF1F3F6);
              final fg = today
                  ? const Color(0xFFFF7C00)
                  : done
                      ? const Color(0xFF17B777)
                      : const Color(0xFF9AA4B2);
              return Column(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: today
                        ? const Text('🔥', style: TextStyle(fontSize: 14))
                        : Icon(
                            done ? Icons.check_rounded : Icons.circle_outlined,
                            color: fg,
                            size: 16,
                          ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    d.weekday,
                    style: TextStyle(fontSize: context.rs(11), color: const Color(0xFF6C7686)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: context.rs(17),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.42,
            color: const Color(0xFF101828),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(
              fontSize: context.rs(13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0757E8),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Continue Learning section (header + latest in-progress topic) ────────────

/// Shows the student's most recently active unfinished topic. Renders
/// nothing at all when there's no in-progress work, so the Learn screen
/// starts at "Subjects" for a brand-new student.
class _ContinueLearningSection extends ConsumerStatefulWidget {
  final VoidCallback onViewAll;
  const _ContinueLearningSection({required this.onViewAll});

  @override
  ConsumerState<_ContinueLearningSection> createState() =>
      _ContinueLearningSectionState();
}

class _ContinueLearningSectionState
    extends ConsumerState<_ContinueLearningSection> {
  final _tutorService = TutorService();
  List<InProgressTopic>? _topics;
  bool _resuming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final topics = await _tutorService.getContinueLearning();
      if (mounted) setState(() => _topics = topics);
    } catch (_) {
      if (mounted) setState(() => _topics = const []);
    }
  }

  Future<void> _resume(InProgressTopic entry) async {
    if (_resuming) return;
    setState(() => _resuming = true);
    await ref.read(tutorControllerProvider.notifier).startSession(
          subjectId: entry.topic.subjectId,
          classLevel: entry.topic.classLevel,
          topicId: entry.topic.id,
        );
    if (!mounted) return;
    setState(() => _resuming = false);

    final error = ref.read(tutorControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TutorChatPage(topicTitle: entry.topic.topic),
      ),
    );
    // Studying in that session may have advanced XP/coins/streak/goal.
    invalidateUserStats(ref);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final topics = _topics;
    // Still loading, or nothing in progress: show nothing.
    if (topics == null || topics.isEmpty) return const SizedBox.shrink();

    final entry = topics.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Continue Learning',
          onViewAll: widget.onViewAll,
        ),
        const Gap(12),
        _ContinueLearningCard(
          entry: entry,
          resuming: _resuming,
          onTap: () => _resume(entry),
        ),
        const Gap(28),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final InProgressTopic entry;
  final bool resuming;
  final VoidCallback onTap;
  const _ContinueLearningCard({
    required this.entry,
    required this.resuming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = context.isTablet ? 74.0 : 64.0;
    final progress = (entry.progressPercent / 100).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            SizedBox(
              width: tileSize,
              height: tileSize,
              child: SvgPicture.string(subjectIconSvg(entry.topic.subjectId)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.topic.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    entry.topic.theme,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: context.rs(11), color: const Color(0xFF788292)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFE9EDF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF20BD7A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${entry.progressPercent}%',
                        style: TextStyle(
                          fontSize: context.rs(11),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF172033),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0757E8),
                shape: BoxShape.circle,
              ),
              child: resuming
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subject grid ───────────────────────────────────────────────────────────

class _SubjectGrid extends ConsumerWidget {
  const _SubjectGrid();

  static const _subjects = [
    ('Mathematics', mathIconSvg),
    ('English', englishIconSvg),
    ('Physics', physicsIconSvg),
    ('Chemistry', chemistryIconSvg),
    ('Biology', biologyIconSvg),
    ('Economics', economicsIconSvg),
    ('Government', governmentIconSvg),
    ('More', moreIconSvg),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: context.isTablet ? 120 : 96,
        mainAxisExtent: context.isTablet ? 100 : 88,
        mainAxisSpacing: 17,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final (name, svg) = _subjects[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openTutor(
            context,
            ref,
            subjectName: name == 'More' ? null : name,
          ),
          child: Column(
            children: [
              SizedBox(
                width: context.isTablet ? 56 : 48,
                height: context.isTablet ? 56 : 48,
                child: SvgPicture.string(svg),
              ),
              const SizedBox(height: 7),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.rs(11),
                  color: const Color(0xFF303846),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Practice Quiz card ─────────────────────────────────────────────────────

class _PracticeQuizCard extends ConsumerWidget {
  const _PracticeQuizCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final ready = subjectsAsync.valueOrNull?.isNotEmpty ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ready ? () => _openQuizPicker(context, ref) : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0757E8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.quiz_rounded, color: Color(0xFF0757E8), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Quiz',
                    style: TextStyle(
                      fontSize: context.rs(15),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Test yourself and earn coins + XP',
                    style: TextStyle(fontSize: context.rs(12), color: const Color(0xFF758092)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AA4B2)),
          ],
        ),
      ),
    );
  }
}

// ─── Today's Goal card ──────────────────────────────────────────────────────

class _TodayGoalCard extends ConsumerWidget {
  const _TodayGoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dailySummaryProvider).valueOrNull;
    final total = summary?.goalTarget ?? 20;
    final answered = summary?.goalAnswered ?? 0;
    final percent = summary?.goalPercent ?? 0;
    final progress = (percent / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 13),
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
                "Today's Goal",
                style: TextStyle(
                  fontSize: context.rs(17),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF172033),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: context.rs(16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF172033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: const Color(0xFFEDF0F4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0757E8)),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Answer $total questions',
                style: TextStyle(fontSize: context.rs(11), color: const Color(0xFF667085)),
              ),
              Text(
                '$answered / $total',
                style: TextStyle(fontSize: context.rs(11), color: const Color(0xFF667085)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
