import 'package:flutter/material.dart';

// ─── Subject ─────────────────────────────────────────────────────────────────

class SubjectModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String currentTopic;
  final double progress;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.currentTopic,
    required this.progress,
  });
}

// ─── Leaderboard ─────────────────────────────────────────────────────────────

class LeaderboardEntry {
  final int rank;
  final String name;
  final String username;
  final String avatarInitials;
  final Color avatarColor;
  final int xp;
  final String classLevel;
  final String state;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.username,
    required this.avatarInitials,
    required this.avatarColor,
    required this.xp,
    required this.classLevel,
    required this.state,
    this.isCurrentUser = false,
  });
}

// ─── Badge ───────────────────────────────────────────────────────────────────

enum BadgeStatus { earned, locked }

class BadgeModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final BadgeStatus status;
  final String description;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.status,
    required this.description,
  });
}

// ─── Reward ──────────────────────────────────────────────────────────────────

class RewardModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int coinCost;

  const RewardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.coinCost,
  });
}

// ─── Competition ─────────────────────────────────────────────────────────────

class CompetitionModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime endsAt;
  final List<String> prizes;
  final int participants;
  final bool isOngoing;

  const CompetitionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.endsAt,
    required this.prizes,
    required this.participants,
    required this.isOngoing,
  });
}

// ─── Study Progress ───────────────────────────────────────────────────────────

class SubjectProgress {
  final String subject;
  final Color color;
  final double progress;

  const SubjectProgress({
    required this.subject,
    required this.color,
    required this.progress,
  });
}

class WeeklyPoint {
  final String day;
  final double value;

  const WeeklyPoint({required this.day, required this.value});
}

// ─── User ────────────────────────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String username;
  final String classLevel;
  final int level;
  final int coins;
  final int xp;
  final int maxXp;
  final int badges;
  final int certificates;
  final int streak;
  final int questionsAnswered;
  final double accuracy;
  final String timeSpent;

  const UserProfile({
    required this.name,
    required this.username,
    required this.classLevel,
    required this.level,
    required this.coins,
    required this.xp,
    required this.maxXp,
    required this.badges,
    required this.certificates,
    required this.streak,
    required this.questionsAnswered,
    required this.accuracy,
    required this.timeSpent,
  });

  double get xpProgress => xp / maxXp;
}