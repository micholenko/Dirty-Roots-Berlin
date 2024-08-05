import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'posts.dart';
import 'postDetail.dart';
import 'postSnippet.dart';
import 'eventSnippet.dart';
import 'eventDetail.dart';

import 'api.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// say Good Morning, Good Afternoon, Good Evening, Good Night based on the time of the day
String _greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 17) {
    return 'Good Afternoon';
  } else if (hour < 20) {
    return 'Good Evening';
  } else {
    return 'Good Night';
  }
}

class _HomeState extends State<Home> {
  late List<Post> postsBox;
  late List<Event> eventsBox;
  bool loading = true;

  void initState() {
    loading = true;
    super.initState();  
    postsBox = Hive.box<Post>('posts').values.toList();
    eventsBox = Hive.box<Event>('events').values.toList();
    if (postsBox.isEmpty) {
      fetchPosts().then((ret) {
        postsBox = ret['posts'];
        setState(() {});
      }).catchError((error) {
        setState(() {
          print('Error: $error');
        });
      });
    }
    postsBox.sort((a, b) => (b.publishOn).compareTo(a.publishOn));
    print(eventsBox.isEmpty);
    if (eventsBox.isEmpty) {
      fetchMonth(DateTime.now().year, DateTime.now().month).then((events) {
        List<String> eventIds = events!.values.toList().expand((element) => element).toList();
        for (var event in eventIds) {
          fetchEvent(event).then((event) {
            eventsBox.add(event);
            Hive.box<Event>('events').put(event.title, event);
          }).catchError((error) {
            print('Error: $error');
          });
        }
        setState(() {});
      }).catchError((error) {
        setState(() {
          print('Error: $error');
        });
      });
    }
    print(eventsBox);
    eventsBox.sort((a, b) => (a.startDate).compareTo(b.startDate));
    loading = false;

  }

  _findUpcomingEvent(List<Event> events) {
    DateTime now = DateTime.now();
    for (var event in events) {
      if (event.startDate.isAfter(now)) {
        return event;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        // make it so that the calendar is at the top of the screen, and the dynamic list of events fits below it
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // say Good Morning, Good Afternoon, Good Evening, Good Night based on the time of the day
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                _greeting(),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // heading saying latest post
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Latest Post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // show the latest post
            postsBox.isEmpty
                ? Center(child: Text('No data available'))
                : PostSnippet(post: postsBox[0]),

            // PostSnippet(post: postsBox[0]),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Upcoming Event',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // show the upcoming event
            loading
                ? Center(child: CircularProgressIndicator())
                : eventsBox.isEmpty
                    ? Center(child: Text('No data available'))
                    : EventSnippet(event: _findUpcomingEvent(eventsBox)),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Follow us on social media',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // social media links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.instagram),
                  // redirect to the instagram.com page
                  onPressed: () => launchUrl(Uri.parse('https://www.instagram.com/dirtyroots.berlin/')),
                  iconSize: 30,
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.youtube),
                  onPressed: () => launchUrl(Uri.parse('https://www.youtube.com/channel/UCA3jK3Rw-vMvAIWHV_-oI6Q')),
                  iconSize: 30,
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.facebook),
                  onPressed: () => launchUrl(Uri.parse('https://www.facebook.com/dirtyrootsberlin/')),
                  iconSize: 30,
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.tiktok),
                  onPressed: () => launchUrl(Uri.parse('https://www.tiktok.com/@dirtyrootsberlin')),
                  iconSize: 30,
                ),
              ],
            ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Check out the website',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // website link button with icon and text
          ElevatedButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://www.dirtyrootsberlin.com/')),
            icon: FaIcon(FontAwesomeIcons.globe),
            label: Text('Dirty Roots Berlin'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: TextStyle(
                fontSize: 20,
              ),
            ),
          ),

          
          ],
        ),
      ),
    );
  }
}
