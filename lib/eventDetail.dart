// detail page of an event

import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String assetUrl;
  final String fullUrl;
  final DateTime startDate;

  Event(
      {required this.id,
      required this.title,
      required this.assetUrl,
      required this.fullUrl,
      required this.startDate});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      assetUrl: json['assetUrl'],
      fullUrl: json['fullUrl'],
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate']),
      // startDate: json['startDate']
    );
  }
}

class EventDetail extends StatelessWidget {
  const EventDetail({Key? key, required this.event}) : super(key: key);

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(event.assetUrl),
            Text(event.title),
            Text(event.startDate.toString()),
            ElevatedButton(
              onPressed: () {
                // Open the full event page in a browser
              },
              child: const Text('View Full Event'),
            ),
          ],
        ),
      ),
    );
  }
}