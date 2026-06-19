import 'package:flutter/material.dart';
import '../../constants/app_radius.dart';
import '../../constants/app_shadows.dart';
import '../../theme/app_colors.dart';

enum LessonStatus { completed, current, locked, boss }

class LessonNode extends StatelessWidget {
  final LessonStatus status;
  final VoidCallback? onTap;
  final bool isAnimated;

  const LessonNode({
    super.key,
    required this.status,
    this.onTap,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return GestureDetector(
      onTap: status == LessonStatus.locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: config.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: config.borderColor,
            width: 3,
          ),
          boxShadow: isAnimated && status == LessonStatus.current
              ? [
                  BoxShadow(
                    color: config.borderColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppShadows.soft,
        ),
        child: Center(
          child: Icon(
            config.icon,
            color: config.iconColor,
            size: 32,
          ),
        ),
      ),
    );
  }

  _NodeConfig _getConfig() {
    switch (status) {
      case LessonStatus.completed:
        return _NodeConfig(
          icon: Icons.check_rounded,
          iconColor: AppColors.white,
          backgroundColor: AppColors.success,
          borderColor: AppColors.success,
        );
      case LessonStatus.current:
        return _NodeConfig(
          icon: Icons.star_rounded,
          iconColor: AppColors.warning,
          backgroundColor: AppColors.white,
          borderColor: AppColors.primary,
        );
      case LessonStatus.locked:
        return _NodeConfig(
          icon: Icons.lock_rounded,
          iconColor: AppColors.subtitle,
          backgroundColor: AppColors.white,
          borderColor: AppColors.subtitle.withOpacity(0.3),
        );
      case LessonStatus.boss:
        return _NodeConfig(
          icon: Icons.emoji_events_rounded,
          iconColor: AppColors.warning,
          backgroundColor: AppColors.white,
          borderColor: AppColors.warning,
        );
    }
  }
}

class _NodeConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  _NodeConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}