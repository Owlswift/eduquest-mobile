import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../constants/app_text.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppText.sectionTitle,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: AppText.body,
              color: AppColors.subtitle,
            ),
          ),
        ]
      ],
    );
  }
}
