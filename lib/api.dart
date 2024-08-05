
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'postDetail.dart';

import 'eventDetail.dart';

// add optional parameter to fetchPosts
Future<Map<String, dynamic>> fetchPosts([String nextPageUrl = '']) async {
    String url = 'https://www.dirtyrootsberlin.com/blog?format=json';
    if (nextPageUrl != '') {
      url = 'https://www.dirtyrootsberlin.com$nextPageUrl&format=json';
    }
    print(url);
    try {
      final response = await http
          .get(Uri.parse(url));
      if (response.statusCode == 200) {
        dynamic decoded = json.decode(response.body);
        List<dynamic> posts = decoded['items'];
        posts.forEach((post) {
          post['body'] = post['body']
              .replaceAll(RegExp(r'<noscript>.*?</noscript>'), '')
              .replaceAll(RegExp(r'data-src'), 'src')
              .replaceAll(RegExp(r'figure'), 'div')
              .replaceAll(RegExp(r'pre'), 'div');
        });
        String nextUrl = '';
        // check if the nextPageUrl key exists in the decoded JSON
        if (decoded['pagination']['nextPageUrl'] != null)
          nextUrl = decoded['pagination']['nextPageUrl'];
        List<Post> retPosts = posts.map((post) => Post.fromJson(post)).toList();
        return {
          'posts': retPosts,
          'nextPageUrl': nextUrl,
        };
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts');
    }
  }

Future<Map<DateTime, List<String>>?> fetchMonth(int year, int month) async {
  final response = await http.get(Uri.parse(
      'https://www.dirtyrootsberlin.com/api/open/GetItemsByMonth?month=${month.toString()}-${year.toString()}&collectionId=65e608bf2e643015e5d850e3'));
  if (response.statusCode == 200) {
    List<dynamic> events = json.decode(response.body);
    Map<DateTime, List<String>> idMap = {};
    for (var event in events) {
      // remove time from startDate, leave only date
      DateTime startDate =
          DateTime.fromMicrosecondsSinceEpoch(event['startDate'] * 1000);
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      startDate = DateTime.parse(startDate.toString() + 'Z');
      String id = event['fullUrl'];
      if (idMap.containsKey(startDate)) {
        idMap[startDate]!.add(id);
      } else {
        idMap[startDate] = [id];
      }
    }
    return idMap;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<Event> fetchEvent(String id) async {
  final response = await http
      .get(Uri.parse('https://www.dirtyrootsberlin.com$id?format=json'));
  if (response.statusCode == 200) {
    return Event.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load event');
  }
}