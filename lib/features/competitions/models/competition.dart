/// GET /competitions - a time-boxed contest ranked by XP earned since
/// joining. Curated/seeded data server-side, no admin-authoring UI yet.
class Competition {
  final String id;
  final String title;
  final String subtitle;
  final List<String> prizes;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status; // 'upcoming' | 'ongoing' | 'ended'
  final int participantCount;
  final bool isJoined;

  const Competition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prizes,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.participantCount,
    required this.isJoined,
  });

  bool get isOngoing => status == 'ongoing';
  bool get isUpcoming => status == 'upcoming';

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      prizes: ((json['prizes'] as List<dynamic>?) ?? const [])
          .map((p) => p.toString())
          .toList(),
      startsAt: DateTime.parse(json['startsAt']),
      endsAt: DateTime.parse(json['endsAt']),
      status: json['status'] ?? 'ended',
      participantCount: json['participantCount'] ?? 0,
      isJoined: json['isJoined'] ?? false,
    );
  }

  Competition copyWith({bool? isJoined, int? participantCount}) {
    return Competition(
      id: id,
      title: title,
      subtitle: subtitle,
      prizes: prizes,
      startsAt: startsAt,
      endsAt: endsAt,
      status: status,
      participantCount: participantCount ?? this.participantCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

/// GET /competitions/:id/leaderboard
class CompetitionLeaderboard {
  final List<CompetitionLeaderboardEntry> top;
  final CompetitionLeaderboardEntry? me;

  const CompetitionLeaderboard({required this.top, this.me});

  factory CompetitionLeaderboard.fromJson(Map<String, dynamic> json) {
    return CompetitionLeaderboard(
      top: ((json['top'] as List<dynamic>?) ?? const [])
          .map((e) => CompetitionLeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      me: json['me'] == null
          ? null
          : CompetitionLeaderboardEntry.fromJson(json['me'] as Map<String, dynamic>),
    );
  }
}

class CompetitionLeaderboardEntry {
  final int rank;
  final String name;
  final int xpEarned;
  final bool isMe;

  const CompetitionLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xpEarned,
    required this.isMe,
  });

  factory CompetitionLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return CompetitionLeaderboardEntry(
      rank: json['rank'] ?? 0,
      name: (json['name'] as String?) ?? '',
      xpEarned: json['xpEarned'] ?? 0,
      isMe: json['isMe'] ?? false,
    );
  }
}
