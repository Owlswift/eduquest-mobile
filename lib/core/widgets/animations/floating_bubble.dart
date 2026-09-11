import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small circular bubble that gently bobs up and down, producing a
/// floating (3D) effect.
///
/// This is the same decorative "bubble" used on the onboarding screen's
/// illustration area, extracted so it can be reused on other screens such
/// as the login page.
class FloatingBubble extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  /// How far (in logical pixels) the bubble travels from its rest position.
  final double amplitude;

  /// How long one full bob (down and back up) takes.
  final Duration duration;

  /// A phase offset (0..1 of a full cycle) so several bubbles don't move
  /// in lockstep.
  final double phase;

  const FloatingBubble({
    super.key,
    required this.icon,
    required this.color,
    this.size = 52,
    this.iconSize = 36,
    this.amplitude = 6,
    this.duration = const Duration(seconds: 2),
    this.phase = 0,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // A single linear 0->1 loop; the vertical offset is a sine of it, so
    // the motion is smooth and the phase can be applied per-bubble in the
    // builder (rather than by poking _controller.value, which stops it).
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = (_controller.value + widget.phase) % 1.0;
        final dy = -math.sin(t * 2 * math.pi) * widget.amplitude;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Icon(widget.icon, size: widget.iconSize, color: widget.color),
      ),
    );
  }
}
