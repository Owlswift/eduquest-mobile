import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder tutor bubble shown while a turn is being generated, in place
/// of the previous "spinner on the send button" - it's easy to miss a small
/// spinner on a button, but a bubble appearing where the reply will land
/// reads immediately as "the tutor is typing".
class TutorTypingBubble extends StatefulWidget {
  const TutorTypingBubble({super.key});

  @override
  State<TutorTypingBubble> createState() => _TutorTypingBubbleState();
}

class _TutorTypingBubbleState extends State<TutorTypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x11000000)),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value - i * 0.2) % 1.0;
                final opacity = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Opacity(
                    opacity: opacity.clamp(0.3, 1.0),
                    child: const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
