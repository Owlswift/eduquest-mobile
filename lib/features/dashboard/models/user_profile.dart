/// The subset of GET /users/me the Home and Profile tabs render.
class UserProfile {
  final String fullName;
  final String username;
  final int coins;
  final int xp;
  final int maxXp;
  final int level;
  final int streak;
  final int badges;
  final int certificates;
  final int questionsAnswered;
  final double accuracy;
  final int timeSpentMinutes;
  final List<String> subjects;

  const UserProfile({
    required this.fullName,
    this.username = '',
    required this.coins,
    required this.xp,
    required this.maxXp,
    required this.level,
    required this.streak,
    this.badges = 0,
    this.certificates = 0,
    this.questionsAnswered = 0,
    this.accuracy = 0,
    this.timeSpentMinutes = 0,
    this.subjects = const [],
  });

  static const empty = UserProfile(
    fullName: '',
    coins: 0,
    xp: 0,
    maxXp: 500,
    level: 1,
    streak: 0,
  );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: (json['fullName'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      coins: json['coins'] ?? 0,
      xp: json['xp'] ?? 0,
      maxXp: (json['maxXp'] ?? 0) == 0 ? 500 : json['maxXp'],
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
      badges: json['badges'] ?? 0,
      certificates: json['certificates'] ?? 0,
      questionsAnswered: json['questionsAnswered'] ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      timeSpentMinutes: json['timeSpent'] ?? 0,
      subjects: ((json['subjects'] as List<dynamic>?) ?? const [])
          .map((s) => s.toString())
          .toList(),
    );
  }

  /// First name, capitalised - for the greeting line.
  String get firstName {
    final first = fullName.trim().split(RegExp(r'\s+')).first;
    if (first.isEmpty) return 'there';
    return first[0].toUpperCase() + first.substring(1);
  }

  /// Every word capitalised - for the profile header's full name.
  String get displayName {
    if (fullName.trim().isEmpty) return 'Student';
    return fullName
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  String get initials {
    final words = fullName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.map((w) => w[0].toUpperCase()).take(2).join();
    return letters.isEmpty ? '?' : letters;
  }

  double get levelProgress =>
      maxXp <= 0 ? 0 : (xp / maxXp).clamp(0.0, 1.0);

  String get timeSpentLabel {
    if (timeSpentMinutes < 60) return '${timeSpentMinutes}m';
    final h = timeSpentMinutes ~/ 60;
    final m = timeSpentMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
