import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/services/users_service.dart';
import '../models/leaderboard.dart';

final leaderboardProvider = FutureProvider<LeaderboardData>((ref) async {
  return UsersService().getLeaderboard();
});
