import '../models/onboarding_model.dart';
import 'package:flutter/material.dart';

final onboardingPages = [
  OnboardingData(
    image: "assets/images/onboard1.png",
    title: "Learn Smarter",
    coloredWord: "Smarter",
    coloredWordColor: const Color(0xFF2563EB),
    subtitle: "Prepare for WAEC, JAMB and NECO with thousands of CBT questions and expert explanations.",
    backgroundColor: Colors.white,
    iconColor: const Color(0xFF2563EB),
  ),
  OnboardingData(
    image: "assets/images/onboard2.png",
    title: "Track Progress",
    coloredWord: "Progress",
    coloredWordColor: const Color(0xFF10B981),
    subtitle: "See your strengths, monitor your performance and build unstoppable study streaks.",
    backgroundColor: const Color(0xFFF0FDF4),
    iconColor: const Color(0xFF10B981),
  ),
  OnboardingData(
    image: "assets/images/onboard3.png",
    title: "Compete & Win",
    coloredWord: "Win",
    coloredWordColor: const Color(0xFFF59E0B),
    subtitle: "Earn XP, unlock badges, climb the leaderboard and win amazing prizes like airtime, books, devices and scholarships.",
    backgroundColor: const Color(0xFFFFFBEB),
    iconColor: const Color(0xFFF59E0B),
  ),
];
