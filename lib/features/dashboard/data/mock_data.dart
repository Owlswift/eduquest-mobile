import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

// ─── User ────────────────────────────────────────────────────────────────────

const mockUser = UserProfile(
  name: 'Oluwatosin A.',
  username: '@oluwatosin_a',
  classLevel: 'SS3',
  level: 12,
  coins: 2450,
  xp: 2450,
  maxXp: 3000,
  badges: 12,
  certificates: 23,
  streak: 23,
  questionsAnswered: 320,
  accuracy: 0.78,
  timeSpent: '12h 45m',
);

// ─── Subjects ────────────────────────────────────────────────────────────────

const mockSubjects = [
  SubjectModel(
    id: 'math',
    name: 'Mathematics',
    icon: Icons.functions_rounded,
    color: Color(0xFF2563EB),
    currentTopic: 'Algebra • Linear Equations',
    progress: 0.72,
  ),
  SubjectModel(
    id: 'english',
    name: 'English',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF7C3AED),
    currentTopic: 'Comprehension • Essay',
    progress: 0.65,
  ),
  SubjectModel(
    id: 'physics',
    name: 'Physics',
    icon: Icons.science_rounded,
    color: Color(0xFF059669),
    currentTopic: 'Mechanics • Forces',
    progress: 0.58,
  ),
  SubjectModel(
    id: 'chemistry',
    name: 'Chemistry',
    icon: Icons.biotech_rounded,
    color: Color(0xFFDC2626),
    currentTopic: 'Organic • Hydrocarbons',
    progress: 0.44,
  ),
  SubjectModel(
    id: 'biology',
    name: 'Biology',
    icon: Icons.eco_rounded,
    color: Color(0xFF16A34A),
    currentTopic: 'Genetics • DNA',
    progress: 0.81,
  ),
  SubjectModel(
    id: 'economics',
    name: 'Economics',
    icon: Icons.trending_up_rounded,
    color: Color(0xFFF59E0B),
    currentTopic: 'Microeconomics • Demand',
    progress: 0.53,
  ),
  SubjectModel(
    id: 'government',
    name: 'Government',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF0891B2),
    currentTopic: 'Nigeria Constitution',
    progress: 0.39,
  ),
];

// ─── Leaderboard ─────────────────────────────────────────────────────────────

const mockLeaderboard = [
  LeaderboardEntry(
    rank: 1,
    name: 'Oluwatosin A.',
    username: 'oluwatosin_a',
    avatarInitials: 'OA',
    avatarColor: Color(0xFF2563EB),
    xp: 4850,
    classLevel: 'SS3',
    state: 'Lagos',
  ),
  LeaderboardEntry(
    rank: 2,
    name: 'Daniel E.',
    username: 'daniel_e',
    avatarInitials: 'DE',
    avatarColor: Color(0xFF7C3AED),
    xp: 4230,
    classLevel: 'SS2',
    state: 'Abuja',
  ),
  LeaderboardEntry(
    rank: 3,
    name: 'Adaeze M.',
    username: 'adaeze_m',
    avatarInitials: 'AM',
    avatarColor: Color(0xFF059669),
    xp: 3920,
    classLevel: 'SS3',
    state: 'Enugu',
  ),
  LeaderboardEntry(
    rank: 4,
    name: 'John D.',
    username: 'john_d',
    avatarInitials: 'JD',
    avatarColor: Color(0xFFDC2626),
    xp: 3450,
    classLevel: 'SS2',
    state: 'Port Harcourt',
  ),
  LeaderboardEntry(
    rank: 5,
    name: 'Faith I.',
    username: 'faith_i',
    avatarInitials: 'FI',
    avatarColor: Color(0xFFF59E0B),
    xp: 3120,
    classLevel: 'SS3',
    state: 'Ibadan',
  ),
  LeaderboardEntry(
    rank: 6,
    name: 'Emeka C.',
    username: 'emeka_c',
    avatarInitials: 'EC',
    avatarColor: Color(0xFF0891B2),
    xp: 2980,
    classLevel: 'SS2',
    state: 'Onitsha',
  ),
  LeaderboardEntry(
    rank: 7,
    name: 'Blessing T.',
    username: 'blessing_t',
    avatarInitials: 'BT',
    avatarColor: Color(0xFFDB2777),
    xp: 2760,
    classLevel: 'SS1',
    state: 'Kano',
  ),
  LeaderboardEntry(
    rank: 23,
    name: 'You',
    username: 'oluwatosin_a',
    avatarInitials: 'OA',
    avatarColor: Color(0xFF2563EB),
    xp: 1250,
    classLevel: 'SS3',
    state: 'Lagos',
    isCurrentUser: true,
  ),
];

// ─── Badges ──────────────────────────────────────────────────────────────────

