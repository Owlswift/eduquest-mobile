import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/services/users_service.dart';
import '../../../subjects/services/subjects_service.dart';
import '../../../dashboard/models/dashboard_models.dart';
import '../../../quiz/models/quiz_models.dart';
import '../../../quiz/services/quiz_service.dart';

class PostRegState {
  final int step;
  final String classLevel;
  final String selectedState;
  final List<SubjectModel> availableSubjects;
  final List<String> selectedSubjectIds;
  final int bonusCoins;
  final int bonusXp;
  final bool bonusClaimed;
  final List<QuestionModel> questions;
  final List<SubmittedAnswer> submittedAnswers;
  final int currentQuestionIndex;
  final int timeLeft;
  final bool isChallengeActive;
  final String? selectedAnswerId;
  final bool? answerCorrect;
  final String? revealedCorrectOptionId;
  final int earnedCoins;
  final int earnedXp;
  final int questionsAnswered;
  final int correctAnswers;
  final int nationalRank;
  final int stateRank;
  final bool challengeComplete;
  final bool loading;
  final String? error;

  const PostRegState({
    this.step = 0,
    this.classLevel = 'SS1',
    this.selectedState = '',
    this.availableSubjects = const [],
    this.selectedSubjectIds = const [],
    this.bonusCoins = 0,
    this.bonusXp = 0,
    this.bonusClaimed = false,
    this.questions = const [],
    this.submittedAnswers = const [],
    this.currentQuestionIndex = 0,
    this.timeLeft = 30,
    this.isChallengeActive = false,
    this.selectedAnswerId,
    this.answerCorrect,
    this.revealedCorrectOptionId,
    this.earnedCoins = 0,
    this.earnedXp = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.nationalRank = 0,
    this.stateRank = 0,
    this.challengeComplete = false,
    this.loading = false,
    this.error,
  });

