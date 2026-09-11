import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../dashboard/controllers/refresh.dart';
import '../../models/quiz_models.dart';
import '../../services/quiz_service.dart';
import 'quiz_result_page.dart';

/// A subject practice quiz - fetch questions, answer them one at a time
/// (with an optional immediate right/wrong reveal), then submit for
/// server-side grading. Not timed by default; a student can take their
/// time on each question - total elapsed time is still tracked and sent
/// along for stats.
class QuizPlayPage extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;
  final String classLevel;

  const QuizPlayPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.classLevel = 'SS1',
  });

  @override
  ConsumerState<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<QuizPlayPage> {
  final _service = QuizService();
  final _stopwatch = Stopwatch();

  bool _loading = true;
  String? _loadError;
  List<QuestionModel> _questions = const [];
  final List<SubmittedAnswer> _answers = [];

  int _index = 0;
  String? _selectedOptionId;
  String? _revealedCorrectOptionId;
  bool _checking = false;

  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final questions = await _service.getRandomQuestions(
        subjectId: widget.subjectId,
        count: 10,
        classLevel: widget.classLevel,
      );
      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() {
          _loading = false;
          _loadError = 'No questions are available for this subject yet.';
        });
        return;
      }
      _stopwatch
        ..reset()
        ..start();
      setState(() {
        _loading = false;
        _questions = questions;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = "Couldn't load questions - check your connection and try again.";
      });
    }
  }

  Future<void> _selectAnswer(String optionId) async {
    if (_selectedOptionId != null) return;
    final question = _questions[_index];

    setState(() {
      _selectedOptionId = optionId;
      _checking = true;
      _answers.add(SubmittedAnswer(questionId: question.id, selectedOptionId: optionId));
    });

    try {
      final check = await _service.checkAnswer(
        questionId: question.id,
        selectedOptionId: optionId,
      );
      if (!mounted || _selectedOptionId != optionId) return;
      setState(() {
        _revealedCorrectOptionId = check.correctOptionId;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Cosmetic feedback only - real grading happens on submit regardless.
      setState(() => _checking = false);
    }
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index += 1;
      _selectedOptionId = null;
      _revealedCorrectOptionId = null;
    });
  }

  Future<void> _finish() async {
    _stopwatch.stop();
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final result = await _service.submitQuizResults(
        subjectId: widget.subjectId,
        answers: _answers,
        timeTaken: _stopwatch.elapsed.inSeconds,
      );
      invalidateUserStats(ref);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            subjectName: widget.subjectName,
            totalQuestions: _questions.length,
            correctAnswers: result['correctAnswers'] ?? 0,
            earnedCoins: result['earnedCoins'] ?? 0,
            earnedXp: result['earnedXp'] ?? 0,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = "Couldn't submit your results - check your connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: Text(
          widget.subjectName,
          style: AppTextStyles.title.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return _ErrorState(message: _loadError!, onRetry: _load);
    }
    if (_submitError != null) {
      return _ErrorState(message: _submitError!, onRetry: _finish);
    }

    final question = _questions[_index];
    final answered = _selectedOptionId != null;
    final isLast = _index >= _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_index + 1} of ${_questions.length}',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.subtitle,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EDF2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const Gap(24),

          Text(
            question.questionText,
            style: AppTextStyles.title.copyWith(fontSize: 19, height: 1.4),
          ),
          const Gap(24),

          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, i) {
                final option = question.options[i];
                final label = String.fromCharCode(65 + i); // A, B, C...
                final isSelected = _selectedOptionId == option.id;
                final isRevealedCorrect = _revealedCorrectOptionId == option.id;

                Color border = const Color(0xFFE5E7EB);
                Color bg = Colors.white;
                Color labelBg = const Color(0xFFF3F4F6);
                Color labelFg = AppColors.subtitle;
                Widget? trailing;

                if (answered && !_checking) {
                  if (isRevealedCorrect) {
                    border = AppColors.success;
                    bg = AppColors.success.withValues(alpha: 0.08);
                    labelBg = AppColors.success;
                    labelFg = Colors.white;
                    trailing = const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 22);
                  } else if (isSelected) {
                    border = AppColors.danger;
                    bg = AppColors.danger.withValues(alpha: 0.06);
                    labelBg = AppColors.danger;
                    labelFg = Colors.white;
                    trailing = const Icon(Icons.cancel_rounded,
                        color: AppColors.danger, size: 22);
                  }
                } else if (isSelected) {
                  border = AppColors.primary;
                  bg = AppColors.primary.withValues(alpha: 0.06);
                  labelBg = AppColors.primary;
                  labelFg = Colors.white;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    onTap: answered ? null : () => _selectAnswer(option.id),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border, width: 1.5),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: labelBg, shape: BoxShape.circle),
                            child: Text(
                              label,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: labelFg,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              option.text,
                              style: AppTextStyles.body.copyWith(fontSize: 15),
                            ),
                          ),
                          if (trailing != null) trailing,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (answered && !_checking && question.explanation != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FF),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                question.explanation!,
                style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 13),
              ),
            ),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !answered || _checking || _submitting ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: AppColors.subtitle,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isLast ? 'Finish Quiz' : 'Next Question',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
            ),
            const Gap(16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
