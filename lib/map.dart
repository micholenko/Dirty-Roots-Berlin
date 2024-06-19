import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the full screen height
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return WebView(
      initialUrl: 'https://www.google.com/maps/d/embed?mid=1YZ514gkddcJa9tcjrSJm-8JlMyAssDo&ehbc=2E312F',
      javascriptMode: JavascriptMode.unrestricted,
      );
  }
}
