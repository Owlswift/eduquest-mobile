import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/tutor_models.dart';
import 'tutor_audio_button.dart';
import 'tutor_block_widget.dart';
import 'tutor_formatted_text.dart';

class TutorMessageBubble extends StatelessWidget {
  final TutorMessage message;
  final void Function(String answer)? onQuizAnswer;

  const TutorMessageBubble({super.key, required this.message, this.onQuizAnswer});

  @override
  Widget build(BuildContext context) {
    final isTutor = message.isTutor;

    return Align(
      alignment: isTutor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isTutor ? Colors.white : AppColors.primary,
          // Chat-bubble "tail": the corner nearest the sender's own edge is
          // pulled in (small radius) while the rest stay fully rounded.
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isTutor ? 4 : 18),
            bottomRight: Radius.circular(isTutor ? 18 : 4),
          ),
          boxShadow: isTutor
              ? const [
                  BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x11000000)),
                ]
              : null,
        ),
        child: isTutor ? _tutorContent() : _studentContent(),
      ),
    );
  }

  Widget _studentContent() {
    return Text(
      message.content,
      style: const TextStyle(fontSize: 15, color: Colors.white),
    );
  }

  Widget _tutorContent() {
    if (message.blocks.isEmpty) {
      return TutorFormattedText(
        message.content,
        style: const TextStyle(fontSize: 15, color: AppColors.text),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < message.blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          TutorBlockWidget(
            block: message.blocks[i],
            messageId: message.id,
            onQuizAnswer: onQuizAnswer,
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TutorAudioButton(messageId: message.id),
        ),
      ],
    );
  }
}
