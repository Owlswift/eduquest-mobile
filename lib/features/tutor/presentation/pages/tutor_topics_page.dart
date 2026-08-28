import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../dashboard/models/dashboard_models.dart';
import '../../../subjects/services/subjects_service.dart';
import '../../controllers/tutor_controller.dart';
import '../../models/tutor_models.dart';
import '../../services/tutor_service.dart';
import 'tutor_chat_page.dart';

/// Entry point for the AI Tutor: pick a subject, then a topic within it.
/// Starting a lesson creates a new TutorSession server-side and pushes into
/// TutorChatPage for the actual conversation.
class TutorTopicsPage extends ConsumerStatefulWidget {
  const TutorTopicsPage({super.key});

  @override
  ConsumerState<TutorTopicsPage> createState() => _TutorTopicsPageState();
}

class _TutorTopicsPageState extends ConsumerState<TutorTopicsPage> {
  final _subjectsService = SubjectsService();
  final _tutorService = TutorService();

  List<SubjectModel>? _subjects;
  SubjectModel? _selectedSubject;
  List<CurriculumTopicSummary>? _topics;
  bool _loadingSubjects = true;
  bool _loadingTopics = false;
  bool _startingSession = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  String get _classLevel {
    final user = ref.read(authControllerProvider).user;
    return (user?['classLevel'] as String?) ?? 'SS1';
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _loadingSubjects = true;
      _error = null;
    });
    try {
      final subjects = await _subjectsService.getSubjects();
      setState(() {
        _subjects = subjects;
        _loadingSubjects = false;
      });
    } catch (_) {
      setState(() {
        _loadingSubjects = false;
        _error = "Couldn't load subjects.";
      });
    }
  }

  Future<void> _selectSubject(SubjectModel subject) async {
    setState(() {
      _selectedSubject = subject;
      _topics = null;
      _loadingTopics = true;
      _error = null;
    });
    try {
      final topics = await _tutorService.getTopics(
        subjectId: subject.id,
        classLevel: _classLevel,
      );
      setState(() {
        _topics = topics;
        _loadingTopics = false;
      });
    } catch (_) {
      setState(() {
        _loadingTopics = false;
        _error = "Couldn't load topics for ${subject.name}.";
      });
    }
  }

  Future<void> _startTopic(CurriculumTopicSummary topic) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      // Without this, the sheet is capped at ~half the screen regardless
      // of content - let it grow to fit (up to the full screen height,
      // scrolling internally past that) instead.
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AssessmentNoticeSheet(topicTitle: topic.topic),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await _beginSession(topic);
  }

  Future<void> _beginSession(CurriculumTopicSummary topic) async {
    setState(() => _startingSession = true);
    await ref.read(tutorControllerProvider.notifier).startSession(
          subjectId: topic.subjectId,
          classLevel: topic.classLevel,
          topicId: topic.id,
        );
    setState(() => _startingSession = false);
    if (!mounted) return;

    final error = ref.read(tutorControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TutorChatPage(topicTitle: topic.topic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _selectedSubject == null ? _buildSubjectList() : _buildTopicList(),
      ),
    );
  }

  Widget _buildSubjectList() {
    if (_loadingSubjects) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('AI Tutor', style: AppTextStyles.headline),
        const SizedBox(height: 4),
        Text('Pick a subject to start a lesson', style: AppTextStyles.body),
        const SizedBox(height: 20),
        if (_error != null) _errorBanner(_error!),
        for (final subject in _subjects ?? const <SubjectModel>[])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _selectSubject(subject),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: subject.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(subject.icon, color: subject.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        subject.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopicList() {
    final subject = _selectedSubject!;
    final grouped = <String, List<CurriculumTopicSummary>>{};
    for (final topic in _topics ?? const <CurriculumTopicSummary>[]) {
      grouped.putIfAbsent(topic.theme, () => []).add(topic);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedSubject = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(subject.name, style: AppTextStyles.title, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingTopics
              ? const Center(child: CircularProgressIndicator())
              : _startingSession
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Preparing your lesson...', style: TextStyle(color: AppColors.subtitle)),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      children: [
                        if (_error != null) _errorBanner(_error!),
                        for (final entry in grouped.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.subtitle,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          for (final topic in entry.value)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () => _startTopic(topic),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x0A000000)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          topic.topic,
                                          style: const TextStyle(fontSize: 15, color: AppColors.text),
                                        ),
                                      ),
                                      const Icon(Icons.play_circle_fill_rounded,
                                          color: AppColors.primary, size: 22),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
        ),
      ],
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

/// Shown once before every topic starts, so the student knows what to
/// expect (a short prior-knowledge check before the actual teaching) and
/// that they can skip straight to the lesson if they'd rather not answer it.
class _AssessmentNoticeSheet extends StatelessWidget {
  final String topicTitle;

  const _AssessmentNoticeSheet({required this.topicTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // A modal bottom sheet doesn't scroll its content by default - on a
        // shorter device, or a long topic title wrapping to an extra line,
        // this much fixed-size content (image + heading + paragraph + 3
        // bullets + button) can exceed the sheet's max height and overflow.
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/illustrations/girl_books.png',
                height: 360,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Before we begin: $topicTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your AI Tutor will start with a few quick questions to see what you already know about this topic. '
              "There's no wrong answer here - it just helps the tutor pitch the lesson at the right level for you.",
              style: TextStyle(fontSize: 14, color: AppColors.text, height: 1.4),
            ),
            const SizedBox(height: 14),
            _bullet(Icons.fast_forward_rounded, 'Already know this topic? Tap "Skip assessment" at the top of the chat to jump straight into the lesson.'),
            const SizedBox(height: 8),
            _bullet(Icons.mic_rounded, 'You can type or use the microphone to answer.'),
            const SizedBox(height: 8),
            _bullet(Icons.image_rounded, 'Some lessons include diagrams and pictures to help explain a concept.'),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Let's begin", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.subtitle, height: 1.4)),
        ),
      ],
    );
  }
}
