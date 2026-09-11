import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/services/users_service.dart';
import '../models/daily_summary.dart';

/// The Learn screen's streak strip and "Today's Goal" card both read this.
/// `invalidate` it after a lesson or challenge to refresh the numbers.
final dailySummaryProvider = FutureProvider<DailySummary>((ref) async {
  return UsersService().getDailySummary();
});
