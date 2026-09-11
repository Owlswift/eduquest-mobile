/// The subset of GET /users/me the Home dashboard renders.
class UserProfile {
  final String fullName;
  final int coins;
  final int xp;
  final int maxXp;
  final int level;
  final int streak;
  final List<String> subjects;

  const UserProfile({
    required this.fullName,
    required this.coins,
    required this.xp,
    required this.maxXp,
    required this.level,
    required this.streak,
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
      coins: json['coins'] ?? 0,
      xp: json['xp'] ?? 0,
      maxXp: (json['maxXp'] ?? 0) == 0 ? 500 : json['maxXp'],
      level: json['level'] ?? 1,
      streak: json['streak'] ?? 0,
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

  double get levelProgress =>
      maxXp <= 0 ? 0 : (xp / maxXp).clamp(0.0, 1.0);
}
