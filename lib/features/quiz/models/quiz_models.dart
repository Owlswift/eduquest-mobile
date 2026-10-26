class QuestionModel {
  final String id;

  /// The server-issued quiz session this question belongs to. Checking and
  /// submitting answers only works against it.
  final String sessionId;
  final String subjectId;
  final String questionText;
  final List<AnswerOption> options;
  final String? explanation;
  final int difficulty; // 1-5
  final String classLevel;

  const QuestionModel({
    required this.id,
    this.sessionId = '',
    required this.subjectId,
    required this.questionText,
    required this.options,
    this.explanation,
    this.difficulty = 1,
    required this.classLevel,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      subjectId: json['subjectId'] ?? json['subject_id'] ?? '',
      questionText: json['questionText'] ?? json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((opt) => AnswerOption.fromJson(opt))
          .toList() ?? [],
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 1,
      classLevel: json['classLevel'] ?? json['class_level'] ?? 'SS1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'subjectId': subjectId,
      'questionText': questionText,
      'options': options.map((opt) => opt.toJson()).toList(),
      'explanation': explanation,
      'difficulty': difficulty,
      'classLevel': classLevel,
    };
  }
}

/// One answer a student picked for one question - the unit both the main
/// quiz submit and the starter-challenge submit send to the backend for
/// server-side grading. The server is the only place that knows what's
/// actually correct.
class SubmittedAnswer {
  final String questionId;
  final String selectedOptionId;

  const SubmittedAnswer({required this.questionId, required this.selectedOptionId});

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
      };
}

/// One topic tagged on a subject's question bank, with how many questions
/// exist for it - powers the Challenges topic picker. A subject that
/// isn't topic-tagged yet just returns an empty list.
class TopicOption {
  final String topic;
  final int questionCount;

  const TopicOption({required this.topic, required this.questionCount});

  factory TopicOption.fromJson(Map<String, dynamic> json) {
    return TopicOption(
      topic: json['topic'] ?? '',
      questionCount: json['questionCount'] ?? 0,
    );
  }
}

class AnswerOption {
  final String id;
  final String text;
  final String? imageUrl;

  const AnswerOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
    };
  }
}