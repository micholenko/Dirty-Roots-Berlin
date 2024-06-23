// detail page of an event

import 'package:flutter/material.dart';

class Event {
  final String title;
  final String assetUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String body;

  Event({
    required this.title,
    required this.assetUrl,
    required this.startDate,
    required this.endDate,
    required this.body,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    dynamic item = json['item'];
    print(item);
    return Event(
      title: item['title'],
      assetUrl: item['assetUrl'],
      startDate: DateTime.fromMillisecondsSinceEpoch(item['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(item['endDate']),
      body: item['body'],

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