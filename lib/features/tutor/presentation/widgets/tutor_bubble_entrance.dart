import 'package:flutter/material.dart';

/// Plays a Telegram-style "pop" entrance once when a chat bubble first
/// mounts: scales up from the corner nearest the sender's side with a
/// slight overshoot/bounce, plus a quick fade. Wrap each list item with a
/// stable `key` (e.g. the message id) so Flutter reuses the same element -
/// and skips replaying the animation - as the list rebuilds around it.
class TutorBubbleEntrance extends StatefulWidget {
  final Widget child;

  /// Where the bubble grows from - bottomLeft for tutor bubbles,
  /// bottomRight for the student's own, matching which corner has the
  /// bubble's "tail" in TutorMessageBubble.
  final Alignment alignment;

  const TutorBubbleEntrance({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomLeft,
  });

  @override
  State<TutorBubbleEntrance> createState() => _TutorBubbleEntranceState();
}

class _TutorBubbleEntranceState extends State<TutorBubbleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        alignment: widget.alignment,
        child: widget.child,
      ),
    );
  }
}
