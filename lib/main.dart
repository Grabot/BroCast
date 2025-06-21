import 'package:brocast/router.dart' as router;
import 'package:brocast/utils/navigation_service.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/views/life_cycle/life_cycle.dart';
import 'package:brocast/views/opening_screen/opening_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  await NotificationController.initializeLocalNotifications(debug: false);

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  await NotificationController.initializeRemoteNotifications(debug: false);
  await NotificationController.startListeningNotificationEvents();
  await NotificationController.initializeIsolateReceivePort();
  await NotificationController.getInitialNotificationAction();
  // Initialize some singleton classes so we don't have to wait later.
  Settings();
  SecureStorage();

  runApp(OKToast(child: LifeCycle(child: MyApp())));
}

class MyApp extends StatelessWidget {

  final Widget opening = OpeningScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brocast",
      onGenerateRoute: router.generateRoute,
      navigatorKey: locator.get<NavigationService>().navigatorKey,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff393b57),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      home: opening,
    );
  }
}
