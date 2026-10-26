/// Who I am in one Challenge - drives which topics/score are "mine" vs
/// "theirs" on a summary/detail response.
enum ChallengeRole { challenger, opponent }

ChallengeRole _roleFromJson(String? value) =>
    value == 'opponent' ? ChallengeRole.opponent : ChallengeRole.challenger;

enum ChallengeStatus { pending, active, completed, declined, unknown }

ChallengeStatus _statusFromJson(String? value) {
  switch (value) {
    case 'PENDING':
      return ChallengeStatus.pending;
    case 'ACTIVE':
      return ChallengeStatus.active;
    case 'COMPLETED':
      return ChallengeStatus.completed;
    case 'DECLINED':
      return ChallengeStatus.declined;
    default:
      return ChallengeStatus.unknown;
  }
}

class ChallengeOpponent {
  final String id;
  final String name;

  const ChallengeOpponent({required this.id, required this.name});

  factory ChallengeOpponent.fromJson(Map<String, dynamic> json) {
    return ChallengeOpponent(id: json['id'] ?? '', name: json['name'] ?? 'Student');
  }
}

/// One row of GET /challenges - everything a list tile needs without a
/// second round trip.
class ChallengeSummary {
  final String id;
  final String subjectId;
  final String subjectName;
  final ChallengeRole role;
  final ChallengeOpponent opponent;
  final ChallengeStatus status;
  final List<String> myTopics;
  final List<String> theirTopics;
  final int? myScore;
  final int? theirScore;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ChallengeSummary({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.role,
    required this.opponent,
    required this.status,
    required this.myTopics,
    required this.theirTopics,
    this.myScore,
    this.theirScore,
    required this.createdAt,
    this.completedAt,
  });

  factory ChallengeSummary.fromJson(Map<String, dynamic> json) {
    return ChallengeSummary(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      role: _roleFromJson(json['role']),
      opponent: ChallengeOpponent.fromJson(json['opponent'] ?? const {}),
      status: _statusFromJson(json['status']),
      myTopics: ((json['myTopics'] as List<dynamic>?) ?? const []).cast<String>(),
      theirTopics: ((json['theirTopics'] as List<dynamic>?) ?? const []).cast<String>(),
      myScore: json['myScore'],
      theirScore: json['theirScore'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
    );
  }
}

/// GET /challenges/:id - the full picture for one challenge, including
/// whether the opponent has picked their topics yet.
class ChallengeDetail {
  final String id;
  final String subjectId;
  final String subjectName;
  final String classLevel;
  final ChallengeRole role;
  final ChallengeOpponent opponent;
  final ChallengeStatus status;
  final List<String> challengerTopics;
  final List<String>? opponentTopics;
  final int questionCount;
  final int? myScore;
  final int? theirScore;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;

  const ChallengeDetail({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.classLevel,
    required this.role,
    required this.opponent,
    required this.status,
    required this.challengerTopics,
    this.opponentTopics,
    required this.questionCount,
    this.myScore,
    this.theirScore,
    required this.createdAt,
    this.respondedAt,
    this.completedAt,
  });

  /// The topics *I* picked (challenger's own list, or my response once
  /// I've answered as the opponent).
  List<String> get myTopics => role == ChallengeRole.challenger ? challengerTopics : (opponentTopics ?? const []);

  /// The topics the *other* player picked - null if they haven't
  /// responded yet (only possible when I'm the challenger).
  List<String>? get theirTopics => role == ChallengeRole.challenger ? opponentTopics : challengerTopics;

  /// True once I've submitted my answers (score is only ever set once
  /// grading happens server-side on submit).
  bool get iHaveAnswered => myScore != null;

  factory ChallengeDetail.fromJson(Map<String, dynamic> json) {
    return ChallengeDetail(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      classLevel: json['classLevel'] ?? 'SS1',
      role: _roleFromJson(json['role']),
      opponent: ChallengeOpponent.fromJson(json['opponent'] ?? const {}),
      status: _statusFromJson(json['status']),
      challengerTopics: ((json['challengerTopics'] as List<dynamic>?) ?? const []).cast<String>(),
      opponentTopics: (json['opponentTopics'] as List<dynamic>?)?.cast<String>(),
      questionCount: json['questionCount'] ?? 0,
      myScore: json['myScore'],
      theirScore: json['theirScore'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      respondedAt: json['respondedAt'] != null ? DateTime.tryParse(json['respondedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
    );
  }
}

class ChallengeOption {
  final String id;
  final String text;

  const ChallengeOption({required this.id, required this.text});

  factory ChallengeOption.fromJson(Map<String, dynamic> json) {
    return ChallengeOption(id: json['id'] ?? '', text: json['text'] ?? '');
  }
}

/// One question in a challenge's frozen pool, with options in *this*
/// player's own randomized order. Never carries the correct answer -
/// grading happens server-side on submit.
class ChallengeQuestion {
  final String id;
  final String? topic;
  final String questionText;
  final String? explanation;
  final int difficulty;
  final List<ChallengeOption> options;

  const ChallengeQuestion({
    required this.id,
    this.topic,
    required this.questionText,
    this.explanation,
    this.difficulty = 1,
    required this.options,
  });

  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      id: json['id'] ?? '',
      topic: json['topic'],
      questionText: json['questionText'] ?? '',
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 1,
      options: ((json['options'] as List<dynamic>?) ?? const [])
          .map((o) => ChallengeOption.fromJson(o))
          .toList(),
    );
  }
}

/// One player's side of a finished challenge's results screen.
class ChallengeResultSide {
  final String id;
  final String name;
  final bool won;
  final int correctCount;
  final int totalQuestions;
  final int earnedXp;
  final int earnedCoins;

