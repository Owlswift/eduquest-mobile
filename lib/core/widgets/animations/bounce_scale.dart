import 'package:flutter/material.dart';

class BounceScale extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;

  const BounceScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.beginScale = 0.8,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: endScale),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}