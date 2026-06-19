import 'package:flutter/material.dart';

class FadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset slideOffset;

  const FadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = const Offset(0, 0.05),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: slideOffset * (1 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}