  const ChallengeResultSide({
    required this.id,
    required this.name,
    required this.won,
    required this.correctCount,
    required this.totalQuestions,
    required this.earnedXp,
    required this.earnedCoins,
  });

  factory ChallengeResultSide.fromJson(Map<String, dynamic> json) {
    return ChallengeResultSide(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Student',
      won: json['won'] ?? false,
      correctCount: json['correctCount'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      earnedXp: json['earnedXp'] ?? 0,
      earnedCoins: json['earnedCoins'] ?? 0,
    );
  }
}

class ChallengeResults {
  final String subjectId;
  final bool isDraw;
  final ChallengeResultSide challenger;
  final ChallengeResultSide opponent;

  const ChallengeResults({
    required this.subjectId,
    required this.isDraw,
    required this.challenger,
    required this.opponent,
  });

  factory ChallengeResults.fromJson(Map<String, dynamic> json) {
    return ChallengeResults(
      subjectId: json['subjectId'] ?? '',
      isDraw: json['isDraw'] ?? false,
      challenger: ChallengeResultSide.fromJson(json['challenger'] ?? const {}),
      opponent: ChallengeResultSide.fromJson(json['opponent'] ?? const {}),
    );
  }
}

/// One entry in GET /challenges/suggestions - a candidate opponent picked
/// by the matchmaking algorithm (similar subject ability, topic overlap,
/// recent activity). Shown pseudonymously - real names only appear once
/// a challenge actually exists between two students.
class SuggestedOpponent {
  final String userId;
  final String pseudonym;
  final int? abilityPercent;
  final bool activeToday;

  const SuggestedOpponent({
    required this.userId,
    required this.pseudonym,
    this.abilityPercent,
    required this.activeToday,
  });

  factory SuggestedOpponent.fromJson(Map<String, dynamic> json) {
    return SuggestedOpponent(
      userId: json['userId'] ?? '',
      pseudonym: json['pseudonym'] ?? 'Student',
      abilityPercent: json['abilityPercent'],
      activeToday: json['activeToday'] ?? false,
    );
  }
}

class ChallengeSuggestions {
  final List<SuggestedOpponent> recommended;
  final List<SuggestedOpponent> discover;

  const ChallengeSuggestions({required this.recommended, required this.discover});

  factory ChallengeSuggestions.fromJson(Map<String, dynamic> json) {
    return ChallengeSuggestions(
      recommended: ((json['recommended'] as List<dynamic>?) ?? const [])
          .map((s) => SuggestedOpponent.fromJson(s))
          .toList(),
      discover: ((json['discover'] as List<dynamic>?) ?? const [])
          .map((s) => SuggestedOpponent.fromJson(s))
          .toList(),
    );
  }
}

/// GET /users/search - a candidate opponent.
class ChallengeOpponentCandidate {
  final String id;
  /// First name and surname initial only ("Ola L."): the server never sends another student's full name, username or photo.
  final String fullName;
  final String classLevel;
  /// False if this student can't actually be challenged right now (a
  /// different class level, or an open challenge already exists between
  /// them and the caller for this subject) - still shown, not hidden,
  /// so search doesn't look like it silently can't find someone.
  final bool eligible;
  final String? ineligibleReason;

  const ChallengeOpponentCandidate({
    required this.id,
    required this.fullName,
    required this.classLevel,
    this.eligible = true,
    this.ineligibleReason,
  });

  factory ChallengeOpponentCandidate.fromJson(Map<String, dynamic> json) {
    return ChallengeOpponentCandidate(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      classLevel: json['classLevel'] ?? 'SS1',
      eligible: json['eligible'] ?? true,
      ineligibleReason: json['ineligibleReason'],
    );
  }
}
