// import material.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<Event>> events = {};
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initially fetch events for the current month
    _fetchEventsForMonth(DateTime.now().year, DateTime.now().month);
  }

  Future<void> _fetchEventsForMonth(int year, int month) async {
    var fetchedEvents = await fetchMonth(year, month);
    if (fetchedEvents != null) {
      setState(() {
        events = fetchedEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      eventLoader: (date) {
        return events[date] ?? [];
      },
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 1, 1),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onPageChanged: (newFocusedDay) {
        // Fetch events for the month when the page changes
        focusedDay = newFocusedDay;
        _fetchEventsForMonth(newFocusedDay.year, newFocusedDay.month);
      },
      onDaySelected: (selectedDay, focusedDay) {
        this.focusedDay = focusedDay; // Update the focused day
        // Display the events for the selected day
        var dayEvents = events[selectedDay] ?? [];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Events:'),
            content: SingleChildScrollView(
              child: ListBody(
                children: dayEvents.map((event) => Text(event.title)).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<Map<DateTime, List<Event>>?> fetchMonth(int year, int month) async {
  final response = await http.get(Uri.parse(
      'https://www.dirtyrootsberlin.com/api/open/GetItemsByMonth?month=${month.toString()}-${year.toString()}&collectionId=65e608bf2e643015e5d850e3'));
  if (response.statusCode == 200) {
    List<dynamic> events = json.decode(response.body);
    Map<DateTime, List<Event>> eventsMap = {};
    for (var event in events) {
      Event newEvent = Event.fromJson(event);
      // remove time from startDate, leave only date
      DateTime date = DateTime(newEvent.startDate.year,
          newEvent.startDate.month, newEvent.startDate.day);
      date = DateTime.parse(date.toString() + 'Z');
      if (eventsMap.containsKey(date)) {
        eventsMap[date]!.add(newEvent);
      } else {
        eventsMap[date] = [newEvent];
      }
    }
    return eventsMap;
  } else {
    throw Exception('Failed to load data');
  }
}
