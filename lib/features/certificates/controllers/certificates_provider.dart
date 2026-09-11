import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/certificate.dart';
import '../services/certificates_service.dart';

final certificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  return CertificatesService().getCertificates();
});
