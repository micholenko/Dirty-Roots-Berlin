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
  late ScrollController _scrollController;
  bool isLoading = false;
  String? errorMessage;
  bool isNextPageAvailable = true;
  String nextPageUrl = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    postsBox = Hive.box<Post>('posts');
    postsList = postsBox.values.toList();
    postsList.sort((a, b) => (b.publishOn).compareTo(a.publishOn));

    fetchPosts(nextPageUrl).then((posts) {
      // If there is a new post in the API response, add it to the Hive box and update the UI.
      for (Post post in posts['posts']) {
        if (!postsBox.containsKey(post.id)) {
          postsBox.put(post.id, post);
        }
      }
      postsList = postsBox.values.toList();
      postsList.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
      nextPageUrl = posts['nextPageUrl'];
      setState(() {});
    }).catchError((error) {
      setState(() {
        errorMessage = error.toString();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge) {
      bool isBottom = _scrollController.position.pixels != 0;
      if (isBottom) {
        _fetchMorePosts();
      }
    }
  }

  Future<void> _fetchMorePosts() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      Map ret = await fetchPosts(nextPageUrl);
      print(ret);
      for (Post post in ret['posts']) {
        if (!postsBox.containsKey(post.id)) {
          postsBox.put(post.id, post);
        }
      }
      setState(() {
        postsList = postsBox.values.toList();
        postsList.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
        nextPageUrl = ret['nextPageUrl'];
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: errorMessage != null
          ? Center(child: Text('Error: $errorMessage'))
          : postsBox.isEmpty
              ? const Center(child: Text('No data available'))
              : Scrollbar(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postsList.length,
                            itemBuilder: (context, index) {
                              return PostSnippet(post: postsList[index]);
                            },
                          ),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}