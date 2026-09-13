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
