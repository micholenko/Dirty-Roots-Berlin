// add a forum page, include embed html

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Forum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return WebView(
        initialUrl: 'https://dirtyroots.discussion.community/',
        javascriptMode: JavascriptMode.unrestricted,
      );
  }
}