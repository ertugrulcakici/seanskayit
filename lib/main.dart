import "package:flutter/material.dart";
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/init.dart';
import 'package:seanskayit/core/services/navigation/navigation_router.dart';
import 'package:seanskayit/view/auth/splash/view/splash_view.dart';

void main(List<String> args) async {
  await initApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.7, 856.7),
      builder: (context, widget) {
        return ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light().copyWith(
                appBarTheme: ThemeData.light().appBarTheme.copyWith(
                      backgroundColor: Colors.white,
                      iconTheme: ThemeData.light()
                          .iconTheme
                          .copyWith(color: Colors.black),
                      titleTextStyle: ThemeData.light()
                          .textTheme
                          .headline6!
                          .copyWith(
                              fontSize: ScreenUtil().orientation ==
                                      Orientation.landscape
                                  ? 8.sp
                                  : 14.sp),
                    )),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale("tr")],
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationRouter.navigatorKey,
            home: const SplashView(),
            builder: EasyLoading.init(),
          ),
        );
      },
    );
  }
}
