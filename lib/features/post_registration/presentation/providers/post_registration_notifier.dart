import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../users/services/users_service.dart';

class PostRegState {
  // Step tracking
  final int step;

  // Step 2 — Arena
  final String classLevel;

  // Step 3 — State
  final String selectedState;

  // Step 4 — Subjects
  final List<String> selectedSubjects;

  // Step 5 — Bonus (from API)
  final int bonusCoins;
  final int bonusXp;
  final bool bonusClaimed;

  // Step 7 — Challenge results (from API)
  final int earnedCoins;
  final int earnedXp;
  final int questionsAnswered;
  final int nationalRank;
  final int stateRank;
  final bool challengeComplete;

  // UI state
  final bool loading;
  final String? error;

  const PostRegState({
    this.step = 0,
    this.classLevel = 'SS1',
    this.selectedState = '',
    this.selectedSubjects = const [],
    this.bonusCoins = 0,
    this.bonusXp = 0,
    this.bonusClaimed = false,
    this.earnedCoins = 0,
    this.earnedXp = 0,
    this.questionsAnswered = 0,
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
    List<String>? selectedSubjects,
    int? bonusCoins,
    int? bonusXp,
    bool? bonusClaimed,
    int? earnedCoins,
    int? earnedXp,
    int? questionsAnswered,
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
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      bonusCoins: bonusCoins ?? this.bonusCoins,
      bonusXp: bonusXp ?? this.bonusXp,
      bonusClaimed: bonusClaimed ?? this.bonusClaimed,
      earnedCoins: earnedCoins ?? this.earnedCoins,
      earnedXp: earnedXp ?? this.earnedXp,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      nationalRank: nationalRank ?? this.nationalRank,
      stateRank: stateRank ?? this.stateRank,
      challengeComplete: challengeComplete ?? this.challengeComplete,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class PostRegNotifier extends Notifier<PostRegState> {
  final _service = UsersService();

  @override
  PostRegState build() => const PostRegState();

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void nextStep() {
    if (state.step < 6) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  // ─── Step 2 — Arena ─────────────────────────────────────────────────────────

  void setClassLevel(String level) =>
      state = state.copyWith(classLevel: level);

  // ─── Step 3 — State ─────────────────────────────────────────────────────────

  void setSelectedState(String s) =>
      state = state.copyWith(selectedState: s);

  // ─── Step 4 — Subjects ──────────────────────────────────────────────────────

  void toggleSubject(String subject) {
    final current = List<String>.from(state.selectedSubjects);
    current.contains(subject)
        ? current.remove(subject)
        : current.add(subject);
    state = state.copyWith(selectedSubjects: current);
  }

  // ─── Save profile (steps 2-4 combined call) ──────────────────────────────────

  Future<bool> saveProfile() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.updateProfile(
        classLevel: state.classLevel,
        state: state.selectedState,
        subjects: state.selectedSubjects,
      );
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  // ─── Step 5 — Claim bonus ────────────────────────────────────────────────────

  Future<bool> claimBonus() async {
    state = state.copyWith(loading: true, error: null);
    try {
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

  // ─── Step 6 — Complete challenge ─────────────────────────────────────────────

  Future<bool> completeChallenge() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await _service.completeStarterChallenge();
      state = state.copyWith(
        loading: false,
        earnedCoins: result['earnedCoins'] ?? 50,
        earnedXp: result['earnedXp'] ?? 50,
        questionsAnswered: result['questionsAnsweredInChallenge'] ?? 5,
        nationalRank: result['nationalRank'] ?? 4872,
        stateRank: result['stateRank'] ?? 312,
        challengeComplete: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const PostRegState();
}

final postRegProvider =
    NotifierProvider<PostRegNotifier, PostRegState>(PostRegNotifier.new);