/// GET /users/leaderboard - all-time ranking by XP.
class LeaderboardData {
  final List<LeaderboardEntry> top;
  final LeaderboardEntry? me;

  const LeaderboardData({required this.top, this.me});

  static const empty = LeaderboardData(top: []);

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      top: ((json['top'] as List<dynamic>?) ?? const [])
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      me: json['me'] == null
          ? null
          : LeaderboardEntry.fromJson(json['me'] as Map<String, dynamic>),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isMe;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      name: (json['name'] as String?) ?? '',
      xp: json['xp'] ?? 0,
      isMe: json['isMe'] ?? false,
    );
  }
}
