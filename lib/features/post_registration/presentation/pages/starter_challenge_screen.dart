import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/post_registration_notifier.dart';

const _blue = Color(0xFF2B5CE6);
const _darkText = Color(0xFF0D1B3E);
const _greyText = Color(0xFF6B7280);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _borderGrey = Color(0xFFE5E7EB);

class StarterChallengeScreen extends ConsumerStatefulWidget {
  const StarterChallengeScreen({super.key});

  @override
  ConsumerState<StarterChallengeScreen> createState() =>
      _StarterChallengeScreenState();
}

class _StarterChallengeScreenState
    extends ConsumerState<StarterChallengeScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _timerAnimController;

  // Track which question the timer is running for
  // to prevent stale ticks from affecting new questions
  int _timerQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _timerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _startTimerForCurrentQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerAnimController.dispose();
    super.dispose();
  }

  void _startTimerForCurrentQuestion() {
    _timer?.cancel();
    _timerAnimController.forward(from: 0);
    final questionIndex = ref.read(postRegProvider).currentQuestionIndex;
    _timerQuestionIndex = questionIndex;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final state = ref.read(postRegProvider);
      // Only tick if we're still on the same question and it's unanswered
      if (state.currentQuestionIndex != _timerQuestionIndex) return;
      if (state.selectedAnswerId != null) return;
      if (state.challengeComplete) return;
      ref.read(postRegProvider.notifier).tick();
    });
  }

  void _onAnswerTap(String answerId) {
    final state = ref.read(postRegProvider);
    if (state.selectedAnswerId != null) return;
    if (state.challengeComplete) return;

    HapticFeedback.lightImpact();

    // Stop timer — user answered in time
    _timer?.cancel();
    _timerAnimController.stop();

    ref.read(postRegProvider.notifier).selectAnswer(answerId);
  }

  void _onNext() {
    final state = ref.read(postRegProvider);

    // Last question — go to results
    if (state.currentQuestionIndex >= state.questions.length - 1) {
      _timer?.cancel();
      _timerAnimController.stop();
      ref.read(postRegProvider.notifier).finishAndShowResults();
      return;
    }

    HapticFeedback.lightImpact();

    // Advance to next question then restart timer
    ref.read(postRegProvider.notifier).nextQuestion();

    // Small delay so state updates before timer starts
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _startTimerForCurrentQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postRegProvider);

    // Restart timer when question auto-advances (e.g., timeout)
    if (state.currentQuestionIndex != _timerQuestionIndex &&
        state.selectedAnswerId == null &&
        !state.challengeComplete) {
      _startTimerForCurrentQuestion();
    }

    // Navigate to results step when API call completes
    ref.listen(postRegProvider, (prev, next) {
      if (prev?.challengeComplete == false && next.challengeComplete == true) {
        if (mounted) {
          Navigator.of(context).pop(); // pop quiz screen
          ref.read(postRegProvider.notifier).nextStep(); // advance to step 7
        }
      }
    });

    if (state.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _blue)),
      );
    }

    final question = state.questions[state.currentQuestionIndex];
    final totalQuestions = state.questions.length;
    final current = state.currentQuestionIndex + 1;
    final isLastQuestion = state.currentQuestionIndex >= totalQuestions - 1;
    final hasAnswered = state.selectedAnswerId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => _showExitDialog(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: _darkText, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Progress bar + counter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question $current of $totalQuestions',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _greyText),
                            ),
                            Text(
                              '${state.correctAnswers} correct',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: current / totalQuestions,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_blue),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Timer circle
                  _TimerCircle(
                    timeLeft: state.timeLeft,
                    controller: _timerAnimController,
                  ),
                ],
              ),
            ),

            // ── Question + Options ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(8),

                    // Difficulty dots
                    Row(
                      children: List.generate(5, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < question.difficulty
                                ? _blue
                                : const Color(0xFFE5E7EB),
                          ),
                        );
                      }),
                    ),

                    const Gap(14),

                    // Question text
                    Text(
                      question.questionText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                        height: 1.4,
                      ),
                    ),

                    const Gap(28),

                    // Answer options
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final label = ['A', 'B', 'C', 'D'][index];
                      final isSelected = state.selectedAnswerId == option.id;
                      final isCorrect =
                          option.id == question.correctAnswerId;

                      // Colors depend on answered state
                      Color borderColor;
                      Color bgColor;
                      Color labelBg;
                      Color labelColor;
                      Widget? trailing;

                      if (!hasAnswered) {
                        // No answer yet — all options neutral
                        borderColor = _borderGrey;
                        bgColor = Colors.white;
                        labelBg = const Color(0xFFF3F4F6);
                        labelColor = _greyText;
                      } else if (isCorrect) {
                        // Always highlight correct answer in green
                        borderColor = _green;
                        bgColor = const Color(0xFFF0FDF4);
                        labelBg = _green;
                        labelColor = Colors.white;
                        trailing = const Icon(Icons.check_circle_rounded,
                            color: _green, size: 22);
                      } else if (isSelected) {
                        // Wrong selected answer — red
                        borderColor = _red;
                        bgColor = const Color(0xFFFFF5F5);
                        labelBg = _red;
                        labelColor = Colors.white;
                        trailing = const Icon(Icons.cancel_rounded,
                            color: _red, size: 22);
                      } else {
                        // Other unselected wrong answers — dim
                        borderColor = const Color(0xFFE5E7EB);
                        bgColor = const Color(0xFFFAFAFA);
                        labelBg = const Color(0xFFEEEEEE);
                        labelColor = const Color(0xFFBBBBBB);
                      }

                      return GestureDetector(
                        // Key point: only disable if already answered
                        onTap: hasAnswered
                            ? null
                            : () => _onAnswerTap(option.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: borderColor,
                              width: hasAnswered &&
                                      (isCorrect || isSelected)
                                  ? 2
                                  : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: labelBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: labelColor,
                                      )),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: hasAnswered &&
                                            (isCorrect || isSelected)
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: hasAnswered && !isCorrect && !isSelected
                                        ? const Color(0xFFBBBBBB)
                                        : _darkText,
                                  ),
                                ),
                              ),
                              if (trailing != null) ...[
                                const SizedBox(width: 8),
                                trailing,
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    // Explanation (shown after answering)
                    if (hasAnswered && question.explanation != null) ...[
                      const Gap(4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: state.answerCorrect == true
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.answerCorrect == true
                                ? _green.withOpacity(0.3)
                                : _red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              state.answerCorrect == true
                                  ? Icons.lightbulb_rounded
                                  : Icons.info_rounded,
                              color: state.answerCorrect == true
                                  ? _green
                                  : _red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.explanation!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: state.answerCorrect == true
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF991B1B),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Gap(100),
                  ],
                ),
              ),
            ),

            // ── Next / See Results button ─────────────────────────────────────
            AnimatedSlide(
              offset: hasAnswered ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: hasAnswered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      // Always enabled when hasAnswered is true
                      onPressed: hasAnswered ? _onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.answerCorrect == true
                            ? _green
                            : _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: state.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastQuestion
                                      ? 'See Results 🎉'
                                      : 'Next Question',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Challenge?',
            style:
                TextStyle(fontWeight: FontWeight.w700, color: _darkText)),
        content: const Text(
          'Your progress will be lost. Are you sure?',
          style: TextStyle(color: _greyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue', style: TextStyle(color: _blue)),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(ctx);
              Navigator.of(context).pop(); // pop quiz screen
            },
            child: const Text('Exit', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }
}

// ─── Timer Circle ─────────────────────────────────────────────────────────────

class _TimerCircle extends StatelessWidget {
  final int timeLeft;
  final AnimationController controller;

  const _TimerCircle({required this.timeLeft, required this.controller});

  Color get _color {
    if (timeLeft > 15) return _blue;
    if (timeLeft > 7) return const Color(0xFFF59E0B);
    return _red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => CircularProgressIndicator(
              value: 1 - controller.value,
              strokeWidth: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
            child: Text('$timeLeft'),
          ),
        ],
      ),
    );
  }
}