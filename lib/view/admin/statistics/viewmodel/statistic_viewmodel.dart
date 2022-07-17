import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/navigation/navigation_router.dart';
import 'package:seanskayit/core/utils/datetime_extentions.dart';

class StatisticViewModel extends ChangeNotifier {
  String startDate = DateTime.now().D;
  String stopDate = DateTime.now().D;
  List<String> dates = [];

  getDaysBetweenStopAndStartDate() {
    int y1 = int.parse(startDate.split('/')[2]);
    int m1 = int.parse(startDate.split('/')[1]);
    int d1 = int.parse(startDate.split('/')[0]);
    int y2 = int.parse(stopDate.split('/')[2]);
    int m2 = int.parse(stopDate.split('/')[1]);
    int d2 = int.parse(stopDate.split('/')[0]);
    log('$y1 $m1 $d1 $y2 $m2 $d2');
    dates.clear();
    int difference =
        DateTime(y2, m2, d2).difference(DateTime(y1, m1, d1)).inDays;
    DateTime dt1 = DateTime(y1, m1, d1);
    for (int i = 0; i <= difference; i++) {
      dates.add(dt1.add(Duration(days: i)).D);
    }
    log(dates.toString());
  }

  Future deneme() async {
    getDaysBetweenStopAndStartDate();
  }

  Future pickDate({required bool isStartDate}) async {
    DateTime? date = await showDatePicker(
      context: NavigationRouter.navigatorKey.currentState!.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (date != null) {
      if (isStartDate) {
        startDate = date.D;
      } else {
        stopDate = date.D;
      }
      notifyListeners();
    }
  }
}
