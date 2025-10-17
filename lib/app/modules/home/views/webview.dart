// Add new file app/modules/home/views/web_view_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Website'),
      ),
      body: WebViewWidget(
        controller: WebViewController()..loadRequest(Uri.parse(url)),
      ),
    );
  }
}