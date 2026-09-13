import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../dashboard/controllers/refresh.dart';
import '../../../quiz/models/quiz_models.dart';
import '../../models/challenge_models.dart';
import '../../services/challenges_service.dart';
import 'challenge_results_page.dart';

/// Answering one side of a Challenge. Unlike the regular practice quiz,
/// there's no per-question right/wrong reveal - this is a real scored
/// match against another student, so nothing about the answer key can
/// leak before both sides have submitted. Picking an option just locks
/// it in and moves on.
class ChallengePlayPage extends ConsumerStatefulWidget {
  final String challengeId;
  final String subjectName;

  const ChallengePlayPage({
    super.key,
    required this.challengeId,
    required this.subjectName,
  });

  @override
  ConsumerState<ChallengePlayPage> createState() => _ChallengePlayPageState();
}

class _ChallengePlayPageState extends ConsumerState<ChallengePlayPage> {
  final _service = ChallengesService();

  bool _loading = true;
  String? _loadError;
  List<ChallengeQuestion> _questions = const [];
  final List<SubmittedAnswer> _answers = [];

  int _index = 0;
  String? _selectedOptionId;

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
      final questions = await _service.getQuestions(widget.challengeId);
      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() {
          _loading = false;
          _loadError = 'This challenge has no questions to answer.';
        });
        return;
      }
      setState(() {
        _loading = false;
        _questions = questions;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = "Couldn't load your questions - check your connection and try again.";
      });
    }
  }

  void _selectAnswer(String optionId) {
    if (_selectedOptionId != null) return;
    final question = _questions[_index];
    setState(() {
      _selectedOptionId = optionId;
      _answers.add(SubmittedAnswer(questionId: question.id, selectedOptionId: optionId));
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _index += 1;
      _selectedOptionId = null;
    });
  }

  Future<void> _finish() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final result = await _service.submitAnswers(widget.challengeId, _answers);
      invalidateUserStats(ref);
      if (!mounted) return;

      final waitingOnOpponent = result['waitingOnOpponent'] == true;
      if (waitingOnOpponent) {
        _showWaitingSheet(
          score: result['score'] ?? 0,
          total: result['totalQuestions'] ?? _questions.length,
          earnedXp: result['earnedXp'] ?? 0,
          earnedCoins: result['earnedCoins'] ?? 0,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChallengeResultsPage(challengeId: widget.challengeId),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = "Couldn't submit your answers - check your connection and try again.";
      });
    }
  }

  void _showWaitingSheet({
    required int score,
    required int total,
    required int earnedXp,
    required int earnedCoins,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏳', style: TextStyle(fontSize: 44)),
                const Gap(12),
                Text(
                  'Answers submitted!',
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
                const Gap(8),
                Text(
                  'You got $score of $total correct.\nWaiting for your opponent to finish - '
                  "you'll see the results once they do.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.subtitle, fontSize: 14),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Pill(label: '+$earnedXp XP', color: AppColors.primary),
                    const Gap(10),
                    _Pill(label: '+$earnedCoins coins', color: AppColors.warning),
                  ],
                ),
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop(); // close the sheet
                      Navigator.of(context).pop(); // leave the play page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: const Text(
                      'Back to Challenges',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.text,
          title: Text(
            '${widget.subjectName} Challenge',
            style: AppTextStyles.title.copyWith(fontSize: 18),
          ),
        ),
        body: SafeArea(child: _body()),
      ),
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
              if (question.topic != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.topic!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
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
                final label = String.fromCharCode(65 + i);
                final isSelected = _selectedOptionId == option.id;

                Color border = const Color(0xFFE5E7EB);
                Color bg = Colors.white;
                Color labelBg = const Color(0xFFF3F4F6);
                Color labelFg = AppColors.subtitle;

                if (isSelected) {
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
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !answered || _submitting ? null : _next,
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
                      isLast ? 'Finish Challenge' : 'Next Question',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color),
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
