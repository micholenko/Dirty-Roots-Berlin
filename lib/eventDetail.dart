// detail page of an event

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'eventDetail.g.dart';

@HiveType(typeId: 1)
class Event extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String assetUrl;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
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
    return Event(
      title: item['title'],
      assetUrl: item['assetUrl'],
      startDate: DateTime.fromMillisecondsSinceEpoch(item['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(item['endDate']),
      body: item['body'],
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