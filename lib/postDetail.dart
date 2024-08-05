import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hive/hive.dart';

part 'postDetail.g.dart';

var unescape = HtmlUnescape();

@HiveType(typeId: 0)
class Post {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime publishOn;
  @HiveField(3)
  final String body;
  @HiveField(4)
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
        assetUrl: json['assetUrl']);
  }
}





// class Post {
//   final String id;
//   final String title;
//   final DateTime publishOn;
//   final String body;
//   final String assetUrl;

//   Post(
//       {required this.id,
//       required this.title,
//       required this.body,
//       required this.publishOn,
//       required this.assetUrl});

//   factory Post.fromJson(Map<String, dynamic> json) {
//     return Post(
//         id: json['id'],
//         title: unescape.convert(json['title']),
//         body: json['body'],
//         publishOn: DateTime.fromMillisecondsSinceEpoch(json['publishOn']),
//         assetUrl: json['assetUrl'] +
//             '?format=500w500w' // Add this line to get the image in a higher resolution,
//         );
//   }
// }

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(''),
      ),
       body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0), // Add padding here
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              HtmlWidget(post.body
                // customStylesBuilder: (element) => ,
              ),
            ],
          ),

        ),
      ),
    );
  }
}