  PostRegState copyWith({
    int? step,
    String? classLevel,
    String? selectedState,
    List<SubjectModel>? availableSubjects,
    List<String>? selectedSubjectIds,
    int? bonusCoins,
    int? bonusXp,
    bool? bonusClaimed,
    List<QuestionModel>? questions,
    List<SubmittedAnswer>? submittedAnswers,
    int? currentQuestionIndex,
    int? timeLeft,
    bool? isChallengeActive,
    String? selectedAnswerId,
    bool? answerCorrect,
    String? revealedCorrectOptionId,
    int? earnedCoins,
    int? earnedXp,
    int? questionsAnswered,
    int? correctAnswers,
    int? nationalRank,
    int? stateRank,
    bool? challengeComplete,
    bool? loading,
    String? error,
  }) {
    return PostRegState(
      step: step ?? this.step,
      classLevel: classLevel ?? this.classLevel,
      selectedState: selectedState ?? this.selectedState,
      availableSubjects: availableSubjects ?? this.availableSubjects,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      bonusCoins: bonusCoins ?? this.bonusCoins,
      bonusXp: bonusXp ?? this.bonusXp,
      bonusClaimed: bonusClaimed ?? this.bonusClaimed,
      questions: questions ?? this.questions,
      submittedAnswers: submittedAnswers ?? this.submittedAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isChallengeActive: isChallengeActive ?? this.isChallengeActive,
      selectedAnswerId: selectedAnswerId,
      answerCorrect: answerCorrect,
      revealedCorrectOptionId: revealedCorrectOptionId ?? this.revealedCorrectOptionId,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      earnedXp: earnedXp ?? this.earnedXp,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      nationalRank: nationalRank ?? this.nationalRank,
      stateRank: stateRank ?? this.stateRank,
      challengeComplete: challengeComplete ?? this.challengeComplete,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  // Helper for resetting nullable fields to null while keeping others
  PostRegState copyWithReset({
    int? currentQuestionIndex,
    int? timeLeft,
    int? questionsAnswered,
    String? selectedAnswerId,
    bool? answerCorrect,
    String? revealedCorrectOptionId,
  }) {
    return PostRegState(
      step: this.step,
      classLevel: this.classLevel,
      selectedState: this.selectedState,
      availableSubjects: this.availableSubjects,
      selectedSubjectIds: this.selectedSubjectIds,
      bonusCoins: this.bonusCoins,
      bonusXp: this.bonusXp,
      bonusClaimed: this.bonusClaimed,
      questions: this.questions,
      submittedAnswers: this.submittedAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isChallengeActive: this.isChallengeActive,
      selectedAnswerId: selectedAnswerId,
      answerCorrect: answerCorrect,
      revealedCorrectOptionId: revealedCorrectOptionId,
      earnedCoins: this.earnedCoins,
      earnedXp: this.earnedXp,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: this.correctAnswers,
      nationalRank: this.nationalRank,
      stateRank: this.stateRank,
      challengeComplete: this.challengeComplete,
      loading: this.loading,
      error: this.error,
    );
  }
}

class PostRegNotifier extends Notifier<PostRegState> {
  final _service = UsersService();
  final _subjectsService = SubjectsService();
  final _quizService = QuizService();

  // Guard — prevents _completeChallenge being called more than once
  bool _isSubmitting = false;

  @override
  PostRegState build() {
    Future.microtask(() => loadSubjects());
    return const PostRegState();
  }

  // ─── Load subjects ────────────────────────────────────────────────────────

  Future<void> loadSubjects() async {
    try {
      final subjects = await _subjectsService.getSubjects();
      state = state.copyWith(availableSubjects: subjects);
    } catch (_) {
      state = state.copyWith(availableSubjects: []);
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void nextStep() {
    if (state.step < 6) state = state.copyWith(step: state.step + 1);
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  // ─── Step 2 ───────────────────────────────────────────────────────────────

  void setClassLevel(String level) => state = state.copyWith(classLevel: level);

  // ─── Step 3 ───────────────────────────────────────────────────────────────

  void setSelectedState(String s) => state = state.copyWith(selectedState: s);

  // ─── Step 4 ───────────────────────────────────────────────────────────────

  void toggleSubject(String subjectId) {
    final current = List<String>.from(state.selectedSubjectIds);
    current.contains(subjectId)
        ? current.remove(subjectId)
        : current.add(subjectId);
    state = state.copyWith(selectedSubjectIds: current);
  }

  // ─── Save profile ─────────────────────────────────────────────────────────

  Future<bool> saveProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.updateProfile(
        classLevel: state.classLevel,
        state: state.selectedState,
        subjects: state.selectedSubjectIds,
      );
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ─── Step 5 — Claim bonus ─────────────────────────────────────────────────

  Future<bool> claimBonus() async {
    state = state.copyWith(loading: true, error: null);
    try {
      if (state.classLevel.isNotEmpty && state.selectedState.isNotEmpty) {
        await _service.updateProfile(
          classLevel: state.classLevel,
          state: state.selectedState,
          subjects: state.selectedSubjectIds,
        );
      }
      final result = await _service.claimWelcomeBonus();
      state = state.copyWith(
        loading: false,
        bonusCoins: result['bonusCoins'] ?? 100,
        bonusXp: result['bonusXp'] ?? 50,
        bonusClaimed: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ─── Step 6 — Start challenge ─────────────────────────────────────────────

  Future<bool> startChallenge() async {
    _isSubmitting = false; // reset guard for new challenge
    state = state.copyWith(loading: true, error: null);
    try {
      final subjectId = state.selectedSubjectIds.isNotEmpty
          ? state.selectedSubjectIds.first
          : 'math';

      final questions = await _quizService.getRandomQuestions(
        subjectId: subjectId,
        count: 10,
        classLevel: state.classLevel,
      );

      state = state.copyWith(
        loading: false,
        questions: questions,
        submittedAnswers: const [],
        currentQuestionIndex: 0,
        timeLeft: 30,
        isChallengeActive: true,
        correctAnswers: 0,
        questionsAnswered: 0,
        selectedAnswerId: null,
        answerCorrect: null,
        challengeComplete: false,
        earnedCoins: 0,
        earnedXp: 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ─── Select answer ────────────────────────────────────────────────────────

  Future<void> selectAnswer(String answerId) async {
    // Guard: ignore if already answered
    if (state.selectedAnswerId != null) return;

    final question = state.questions[state.currentQuestionIndex];
    final answers = List<SubmittedAnswer>.from(state.submittedAnswers)
      ..add(SubmittedAnswer(questionId: question.id, selectedOptionId: answerId));

    // Show the pick immediately (isCorrect unknown yet) so the tap feels
    // responsive, then fill in right/wrong once the server confirms it.
    state = state.copyWith(
      selectedAnswerId: answerId,
      submittedAnswers: answers,
      questionsAnswered: state.questionsAnswered + 1,
    );

    try {
      final check = await _quizService.checkAnswer(
        questionId: question.id,
        selectedOptionId: answerId,
      );
      // Guard: the student may have already moved to the next question
      // (e.g. slow network) - don't stamp a stale result onto it.
      if (state.selectedAnswerId != answerId) return;
      state = state.copyWith(
        answerCorrect: check.correct,
        revealedCorrectOptionId: check.correctOptionId,
        correctAnswers: state.correctAnswers + (check.correct ? 1 : 0),
      );
    } catch (_) {
      // Feedback is cosmetic here - real grading happens server-side on
      // submit regardless, so a failed check just leaves this question's
      // color neutral instead of blocking progress.
    }
  }

  // ─── Advance to next question ─────────────────────────────────────────────
  // Called by screen ONLY for questions that are NOT the last one.
  // The screen handles the "last question" case by calling finishAndShowResults().

  void nextQuestion() {
    if (state.currentQuestionIndex >= state.questions.length - 1) return;

    state = state.copyWithReset(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      timeLeft: 30,
      selectedAnswerId: null,
      answerCorrect: null,
    );
  }

  // ─── Timer tick ───────────────────────────────────────────────────────────

  void tick() {
    // Don't tick if answered, challenge done, or submitting
    if (state.selectedAnswerId != null) return;
    if (state.challengeComplete || _isSubmitting) return;

    if (state.timeLeft > 1) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else {
      // Time's up on this question - record it as unanswered (an empty
      // selectedOptionId just won't match any correctAnswerId server-side).
      final question = state.questions[state.currentQuestionIndex];
      final answers = List<SubmittedAnswer>.from(state.submittedAnswers)
        ..add(SubmittedAnswer(questionId: question.id, selectedOptionId: ''));
      state = state.copyWith(submittedAnswers: answers);

      if (state.currentQuestionIndex < state.questions.length - 1) {
        // Not last question — advance
        state = state.copyWithReset(
          currentQuestionIndex: state.currentQuestionIndex + 1,
          timeLeft: 30,
          selectedAnswerId: null,
          answerCorrect: null,
          questionsAnswered: state.questionsAnswered + 1,
        );
      } else {
        // Last question timed out — submit
        finishAndShowResults();
      }
    }
  }

  // ─── Reset answer state for new question ──────────────────────────────────

  void resetAnswerState() {
    state = state.copyWithReset(
      selectedAnswerId: null,
      answerCorrect: null,
    );
  }

  // ─── Finish challenge and submit to backend ───────────────────────────────
  // Called by the screen when user taps "See Results" on the last question,
  // OR automatically when the last question times out.

  Future<void> finishAndShowResults() async {
    // Guard: only run once
    if (_isSubmitting) return;
    _isSubmitting = true;

    state = state.copyWith(
      isChallengeActive: false,
      loading: true,
      error: null,
    );

    try {
      final result = await _service.completeStarterChallenge(state.submittedAnswers);
      state = state.copyWith(
        loading: false,
        earnedCoins: result['earnedCoins'] ?? 0,
        earnedXp: result['earnedXp'] ?? 0,
        correctAnswers: result['correctAnswers'] ?? state.correctAnswers,
        questionsAnswered: state.questionsAnswered,
        nationalRank: result['nationalRank'] ?? 1,
        stateRank: result['stateRank'] ?? 1,
        // Set challengeComplete LAST — this triggers the listener in the screen
        challengeComplete: true,
      );
    } catch (e) {
      // Don't fabricate a fake "success" result - the coins/XP shown would
      // be lies if the server call actually failed. Let the screen show a
      // real error and offer to retry instead.
      _isSubmitting = false;
      state = state.copyWith(
        loading: false,
        isChallengeActive: false,
        error: "Couldn't submit your results - check your connection and try again.",
      );
    }
  }

  void reset() {
    _isSubmitting = false;
    state = const PostRegState();
  }
}

final postRegProvider =
    NotifierProvider<PostRegNotifier, PostRegState>(PostRegNotifier.new);