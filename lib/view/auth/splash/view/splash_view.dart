import 'package:flutter/material.dart';
import 'package:seanskayit/core/init.dart';
import 'package:seanskayit/core/services/cache/locale_manager.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/core/services/navigation/navigation_service.dart';
import 'package:seanskayit/product/enums/locale_enums.dart';
import 'package:seanskayit/product/enums/navigation_enums.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with FirebaseService {
  double _opacity = 0;
  final Duration _duration = const Duration(seconds: 1);

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        _opacity = 1;
      });
      await initData();
      int? appVer = LocaleManager.instance.getInt(LocaleEnum.appVer);
      int version = await AuthService.instance.getProgramVersion();
      if (appVer == null || appVer == version) {
        LocaleManager.instance.setInt(LocaleEnum.appVer, version);
        if (await AuthService.instance.isLoggedIn()) {
          NavigationService.navigateToPageClearStack(NavigationEnums.home);
        } else {
          NavigationService.navigateToPageClearStack(NavigationEnums.login);
        }
      } else {
        NavigationService.navigateWithWidget(const Scaffold(
            body: Center(
                child: Text("Programa güncelleme geldi. Çerezleri sil"))));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: _duration,
          child: Image.asset("assets/images/png/logo.png"),
        ),
      ),
    );
  }
}
