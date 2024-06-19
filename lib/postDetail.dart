import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

var unescape = HtmlUnescape();

class Post {
  final String id;
  final String title;
  final DateTime publishOn;
  final String body;
  final String assetUrl;

  Post(
      {required this.id,
      required this.title,
      required this.body,
      required this.publishOn,
      required this.assetUrl});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: unescape.convert(json['title']),
        body: json['body'],
        publishOn: DateTime.fromMillisecondsSinceEpoch(json['publishOn']),
        assetUrl: json['assetUrl'] +
            '?format=500w500w' // Add this line to get the image in a higher resolution,
        );
  }
}

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: HtmlWidget(post.body),

      ),
    );
  }
}
