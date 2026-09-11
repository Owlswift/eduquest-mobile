import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/services/subjects_service.dart';
import '../models/dashboard_models.dart';

/// GET /subjects - the catalogue with display name / icon / colour.
final subjectsProvider = FutureProvider<List<SubjectModel>>((ref) async {
  return SubjectsService().getSubjects();
});
