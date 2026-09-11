/// GET /users/daily-summary - backs the Learn screen's streak strip and
/// "Today's Goal" card.
class DailySummary {
  final int streak;
  final int goalTarget;
  final int goalAnswered;
  final int goalPercent;
  final List<DayActivity> week;

  const DailySummary({
    required this.streak,
    required this.goalTarget,
    required this.goalAnswered,
    required this.goalPercent,
    required this.week,
  });

  static const empty = DailySummary(
    streak: 0,
    goalTarget: 20,
    goalAnswered: 0,
    goalPercent: 0,
    week: [],
  );

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final goal = (json['goal'] as Map<String, dynamic>?) ?? const {};
    return DailySummary(
      streak: json['streak'] ?? 0,
      goalTarget: goal['target'] ?? 20,
      goalAnswered: goal['answeredToday'] ?? 0,
      goalPercent: goal['percent'] ?? 0,
      week: ((json['week'] as List<dynamic>?) ?? const [])
          .map((d) => DayActivity.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DayActivity {
  final String date;
  final String weekday;
  final bool studied;
  final bool isToday;

  const DayActivity({
    required this.date,
    required this.weekday,
    required this.studied,
    required this.isToday,
  });

  factory DayActivity.fromJson(Map<String, dynamic> json) {
    return DayActivity(
      date: json['date'] ?? '',
      weekday: json['weekday'] ?? '',
      studied: json['studied'] ?? false,
      isToday: json['isToday'] ?? false,
    );
  }
}
