import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/navigation/navigation_router.dart';
import 'package:seanskayit/product/enums/navigation_enums.dart';

class NavigationService {
  static navigateToPage(NavigationEnums navigationEnum, [Object? object]) {
    NavigationRouter.navigate(navigationEnum, object, clearStack: false);
  }

  static navigateToPageClearStack(NavigationEnums navigationEnum,
      [Object? object]) {
    NavigationRouter.navigate(navigationEnum, object, clearStack: true);
  }

  static navigateWithWidget(Widget widget) {
    NavigationRouter.navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (BuildContext context) => widget));
  }
}
