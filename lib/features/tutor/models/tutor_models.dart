/// A single curriculum topic, as returned by GET /curriculum/topics.
/// Only the fields the topic picker needs are parsed - the full row also
/// carries performanceObjectives/content/etc. used server-side by the tutor.
class CurriculumTopicSummary {
  final String id;
  final String subjectId;
  final String classLevel;
  final String theme;
  final String topic;

  CurriculumTopicSummary({
    required this.id,
    required this.subjectId,
    required this.classLevel,
    required this.theme,
    required this.topic,
  });

  factory CurriculumTopicSummary.fromJson(Map<String, dynamic> json) {
    return CurriculumTopicSummary(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      classLevel: json['classLevel'] ?? '',
      theme: json['theme'] ?? '',
      topic: json['topic'] ?? '',
    );
  }
}

/// One renderable content block within a tutor message. The backend already
/// decides which block types to use (explanation/analogy/quiz/diagram/etc.) -
/// the client's only job is to render each type appropriately.
class TutorBlock {
  final String type;
  final String content;
  final List<String>? options;
  final int? correctOptionIndex;
  final List<String>? diagramLabels;
  final String? mermaidCode;
  final String? back;

  TutorBlock({
    required this.type,
    required this.content,
    this.options,
    this.correctOptionIndex,
    this.diagramLabels,
    this.mermaidCode,
    this.back,
  });

  factory TutorBlock.fromJson(Map<String, dynamic> json) {
    return TutorBlock(
      type: json['type'] ?? 'explanation',
      content: json['content'] ?? '',
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctOptionIndex: json['correctOptionIndex'],
      diagramLabels: (json['diagramLabels'] as List<dynamic>?)?.cast<String>(),
      mermaidCode: json['mermaidCode'],
      back: json['back'],
    );
  }
}

class TutorMessage {
  final String id;
  final String sessionId;
  final String role; // 'TUTOR' | 'STUDENT'
  final String content;
  final List<TutorBlock> blocks;
  final String stateAt;
  final DateTime createdAt;

  TutorMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.blocks,
    required this.stateAt,
    required this.createdAt,
  });

  bool get isTutor => role == 'TUTOR';

  factory TutorMessage.fromJson(Map<String, dynamic> json) {
    final rawBlocks = json['blocks'];
    return TutorMessage(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      role: json['role'] ?? 'TUTOR',
      content: json['content'] ?? '',
      blocks: rawBlocks is List
          ? rawBlocks
              .map((b) => TutorBlock.fromJson(b as Map<String, dynamic>))
              .toList()
          : const [],
      stateAt: json['stateAt'] ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class TutorSession {
  final String id;
  final String subjectId;
  final String classLevel;
  final String topicId;
  final String state;
  final DateTime? completedAt;

  TutorSession({
    required this.id,
    required this.subjectId,
    required this.classLevel,
    required this.topicId,
    required this.state,
    this.completedAt,
  });

  bool get isCompleted => state == 'COMPLETED';

  factory TutorSession.fromJson(Map<String, dynamic> json) {
    return TutorSession(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      classLevel: json['classLevel'] ?? '',
      topicId: json['topicId'] ?? '',
      state: json['state'] ?? 'INTRODUCTION',
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
    );
  }
}

/// Result of starting a session or posting a message: the updated session
/// plus the new tutor turn(s). `completionMessage` is only present the one
/// turn a lesson finishes (encouragement + flashcards wrap-up).
class TutorTurnResult {
  final TutorSession session;
  final TutorMessage message;
  final TutorMessage? completionMessage;
  final String? transcript;

  /// Present when starting a session resumes an existing in-progress one -
  /// the full conversation history to restore, instead of just the latest
  /// turn. Null for a normal new-session or postMessage response.
  final List<TutorMessage>? messages;

  TutorTurnResult({
    required this.session,
    required this.message,
    this.completionMessage,
    this.transcript,
    this.messages,
  });

  factory TutorTurnResult.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    return TutorTurnResult(
      session: TutorSession.fromJson(json['session']),
      message: TutorMessage.fromJson(json['message']),
      completionMessage: json['completionMessage'] != null
          ? TutorMessage.fromJson(json['completionMessage'])
          : null,
      transcript: json['transcript'],
      messages: rawMessages is List
          ? rawMessages
              .map((m) => TutorMessage.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class Flashcard {
  final String front;
  final String back;

  Flashcard({required this.front, required this.back});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(front: json['front'] ?? '', back: json['back'] ?? '');
  }
}
