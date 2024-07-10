import 'package:dirty_roots/postDetail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// import from root
import 'package:dirty_roots/postDetail.dart';

Future<void> messageHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  navigatorKey.currentState!.push(MaterialPageRoute(
    builder: (context) => PostDetailPage(
      post: Post(
        id: '1',
        publishOn: DateTime.now(),
        title: 'test',
        body: 'test',
        assetUrl: 'test',
      ),
    ),
  ));
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // subscribe to a topic blog-updates
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.subscribeToTopic('blog-updates');
    // handle when app is in the background
    FirebaseMessaging.onBackgroundMessage(messageHandler);
    // handle when app is on the foreground
    FirebaseMessaging.onMessage.listen(messageHandler);
  }
}
