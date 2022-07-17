import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/cache/locale_manager.dart';
import 'package:seanskayit/firebase_options.dart';

Future initData() async {}

Future initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await _initNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocaleManager.prefrencesInit();
}

// Future _initNotification() async {
//   try {
//     const androidConfig = FlutterBackgroundAndroidConfig(
//       notificationTitle: "Seans kayıt uygulaması",
//       notificationText: "Seans kayıt uygulaması",
//       notificationImportance: AndroidNotificationImportance.Default,
//       notificationIcon: AndroidResource(
//           name: 'background_icon',
//           defType: 'drawable'), // Default is ic_launcher from folder mipmap
//     );
//     await FlutterBackground.initialize(androidConfig: androidConfig);
//     await FlutterBackground.enableBackgroundExecution();
//   } catch (e) {
//     log(e.toString());
//   }

//   await AwesomeNotifications().initialize(
//       // set the icon to null if you want to use the default app icon
//       null,
//       [
//         NotificationChannel(
//             channelGroupKey: 'sessionrecord_channel_group',
//             channelKey: 'sessionrecord_channel',
//             channelName: 'Seans kayıt uygulaması',
//             channelDescription: 'Seans bildirimleri',
//             defaultColor: const Color(0xFF9D50DD),
//             ledColor: Colors.white)
//       ],
//       // Channel groups are only visual and are not required
//       channelGroups: [
//         NotificationChannelGroup(
//             channelGroupkey: 'sessionrecord_channel_group',
//             channelGroupName: 'Seans kayıt uygulaması')
//       ],
//       debug: true);
//   AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//     if (!isAllowed) {
//       // This is just a basic example. For real apps, you must show some
//       // friendly dialog box before call the request method.
//       // This is very important to not harm the user experience
//       AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//   });
// }
