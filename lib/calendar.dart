// import material.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'eventDetail.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<String>> eventIds = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initially fetch eventIds for the current month
    _fetchEventsForMonth(DateTime.now().year, DateTime.now().month);
  }

  Future<void> _fetchEventsForMonth(int year, int month) async {
    var fetchedEvents = await fetchMonth(year, month);
    if (fetchedEvents != null) {
      setState(() {
        eventIds = fetchedEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          eventLoader: (date) {
            return eventIds[date] ?? [];
          },
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 1, 1),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onPageChanged: (newFocusedDay) {
            // Fetch eventIds for the month when the page changes
            _focusedDay = newFocusedDay;
            _fetchEventsForMonth(newFocusedDay.year, newFocusedDay.month);
          },
          selectedDayPredicate: (day) {
            return isSameDay(_focusedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          // change the dot for a plant icon
          calendarBuilders: CalendarBuilders(
            singleMarkerBuilder: (context, date, event) {
              return Icon(Icons.local_florist, size: 15.0, color: Colors.green);
            },
          ),
        ),
        Flexible(
          child: ListView(
            children: [
              for (var id in eventIds[_focusedDay] ?? [])
                FutureBuilder(
                  future: fetchEvent(id),
                  builder: (context, snapshot) {
                    print(snapshot);
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Column(
                        children: [
                          Image.network(snapshot.data!.assetUrl),
                          Text(snapshot.data!.title),
                          // show time in month, day, year format
                          Text(snapshot.data!.startDate.toString()),
                          HtmlWidget(snapshot.data!.body),
                        ],
                        
                        
                      );
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  },
                ),
            ],
          ),
        )
        // Container(
        //   child: ListView(
        //     children: [
        //       Text('Events on ${_focusedDay.toString()}'),
        //         // FutureBuilder(
        //         //   future: fetchEvent(event),
        //         //   builder: (context, snapshot) {
        //         //     if (snapshot.connectionState == ConnectionState.waiting) {
        //         //       return const Center(child: CircularProgressIndicator());
        //         //     } else if (snapshot.hasError) {
        //         //       return Center(child: Text('Error: ${snapshot.error}'));
        //         //     } else if (snapshot.hasData && snapshot.data != null) {
        //         //       return ListTile(
        //         //         title: Text(snapshot.data!.title),
        //         //         subtitle: Text(snapshot.data!.startDate.toString()),

        //         //       );
        //         //     } else {
        //         //       return const Center(child: Text('No data'));
        //         //     }
        //         //   },
        //         // ),
        //     ],
        //   ),
        // ),
      ],
    );
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
  final response = await http.get(Uri.parse(
      'https://www.dirtyrootsberlin.com$id?format=json'));
  if (response.statusCode == 200) {
    return Event.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load event');
  }
}
