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
  final int currentQuestionIndex;
  final int timeLeft;
  final bool isChallengeActive;
  final String? selectedAnswerId;
  final bool? answerCorrect;
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
    this.currentQuestionIndex = 0,
    this.timeLeft = 30,
    this.isChallengeActive = false,
    this.selectedAnswerId,
    this.answerCorrect,
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
    int? currentQuestionIndex,
    int? timeLeft,
    bool? isChallengeActive,
    String? selectedAnswerId,
    bool? answerCorrect,
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
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isChallengeActive: isChallengeActive ?? this.isChallengeActive,
      selectedAnswerId: selectedAnswerId,
      answerCorrect: answerCorrect,
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
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isChallengeActive: this.isChallengeActive,
      selectedAnswerId: selectedAnswerId,
      answerCorrect: answerCorrect,
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

  void selectAnswer(String answerId) {
    // Guard: ignore if already answered
    if (state.selectedAnswerId != null) return;

    final question = state.questions[state.currentQuestionIndex];
    final isCorrect = question.correctAnswerId == answerId;

    state = state.copyWith(
      selectedAnswerId: answerId,
      answerCorrect: isCorrect,
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
    );
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
      // Time's up on this question
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
      final result = await _service.completeStarterChallenge();
      state = state.copyWith(
        loading: false,
        earnedCoins: result['earnedCoins'] ?? state.correctAnswers * 10,
        earnedXp: result['earnedXp'] ?? state.correctAnswers * 10,
        questionsAnswered: state.questionsAnswered,
        nationalRank: result['nationalRank'] ?? 1,
        stateRank: result['stateRank'] ?? 1,
        // Set challengeComplete LAST — this triggers the listener in the screen
        challengeComplete: true,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        earnedCoins: state.correctAnswers * 10,
        earnedXp: state.correctAnswers * 10,
        nationalRank: 1,
        stateRank: 1,
        challengeComplete: true,
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