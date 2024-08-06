// create a new class called EventSnippet for showing the first upcoming event in the home page.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import 'eventDetail.dart';

import 'providers/focusDateProvider.dart';

final unescape = HtmlUnescape();

class EventSnippet extends StatelessWidget {
  final Event event;
  final Function onTap;

  EventSnippet({required this.event, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        this.onTap(2);
        Provider.of<FocusDateProvider>(context, listen: false)
            .setFocusDate(event.startDate);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: event.assetUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(event.startDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
