import 'package:flutter/material.dart';

class OnboardingData {
  final String image;
  final String title;
  final String coloredWord;
  final Color coloredWordColor;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;

  OnboardingData({
    required this.image,
    required this.title,
    required this.coloredWord,
    required this.coloredWordColor,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class OnboardingModel {
  final String title;
  final String highlighted;
  final String description;
  final String illustration;
  final IconData icon;
  final Color accentColor;

  OnboardingModel({
    required this.title,
    required this.highlighted,
    required this.description,
    required this.illustration,
    required this.icon,
    required this.accentColor,
  });
}