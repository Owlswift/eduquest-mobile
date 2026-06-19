import 'package:flutter/material.dart';
import '../../constants/app_radius.dart';
import '../../theme/app_colors.dart';

class PathConnector extends StatelessWidget {
  final bool isVertical;
  final bool isActive;
  final bool isBend;

  const PathConnector({
    super.key,
    this.isVertical = true,
    this.isActive = true,
    this.isBend = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBend) {
      return CustomPaint(
        size: const Size(40, 40),
        painter: _BendPainter(
          color: isActive ? AppColors.primary : AppColors.subtitle.withOpacity(0.3),
          isActive: isActive,
        ),
      );
    }

    return Container(
      width: isVertical ? 4 : null,
      height: isVertical ? 40 : 4,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.subtitle.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BendPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  _BendPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}