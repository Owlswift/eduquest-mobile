import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/services/users_service.dart';
import '../models/user_profile.dart';

/// GET /users/me, typed for the Home dashboard. `invalidate` after actions
/// that change coins/xp/level (challenges, lessons, purchases).
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final data = await UsersService().getProfile();
  return UserProfile.fromJson(data);
});
