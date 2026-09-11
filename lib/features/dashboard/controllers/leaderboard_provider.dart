import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/services/users_service.dart';
import '../models/leaderboard.dart';

/// All-time leaderboard (lifetime XP) - used by the dashboard's compact
/// "your rank" card and as the default tab on the full Leaderboard page.
final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  return UsersService().getLeaderboard();
});

/// Keyed by period ('all' | 'weekly' | 'monthly') - backs the Leaderboard
/// page's tab switcher.
final leaderboardForPeriodProvider =
    FutureProvider.family<LeaderboardData, String>((ref, period) async {
  return UsersService().getLeaderboard(period: period);
});
