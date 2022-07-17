import 'package:flutter/material.dart';
import 'package:seanskayit/product/enums/navigation_enums.dart';
import 'package:seanskayit/view/admin/expanses/view/add_expanse_view.dart';
import 'package:seanskayit/view/admin/expanses/view/expanses_view.dart';
import 'package:seanskayit/view/admin/games/view/games_view.dart';
import 'package:seanskayit/view/admin/histories/session_history/view/session_history_view.dart';
import 'package:seanskayit/view/admin/statistics/view/statistics_view.dart';
import 'package:seanskayit/view/admin/users/view/users_view.dart';
import 'package:seanskayit/view/auth/login/login_view.dart';
import 'package:seanskayit/view/home/view/home_view.dart';

class NavigationRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static navigate(NavigationEnums navigationEnum, Object? data,
      {bool clearStack = false}) {
    switch (navigationEnum) {
      case NavigationEnums.sessionHistory:
        return _navigate(const SessionHistoryView(), data,
            clearStack: clearStack);
      case NavigationEnums.addExpanse:
        return _navigate(const AddExpanseView(), data, clearStack: clearStack);
      case NavigationEnums.login:
        return _navigate(const LoginView(), data, clearStack: clearStack);
      case NavigationEnums.home:
        // return _navigate(const StatisticsView(), data, clearStack: clearStack);
        return _navigate(const HomeView(), data, clearStack: clearStack);
      case NavigationEnums.users:
        return _navigate(const UsersView(), data, clearStack: clearStack);
      case NavigationEnums.games:
        return _navigate(const GamesView(), data, clearStack: clearStack);
      case NavigationEnums.expanses:
        return _navigate(const ExpansesView(), data, clearStack: clearStack);
      case NavigationEnums.statistics:
        return _navigate(const StatisticsView(), data, clearStack: clearStack);
    }
  }

  static _navigate(Widget page, Object? data, {bool clearStack = false}) {
    if (!clearStack) {
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (BuildContext context) => page,
          settings: RouteSettings(arguments: data)));
    } else {
      navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => page,
              settings: RouteSettings(arguments: data)),
          (route) => false);
    }
  }
}
