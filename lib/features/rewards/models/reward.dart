import 'package:flutter/material.dart';

/// A single catalog entry from GET /rewards. The catalog itself (title,
/// subtitle, cost) is a small fixed list server-side; icon/color stay
/// client-rendered via [RewardVisuals] since the server has no notion
/// of them.
class Reward {
  final String id;
  final String title;
  final String subtitle;
  final int coinCost;
  final bool canAfford;

  const Reward({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coinCost,
    required this.canAfford,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      coinCost: json['coinCost'] ?? 0,
      canAfford: json['canAfford'] ?? false,
    );
  }

  Reward copyWith({bool? canAfford}) {
    return Reward(
      id: id,
      title: title,
      subtitle: subtitle,
      coinCost: coinCost,
      canAfford: canAfford ?? this.canAfford,
    );
  }
}

/// GET /rewards response: the caller's coin balance plus the catalog.
class RewardsCatalog {
  final int coins;
  final List<Reward> rewards;

  const RewardsCatalog({required this.coins, required this.rewards});

  factory RewardsCatalog.fromJson(Map<String, dynamic> json) {
    return RewardsCatalog(
      coins: json['coins'] ?? 0,
      rewards: ((json['rewards'] as List<dynamic>?) ?? const [])
          .map((r) => Reward.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Icon/color per reward id - purely cosmetic, kept client-side since the
/// server catalog has no notion of visuals. Falls back to a generic gift
/// icon for any id it doesn't recognize (e.g. a reward added server-side
/// later without a matching visual here yet).
class RewardVisuals {
  final IconData icon;
  final Color color;
  const RewardVisuals(this.icon, this.color);

  static const _byId = <String, RewardVisuals>{
    'airtime_500': RewardVisuals(Icons.phone_android_rounded, Color(0xFF2563EB)),
    'data_1gb': RewardVisuals(Icons.wifi_rounded, Color(0xFF059669)),
    'edu_books': RewardVisuals(Icons.menu_book_rounded, Color(0xFF7C3AED)),
    'exam_voucher': RewardVisuals(Icons.assignment_rounded, Color(0xFFF59E0B)),
    'laptop': RewardVisuals(Icons.laptop_rounded, Color(0xFFDC2626)),
    'scholarship': RewardVisuals(Icons.school_rounded, Color(0xFF0891B2)),
  };

  static RewardVisuals forId(String id) =>
      _byId[id] ?? const RewardVisuals(Icons.card_giftcard_rounded, Color(0xFF64748B));
}
