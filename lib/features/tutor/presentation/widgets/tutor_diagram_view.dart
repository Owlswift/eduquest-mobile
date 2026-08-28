import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../services/tutor_service.dart';

String _diagramHtml(String mermaidCode) => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <style>
    body { margin: 0; padding: 16px; background: #ffffff; }
    pre.mermaid { display: flex; justify-content: center; }
  </style>
</head>
<body>
  <pre class="mermaid">
$mermaidCode
  </pre>
  <script>mermaid.initialize({ startOnLoad: true });</script>
</body>
</html>
''';

/// Full-screen viewer for a diagram block's Mermaid syntax. Rendering
/// happens entirely client-side (mermaid.js) - the server never rasterizes
/// anything, so the diagram is exactly the labels/structure the tutor
/// generated, nothing more.
class TutorDiagramPage extends StatefulWidget {
  final String messageId;

  const TutorDiagramPage({super.key, required this.messageId});

  @override
  State<TutorDiagramPage> createState() => _TutorDiagramPageState();
}

class _TutorDiagramPageState extends State<TutorDiagramPage> {
  final _service = TutorService();
  late final WebViewController _webViewController;

  bool _loading = true;
  String? _error;
  String? _description;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _service.getMessageDiagram(widget.messageId);
      await _webViewController.loadHtmlString(_diagramHtml(result.mermaidCode));
      setState(() {
        _loading = false;
        _description = result.description;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = "Couldn't load this diagram.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_description ?? 'Diagram'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.subtitle)))
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
