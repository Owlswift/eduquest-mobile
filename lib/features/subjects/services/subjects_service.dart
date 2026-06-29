import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../dashboard/models/dashboard_models.dart';

class SubjectsService {
  final _dio = DioClient().dio;
  final _storage = TokenStorage();

  Future<List<SubjectModel>> getSubjects() async {
    final token = await _storage.getToken();
    final response = await _dio.get(
      '/subjects',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    final List<dynamic> subjectsList = response.data;
    return subjectsList.map((subject) {
      return SubjectModel(
        id: subject['id'] ?? '',
        name: subject['name'] ?? '',
        icon: _getIconFromString(subject['icon'] ?? 'menu_book_rounded'),
        color: _getColorFromString(subject['color'] ?? '#FF6B7280'),
        currentTopic: subject['currentTopic'] ?? '',
        progress: (subject['progress'] ?? 0.0).toDouble(),
      );
    }).toList();
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'functions_rounded':
        return Icons.functions_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'science_rounded':
        return Icons.science_rounded;
      case 'biotech_rounded':
        return Icons.biotech_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      case 'account_balance_rounded':
        return Icons.account_balance_rounded;
      case 'auto_stories_rounded':
        return Icons.auto_stories_rounded;
      case 'calculate_rounded':
        return Icons.calculate_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _getColorFromString(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6B7280);
    }
  }
}