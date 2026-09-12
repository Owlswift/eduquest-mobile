import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reward.dart';
import '../services/rewards_service.dart';

final rewardsProvider = FutureProvider<RewardsCatalog>((ref) async {
  return RewardsService().getRewards();
});

final rewardsHistoryProvider = FutureProvider<List<RewardRedemption>>((ref) async {
  return RewardsService().getHistory();
});
