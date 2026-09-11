/// GET /users/subject-progress - average tutor mastery per subject the
/// student has actually studied. Never fabricated: a subject the student
/// hasn't touched simply doesn't appear.
class SubjectProgressEntry {
  final String subjectId;
  final String subjectName;
  final double progress;

  const SubjectProgressEntry({
    required this.subjectId,
    required this.subjectName,
    required this.progress,
  });

  factory SubjectProgressEntry.fromJson(Map<String, dynamic> json) {
    return SubjectProgressEntry(
      subjectId: (json['subjectId'] as String?) ?? '',
      subjectName: (json['subjectName'] as String?) ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}
