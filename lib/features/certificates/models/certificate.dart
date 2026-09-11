/// GET /certificates - auto-awarded once a student's average mastery in a
/// subject crosses the threshold across enough studied topics.
class Certificate {
  final String id;
  final String subjectId;
  final String subjectName;
  final DateTime earnedAt;

  const Certificate({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.earnedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      earnedAt: DateTime.tryParse(json['earnedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
