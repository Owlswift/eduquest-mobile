import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/theme/app_colors.dart';

class TutorInputBar extends StatefulWidget {
  final bool sending;
  final void Function(String text) onSendText;
  final void Function(String audioFilePath) onSendVoice;

  const TutorInputBar({
    super.key,
    required this.sending,
    required this.onSendText,
    required this.onSendVoice,
  });

  @override
  State<TutorInputBar> createState() => _TutorInputBarState();
}

class _TutorInputBarState extends State<TutorInputBar> {
  final _controller = TextEditingController();
  final _recorder = AudioRecorder();
  bool _recording = false;

  @override
  void dispose() {
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null) widget.onSendVoice(path);
      return;
    }

    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/tutor_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() => _recording = true);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.sending || _recording;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 12, offset: Offset(0, -4), color: Color(0x11000000))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !disabled,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _recording ? 'Recording...' : 'Type your answer...',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _submitText(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.sending ? null : _toggleRecording,
            icon: Icon(
              _recording ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: _recording ? AppColors.danger : AppColors.primary,
            ),
          ),
          IconButton(
            onPressed: disabled ? null : _submitText,
            icon: Icon(
              Icons.send_rounded,
              color: disabled ? AppColors.subtitle.withAlpha(120) : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
