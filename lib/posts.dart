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
  late Box<Post> postsBox;
  late List<Post> postsList;
  // sort posts list
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    postsBox = Hive.box<Post>('posts');
    postsList = postsBox.values.toList();
    postsList.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
    // sort posts by publish date
    // postsBox.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
    fetchPosts().then((posts) {
      // if there is a new post in the API response, add it to the Hive box, set state to update the UI
      for (Post post in posts) {
        if (!postsBox.containsKey(post.id)) {
          postsBox.put(post.id, post);
          Hive.box<Post>('posts').put(post.id, post);
        }
      }
      postsList = Hive.box<Post>('posts').values.toList();
      postsList.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
      setState(() {});
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
              : Scrollbar(
                child: SingleChildScrollView(
                  // show scroll sidebar
                    child: Column(
                      children: <Widget>[
                        for (Post post in postsList) ...[PostSnippet(post: post)]
                      ],
                    ),
                  ),
              ),
    );
  }
}
