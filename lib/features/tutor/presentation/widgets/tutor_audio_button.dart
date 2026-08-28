import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../services/tutor_service.dart';

/// Fetches a tutor message's synthesized speech (piper-tts, on demand) and
/// plays it. Bytes are cached in memory for the life of this widget so
/// replaying doesn't re-hit the backend.
class TutorAudioButton extends StatefulWidget {
  final String messageId;

  const TutorAudioButton({super.key, required this.messageId});

  @override
  State<TutorAudioButton> createState() => _TutorAudioButtonState();
}

class _TutorAudioButtonState extends State<TutorAudioButton> {
  final _service = TutorService();
  final _player = AudioPlayer();
  bool _loading = false;
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.stop();
      setState(() => _playing = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final bytes = await _service.getMessageAudio(widget.messageId);
      await _player.play(BytesSource(bytes));
      setState(() {
        _loading = false;
        _playing = true;
      });
      _player.onPlayerComplete.first.then((_) {
        if (mounted) setState(() => _playing = false);
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      onPressed: _toggle,
      icon: Icon(
        _playing ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
        color: AppColors.primary,
        size: 22,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
