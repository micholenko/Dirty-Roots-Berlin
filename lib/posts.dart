import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html_unescape/html_unescape.dart';
import 'package:hive/hive.dart';

import 'postDetail.dart';
import 'postSnippet.dart';

import 'api.dart';

var unescape = HtmlUnescape();

class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  late List<Post> postsBox;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    postsBox = Hive.box<Post>('posts').values.toList();
    // sort posts by publish date
    postsBox.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
    fetchPosts().then((posts) {
      // if there is a new post in the API response, add it to the Hive box, set state to update the UI
      if (postsBox.isNotEmpty && postsBox[0].id != posts[0].id) {
        postsBox.insert(0, posts[0]);
        Hive.box<Post>('posts').put(posts[0].id, posts[0]);
        setState(() {});
      }

      
    }).catchError((error) {
      setState(() {
        errorMessage = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage != null
          ? Center(child: Text('Error: $errorMessage'))
          : postsBox.isEmpty
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      for (Post post in postsBox) ...[
                        PostSnippet(post: post)
                      ]
                    ],
                  ),
                ),
    );
  }

}

