import 'package:flutter/material.dart';
import '../../constants/app_radius.dart';
import '../../theme/app_colors.dart';
import 'lesson_node.dart';
import 'path_connector.dart';

class LessonPath extends StatelessWidget {
  final List<LessonItem> lessons;

  const LessonPath({
    super.key,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isLast = index == lessons.length - 1;

        return Column(
          children: [
            if (index > 0)
              PathConnector(
                isVertical: true,
                isActive: lessons[index - 1].status != LessonStatus.locked &&
                    lesson.status != LessonStatus.locked,
                isBend: lesson.hasBend,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (lesson.hasBend)
                  PathConnector(
                    isVertical: false,
                    isActive: lesson.status != LessonStatus.locked,
                    isBend: false,
                  ),
                LessonNode(
                  status: lesson.status,
                  onTap: lesson.onTap,
                ),
                if (lesson.hasBend)
                  PathConnector(
                    isVertical: false,
                    isActive: lesson.status != LessonStatus.locked,
                    isBend: false,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        if (lesson.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            lesson.subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.subtitle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isLast)
              PathConnector(
                isVertical: true,
                isActive: lesson.status != LessonStatus.locked,
                isBend: lessons[index + 1].hasBend,
              ),
          ],
        );
      },
    );
  }
}

class LessonItem {
  final String title;
  final String? subtitle;
  final LessonStatus status;
  final VoidCallback? onTap;
  final bool hasBend;

  const LessonItem({
    required this.title,
    this.subtitle,
    required this.status,
    this.onTap,
    this.hasBend = false,
  });
}