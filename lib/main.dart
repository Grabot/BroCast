import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance;
  initializeFirebase();
  runApp(MyApp());
}

void initializeFirebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');

  print('message also contained a notification: ${message.notification}');
  print('message has data: ${message.data}');

  Map<String, dynamic> broResult = message.data;
  if (broResult != null) {
    String broName = broResult["bro_name"];
    String bromotion = broResult["bromotion"];
    String messageBody = broResult["message_body"];
    String broId = broResult["id"];
    NotificationService.instance.showNotification(broId, broName, bromotion, messageBody);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BroCast",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpeningScreen(),
    );
  }
}
