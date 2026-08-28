import 'package:flutter/material.dart';

/// Renders the tutor's text with `**bold**` markdown turned into actual
/// bold spans, instead of showing the literal asterisks. The model is
/// prompted to write plain conversational text, but still reaches for
/// markdown emphasis sometimes - this is the client-side safety net for
/// when it does, without pulling in a full markdown rendering package for
/// what is otherwise plain text.
class TutorFormattedText extends StatelessWidget {
  final String content;
  final TextStyle style;

  const TutorFormattedText(this.content, {super.key, required this.style});

  static final RegExp _boldPattern = RegExp(r'\*\*(.+?)\*\*');

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var lastEnd = 0;
    for (final match in _boldPattern.allMatches(content)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: content.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      spans.add(TextSpan(text: content.substring(lastEnd)));
    }

    return RichText(text: TextSpan(style: style, children: spans));
  }
}
