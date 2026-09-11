import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_summary_provider.dart';
import 'leaderboard_provider.dart';
import 'subject_progress_provider.dart';
import 'user_profile_provider.dart';

/// Call after returning from any screen that could have changed the
/// student's XP/coins/streak (a tutor lesson, a competition, a claimed
/// reward) so the dashboard's cards catch up without a manual pull.
void invalidateUserStats(WidgetRef ref) {
  ref.invalidate(userProfileProvider);
  ref.invalidate(dailySummaryProvider);
  ref.invalidate(leaderboardProvider);
  ref.invalidate(subjectProgressProvider);
}
