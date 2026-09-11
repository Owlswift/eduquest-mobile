import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../dashboard/controllers/refresh.dart';
import '../../../dashboard/controllers/subjects_provider.dart';
import '../../../dashboard/models/dashboard_models.dart';
import '../../controllers/tutor_controller.dart';
import '../../models/tutor_models.dart';
import '../../services/tutor_service.dart';
import '../widgets/tutor_header.dart';
import 'tutor_chat_page.dart';

/// "Continue Learning - View All": every topic the student has started but
/// not finished, most recently active first. Deliberately never shows the
/// full curriculum - that's what the subject/topic pickers are for.
class ContinueLearningPage extends ConsumerStatefulWidget {
  const ContinueLearningPage({super.key});

  @override
  ConsumerState<ContinueLearningPage> createState() => _ContinueLearningPageState();
}

class _ContinueLearningPageState extends ConsumerState<ContinueLearningPage> {
  final _tutorService = TutorService();

  List<InProgressTopic>? _topics;
  bool _loading = true;
  bool _resuming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final topics = await _tutorService.getContinueLearning();
      setState(() {
        _topics = topics;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = "Couldn't load your in-progress topics.";
      });
    }
  }

  /// Resumes straight into the conversation - startSession already returns
  /// the existing session's full history when one is in progress for this
  /// topic, so there's no "start over" assessment prompt here.
  Future<void> _resume(InProgressTopic entry) async {
    setState(() => _resuming = true);
    await ref.read(tutorControllerProvider.notifier).startSession(
          subjectId: entry.topic.subjectId,
          classLevel: entry.topic.classLevel,
          topicId: entry.topic.id,
        );
    setState(() => _resuming = false);
    if (!mounted) return;

    final error = ref.read(tutorControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TutorChatPage(topicTitle: entry.topic.topic)),
    );
    // The session may have progressed or completed - refresh this list and
    // the dashboard's stats.
    invalidateUserStats(ref);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.isTablet ? 40.0 : 20.0;
    final subjectsById = {
      for (final s in ref.watch(subjectsProvider).valueOrNull ?? const <SubjectModel>[])
        s.id: s,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _resuming
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Resuming your lesson...', style: TextStyle(color: AppColors.subtitle)),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 20),
                children: [
                  TutorHeader(
                    title: 'Continue Learning',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                  if (_loading) const Center(child: CircularProgressIndicator()),
                  if (_error != null) _errorBanner(_error!),
                  if (!_loading && _error == null && (_topics?.isEmpty ?? true))
                    _emptyState(),
                  for (final entry in _topics ?? const <InProgressTopic>[])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InProgressCard(
                        entry: entry,
                        subject: subjectsById[entry.topic.subjectId],
                        onTap: () => _resume(entry),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.menu_book_rounded, size: 40, color: AppColors.subtitle),
          const SizedBox(height: 12),
          Text(
            "You don't have any in-progress topics yet.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  final InProgressTopic entry;
  final SubjectModel? subject;
  final VoidCallback onTap;
  const _InProgressCard({
    required this.entry,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = entry.progressPercent / 100;
    final tileSize = context.isTablet ? 60.0 : 52.0;
    final tint = subject?.color ?? AppColors.primary;
    final icon = subject?.icon ?? Icons.menu_book_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: tint.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.topic.topic,
                    style: TextStyle(
                      fontSize: context.rs(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.topic.theme,
                    style: TextStyle(fontSize: context.rs(11), color: AppColors.subtitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFE9EDF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20BD7A)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${entry.progressPercent}%',
                        style: TextStyle(
                          fontSize: context.rs(11),
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
