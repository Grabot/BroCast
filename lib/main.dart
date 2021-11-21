import 'package:brocast/services/navigation_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:brocast/utils/notification_util.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/router.dart' as router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Storage();
  setupLocator();

  NotificationUtil notificationUtil = NotificationUtil();
  notificationUtil.firebaseBackgroundInitialization();

  Settings.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brocast",
      debugShowCheckedModeBanner: false,
      initialRoute: routes.OpeningRoute,
      onGenerateRoute: router.generateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff292a38),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpeningScreen(),
    );
  }
}
