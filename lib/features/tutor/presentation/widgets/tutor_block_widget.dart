import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/tutor_models.dart';
import 'tutor_diagram_view.dart';
import 'tutor_flashcard_view.dart';
import 'tutor_formatted_text.dart';
import 'tutor_illustration_view.dart';

/// Renders a single content block according to its type. `messageId` is
/// needed for block types whose full content is fetched on demand
/// (diagram, illustration) rather than shipped inline with the message.
class TutorBlockWidget extends StatelessWidget {
  final TutorBlock block;
  final String messageId;
  final void Function(String answer)? onQuizAnswer;

  const TutorBlockWidget({
    super.key,
    required this.block,
    required this.messageId,
    this.onQuizAnswer,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'analogy':
        return _labelled('ANALOGY', block.content, slanted: true);
      case 'example':
        return _labelled('EXAMPLE', block.content);
      case 'encouragement':
        return TutorFormattedText(
          block.content,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        );
      case 'quiz':
        return _QuizBlock(block: block, onAnswer: onQuizAnswer);
      case 'diagram':
        return _DiagramBlock(block: block, messageId: messageId);
      case 'illustration':
        return TutorIllustrationView(messageId: messageId);
      case 'flashcard':
        return TutorFlashcardView(front: block.content, back: block.back ?? '');
      case 'question':
      case 'explanation':
      default:
        return TutorFormattedText(
          block.content,
          style: const TextStyle(fontSize: 15, color: AppColors.text, height: 1.4),
        );
    }
  }

  Widget _labelled(String label, String content, {bool slanted = false}) {
    // The system italic (FontStyle.italic) skews quite steeply on this
    // font and reads as harder to read at paragraph length - a gentler,
    // hand-picked skew keeps the "this is different" cue without that.
    const gentleSkew = 0.12;

    Widget text = TutorFormattedText(
      content,
      style: const TextStyle(fontSize: 15, color: AppColors.text, height: 1.4),
    );
    if (slanted) {
      text = Transform(
        transform: Matrix4.skewX(-gentleSkew),
        alignment: Alignment.centerLeft,
        child: text,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        text,
      ],
    );
  }
}

class _DiagramBlock extends StatelessWidget {
  final TutorBlock block;
  final String messageId;

  const _DiagramBlock({required this.block, required this.messageId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.subtitle.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TutorFormattedText(
              block.content,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TutorDiagramPage(messageId: messageId),
                ),
              );
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

class _QuizBlock extends StatefulWidget {
  final TutorBlock block;
  final void Function(String answer)? onAnswer;

  const _QuizBlock({required this.block, this.onAnswer});

  @override
  State<_QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends State<_QuizBlock> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final options = widget.block.options ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TutorFormattedText(
          widget.block.content,
          style: const TextStyle(fontSize: 15, color: AppColors.text, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...List.generate(options.length, (i) {
          final isSelected = _selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: _selected == null
                  ? () {
                      setState(() => _selected = i);
                      widget.onAnswer?.call(options[i]);
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.subtitle.withAlpha(60),
                  ),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