const mockBadges = [
  BadgeModel(
    id: 'first_steps',
    title: 'First Steps',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF2563EB),
    status: BadgeStatus.earned,
    description: 'Complete your first quiz',
  ),
  BadgeModel(
    id: 'seven_streak',
    title: '7 Day Streak',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFF59E0B),
    status: BadgeStatus.earned,
    description: 'Study for 7 days in a row',
  ),
  BadgeModel(
    id: 'quiz_master',
    title: 'Quiz Master',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFF059669),
    status: BadgeStatus.earned,
    description: 'Score 100% in a quiz',
  ),
  BadgeModel(
    id: 'challenge_ace',
    title: 'Challenge Ace',
    icon: Icons.military_tech_rounded,
    color: Color(0xFF7C3AED),
    status: BadgeStatus.locked,
    description: 'Win a monthly challenge',
  ),
  BadgeModel(
    id: 'top_10',
    title: 'Top 10 Finisher',
    icon: Icons.leaderboard_rounded,
    color: Color(0xFFDC2626),
    status: BadgeStatus.locked,
    description: 'Reach top 10 on leaderboard',
  ),
  BadgeModel(
    id: 'subject_expert',
    title: 'Subject Expert',
    icon: Icons.star_rounded,
    color: Color(0xFF0891B2),
    status: BadgeStatus.locked,
    description: 'Complete all topics in a subject',
  ),
  BadgeModel(
    id: 'speed_demon',
    title: 'Speed Demon',
    icon: Icons.flash_on_rounded,
    color: Color(0xFFDB2777),
    status: BadgeStatus.locked,
    description: 'Answer 20 questions in under 5 minutes',
  ),
  BadgeModel(
    id: 'perfect_week',
    title: 'Perfect Week',
    icon: Icons.calendar_today_rounded,
    color: Color(0xFF16A34A),
    status: BadgeStatus.locked,
    description: 'Score above 80% every day for a week',
  ),
];

// ─── Rewards ─────────────────────────────────────────────────────────────────

const mockRewards = [
  RewardModel(
    id: 'airtime_500',
    title: 'Airtime',
    subtitle: 'N500',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF2563EB),
    coinCost: 500,
  ),
  RewardModel(
    id: 'data_1gb',
    title: 'Data Bundle',
    subtitle: '1GB',
    icon: Icons.wifi_rounded,
    color: Color(0xFF059669),
    coinCost: 800,
  ),
  RewardModel(
    id: 'edu_books',
    title: 'Edu Books',
    subtitle: 'E-Book',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF7C3AED),
    coinCost: 1200,
  ),
  RewardModel(
    id: 'exam_voucher',
    title: 'Exam Voucher',
    subtitle: 'WAEC',
    icon: Icons.assignment_rounded,
    color: Color(0xFFF59E0B),
    coinCost: 1500,
  ),
  RewardModel(
    id: 'laptop',
    title: 'Laptop',
    subtitle: 'HP 14"',
    icon: Icons.laptop_rounded,
    color: Color(0xFFDC2626),
    coinCost: 25000,
  ),
  RewardModel(
    id: 'scholarship',
    title: 'Scholarship',
    subtitle: 'University',
    icon: Icons.school_rounded,
    color: Color(0xFF0891B2),
    coinCost: 50000,
  ),
];

// ─── Competitions ────────────────────────────────────────────────────────────

final mockCompetitions = [
  CompetitionModel(
    id: 'monthly_may',
    title: 'Monthly Challenge',
    subtitle: 'Compete with students across the country and win amazing prizes!',
    endsAt: DateTime.now().add(const Duration(days: 10, hours: 14, minutes: 32)),
    prizes: ['Laptop', 'Tablet', 'Airtime (N50,000)', 'Scholarship'],
    participants: 8432,
    isOngoing: true,
  ),
  CompetitionModel(
    id: 'waec_prep',
    title: 'WAEC Prep Challenge',
    subtitle: 'Get ready for WAEC with this 2-week intensive challenge.',
    endsAt: DateTime.now().add(const Duration(days: 21)),
    prizes: ['Airtime (N10,000)', 'Data Bundle', 'Edu Books'],
    participants: 0,
    isOngoing: false,
  ),
  CompetitionModel(
    id: 'math_olympiad',
    title: 'Math Olympiad',
    subtitle: 'Show your math skills and win big prizes.',
    endsAt: DateTime.now().add(const Duration(days: 30)),
    prizes: ['Scholarship', 'Calculator', 'Textbooks'],
    participants: 0,
    isOngoing: false,
  ),
];

// ─── Study Progress ──────────────────────────────────────────────────────────

const mockSubjectProgress = [
  SubjectProgress(
    subject: 'Mathematics',
    color: Color(0xFF2563EB),
    progress: 0.86,
  ),
  SubjectProgress(
    subject: 'English',
    color: Color(0xFF7C3AED),
    progress: 0.72,
  ),
  SubjectProgress(
    subject: 'Physics',
    color: Color(0xFF059669),
    progress: 0.64,
  ),
  SubjectProgress(
    subject: 'Chemistry',
    color: Color(0xFFDC2626),
    progress: 0.51,
  ),
  SubjectProgress(
    subject: 'Biology',
    color: Color(0xFF16A34A),
    progress: 0.78,
  ),
];

const mockWeeklyPoints = [
  WeeklyPoint(day: 'May 1', value: 0.4),
  WeeklyPoint(day: 'May 8', value: 0.6),
  WeeklyPoint(day: 'May 15', value: 0.5),
  WeeklyPoint(day: 'May 22', value: 0.75),
  WeeklyPoint(day: 'May 29', value: 0.78),
];

// ─── Streak days ─────────────────────────────────────────────────────────────

const mockStreakDays = [
  ('Mon', true),
  ('Tue', true),
  ('Wed', true),
  ('Thu', true),
  ('Fri', true),
  ('Sat', false),
  ('Sun', false),
];