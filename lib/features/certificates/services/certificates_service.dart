import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/certificate.dart';

class CertificatesService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _storage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<Certificate>> getCertificates() async {
    final response = await _dio.get('/certificates', options: await _authOptions());
    final List<dynamic> list = response.data;
    return list.map((c) => Certificate.fromJson(c as Map<String, dynamic>)).toList();
  }
}
