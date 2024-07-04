
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'postDetail.dart';


Future<List<Post>> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.dirtyrootsberlin.com/blog?format=json'));
      if (response.statusCode == 200) {
        List<dynamic> posts = json.decode(response.body)['items'];
        posts.forEach((post) {
          post['body'] = post['body']
              .replaceAll(RegExp(r'<noscript>.*?</noscript>'), '')
              .replaceAll(RegExp(r'data-src'), 'src')
              .replaceAll(RegExp(r'figure'), 'div')
              .replaceAll(RegExp(r'pre'), 'div');
        });
        return posts.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts');
    }
  }