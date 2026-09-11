import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// A circular back button matching the app's other circular icon buttons
/// (e.g. the header notification bell) - bigger and easier to tap than a
/// bare icon, and scales up further on tablets.
class CircularBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const CircularBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = context.isTablet ? 52.0 : 40.0;
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_rounded,
            size: context.isTablet ? 26 : 20,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}

/// Standard nav-bar layout: back button pinned left, title centered on the
/// full row width (matching the leading/centered-title/trailing convention
/// Flutter's own AppBar uses elsewhere in this app). With no [onBack], it's
/// just a plain left-aligned page heading.
class TutorHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  const TutorHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final back = onBack;
    if (back == null) {
      return Text(title, style: AppTextStyles.headline);
    }
    final buttonSize = context.isTablet ? 52.0 : 40.0;
    return Row(
      children: [
        CircularBackButton(onTap: back),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(fontSize: context.rs(20)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: buttonSize),
      ],
    );
  }
}
