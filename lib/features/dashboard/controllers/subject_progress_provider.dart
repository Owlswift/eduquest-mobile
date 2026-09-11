import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/services/users_service.dart';
import '../models/subject_progress_entry.dart';

final subjectProgressProvider =
    FutureProvider<List<SubjectProgressEntry>>((ref) async {
  return UsersService().getSubjectProgress();
});
