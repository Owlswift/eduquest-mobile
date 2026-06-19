import 'package:flutter/material.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_shadows.dart';
import '../../theme/app_colors.dart';

class SubjectSelector extends StatelessWidget {
  final List<SubjectItem> subjects;
  final String? selectedSubjectId;
  final ValueChanged<String>? onSubjectSelected;

  const SubjectSelector({
    super.key,
    required this.subjects,
    this.selectedSubjectId,
    this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = subject.id == selectedSubjectId;

          return GestureDetector(
            onTap: () => onSubjectSelected?.call(subject.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : AppShadows.card,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    subject.icon,
                    color: isSelected ? AppColors.white : AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SubjectItem {
  final String id;
  final String name;
  final IconData icon;

  const SubjectItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}