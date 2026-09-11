import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/competition.dart';
import '../services/competitions_service.dart';

final competitionsProvider = FutureProvider<List<Competition>>((ref) async {
  return CompetitionsService().getCompetitions();
});

final competitionLeaderboardProvider =
    FutureProvider.family<CompetitionLeaderboard, String>((ref, competitionId) async {
  return CompetitionsService().getLeaderboard(competitionId);
});
