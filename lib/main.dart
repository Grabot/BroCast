import 'package:brocast/router.dart' as router;
import 'package:brocast/services/navigation_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/views/opening_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Settings();
  setupLocator();

  // firebaseBackgroundInitialization();

  runApp(OKToast(child: MyApp()));
}

// void firebaseBackgroundInitialization() async {
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// }
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brocast",
      debugShowCheckedModeBanner: false,
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
