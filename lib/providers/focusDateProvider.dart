import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class FocusDateProvider extends ChangeNotifier {
  DateTime _focusDate = DateTime.now();

  DateTime get focusDate => _focusDate;

  void setFocusDate(DateTime date) {

    date = DateTime(date.year, date.month, date.day);
    _focusDate = DateTime.parse(date.toString() + 'Z');
    notifyListeners();
  }
}