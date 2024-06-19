import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';

import 'postDetail.dart';

var unescape = HtmlUnescape();


class Posts extends StatefulWidget {
  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          return SingleChildScrollView(
            child: Column(children: <Widget>[
              for (Post post in snapshot.data!) ...[
                InkWell(
                  // Wrap with InkWell for tap detection
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PostDetailPage(
                          post:
                              post), // Assuming PostDetailPage takes a 'post' argument
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unescape.convert(post.title),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(DateFormat('MM/dd/yyyy').format(post.publishOn)),
                        // show only date in month, day, year format

                        Container(
                          width: double.infinity,
                          height: 400.0, // Fixed height for the image
                          child: Image.network(
                            post.assetUrl,
                            fit: BoxFit
                                .cover, // Ensures the image covers the container area
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ]
            ]),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}

// create fetchPosts function to make an api call to get the posts
Future<List<Post>> fetchPosts() async {
  final response = await http
      .get(Uri.parse('https://www.dirtyrootsberlin.com/blog?format=json'));
  if (response.statusCode == 200) {
    List<dynamic> posts = json.decode(response.body)['items'];
    log(posts.toString());
    return posts.map((post) => Post.fromJson(post)).toList();
  } else {
    throw Exception('Failed to load posts');
  }
}

// create a Post class to hold the post data


// create a PostDetailPage class to show the post detail
