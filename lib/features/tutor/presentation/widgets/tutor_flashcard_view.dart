import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'tutor_formatted_text.dart';

/// A single flashcard from the lesson-completion wrap-up. Tap to flip
/// between the front (prompt) and back (answer).
class TutorFlashcardView extends StatefulWidget {
  final String front;
  final String back;

  const TutorFlashcardView({super.key, required this.front, required this.back});

  @override
  State<TutorFlashcardView> createState() => _TutorFlashcardViewState();
}

class _TutorFlashcardViewState extends State<TutorFlashcardView> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showBack = !_showBack),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _showBack ? AppColors.primary.withAlpha(15) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _showBack ? AppColors.primary.withAlpha(80) : AppColors.subtitle.withAlpha(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showBack ? 'ANSWER' : 'FLASHCARD - tap to reveal',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: _showBack ? AppColors.primary : AppColors.subtitle,
              ),
            ),
            const SizedBox(height: 6),
            TutorFormattedText(
              _showBack ? widget.back : widget.front,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}
