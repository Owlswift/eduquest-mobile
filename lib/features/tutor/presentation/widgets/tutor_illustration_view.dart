import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../services/tutor_service.dart';

/// Illustration blocks are decorative, not label-critical, and generation
/// runs a local Stable Diffusion pass (15-30+ seconds) - so this is
/// generated on demand when the student taps, not eagerly for every block.
class TutorIllustrationView extends StatefulWidget {
  final String messageId;

  const TutorIllustrationView({super.key, required this.messageId});

  @override
  State<TutorIllustrationView> createState() => _TutorIllustrationViewState();
}

class _TutorIllustrationViewState extends State<TutorIllustrationView> {
  final _service = TutorService();
  Uint8List? _bytes;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await _service.getMessageIllustration(widget.messageId);
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = "Couldn't generate that image.";
      });
    }
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullScreenIllustration(bytes: _bytes!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return GestureDetector(
        onTap: () => _openFullScreen(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(_bytes!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.subtitle.withAlpha(40)),
      ),
      child: Column(
        children: [
          if (_loading) ...[
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 10),
            const Text(
              'Painting a picture... this can take a little while',
              style: TextStyle(color: AppColors.subtitle, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              const SizedBox(height: 8),
            ],
            TextButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.image_rounded, size: 18),
              label: const Text('Show me a picture'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _FullScreenIllustration extends StatelessWidget {
  final Uint8List bytes;

  const _FullScreenIllustration({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
