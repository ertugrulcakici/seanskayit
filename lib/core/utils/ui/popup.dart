import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/navigation/navigation_router.dart';

class PopupHelper {
  static Future<void> showSimpleSnackbar(String message,
      {bool error = false, int milliSecond = 4000}) async {
    if (!error) {
      ScaffoldMessenger.of(NavigationRouter.navigatorKey.currentContext!)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: milliSecond),
        ),
      );
    } else {
      ScaffoldMessenger.of(NavigationRouter.navigatorKey.currentContext!)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
