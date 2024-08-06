// import material.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'eventDetail.dart';

import 'api.dart';

import 'providers/focusDateProvider.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<String>> eventIds = {};
  DateTime _focusedDay = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Initially fetch eventIds for the current month
    _fetchEventsForMonth(DateTime.now().year, DateTime.now().month);
    _focusedDay = Provider.of<FocusDateProvider>(context, listen: false).focusDate;
    Provider.of<FocusDateProvider>(context, listen: false).setFocusDate(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTarget());
  }

  void _scrollToTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the target widget is visible by scrolling to it
      Scrollable.ensureVisible(
        _listKey.currentContext!,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchEventsForMonth(int year, int month) async {
    setState(() {
      loading = true;
    });
    var fetchedEvents = await fetchMonth(year, month);
    if (fetchedEvents != null) {
      setState(() {
        eventIds = fetchedEvents;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        controller: _scrollController,
        // make it so that the calendar is at the top of the screen, and the dynamic list of events fits below it
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                TableCalendar(
                daysOfWeekHeight: 22.0,
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black),
                  titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                calendarBuilders: CalendarBuilders(
                  singleMarkerBuilder: (context, date, event) {
                    return Icon(Icons.local_florist,
                        size: 14.0, color: Color(0xFF00201F));
                  },
                ),
                // color of the selected day

                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF049391),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF049391).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                )),
                if (loading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.5),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),

              ],
            ),
            
            ListView.builder(
              key: _listKey,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: eventIds[_focusedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                var id = eventIds[_focusedDay]?[index];
                return FutureBuilder(
                  future: fetchEvent(id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(
                          child:
                              const Center(child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return FutureBuilder(
                          future: _loadImage(snapshot.data!.assetUrl),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (imageSnapshot.hasError) {
                              return Center(child: Text('Error loading image'));
                            } else {
                              _scrollToTarget();

                              return Padding(
                                // top padding to separate events
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(snapshot.data!.assetUrl),
                                    Text(snapshot.data!.title,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        DateFormat('EEEE, MMMM d, y')
                                            .format(snapshot.data!.startDate),
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey)),
                                    HtmlWidget(snapshot.data!.body),
                                  ],
                                ),
                              );
                            }
                          });
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadImage(String url) {
    final completer = Completer<void>();
    final image = Image.network(url);
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete();
    }, onError: (dynamic error, StackTrace? stackTrace) {
      completer.completeError(error);
    });
    image.image.resolve(ImageConfiguration()).addListener(listener);
    return completer.future;
  }
}
