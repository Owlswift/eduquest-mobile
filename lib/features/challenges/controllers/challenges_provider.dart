import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_models.dart';
import '../services/challenges_service.dart';

/// GET /challenges - every challenge I'm in, either side.
final challengesListProvider = FutureProvider<List<ChallengeSummary>>((ref) async {
  return ChallengesService().list();
});

final challengeDetailProvider =
    FutureProvider.family<ChallengeDetail, String>((ref, challengeId) async {
  return ChallengesService().getOne(challengeId);
});
