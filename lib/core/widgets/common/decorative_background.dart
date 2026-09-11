import 'package:flutter/material.dart';

/// Paints a subtle decorative background consisting of a curvy wave along
/// the bottom edge and a scatter of translucent floating circles.
///
/// Together these layers give the screen depth and a layered (3D) look,
/// matching the visual style of the onboarding screen.
///
/// [color] is the (already faded) accent tint used to paint everything;
/// the floating circles are drawn at 45% opacity of that tint.
class DecorativeBackground extends StatelessWidget {
  final Color color;

  const DecorativeBackground({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _DecorativeBackgroundPainter(color)),
      ),
    );
  }
}

class _DecorativeBackgroundPainter extends CustomPainter {
  final Color color;

  _DecorativeBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * .82);

    path.quadraticBezierTo(
      size.width * .20,
      size.height * .72,
      size.width * .50,
      size.height * .82,
    );

    path.quadraticBezierTo(
      size.width * .80,
      size.height * .92,
      size.width,
      size.height * .82,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final circlePaint = Paint()..color = color.withValues(alpha: 0.45);

    canvas.drawCircle(
      Offset(size.width * .88, size.height * .16),
      28,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * .18, size.height * .22),
      8,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .30),
      6,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * .12, size.height * .56),
      4,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * .92, size.height * .60),
      5,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
