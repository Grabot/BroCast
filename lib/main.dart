import 'dart:io';

import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/views/opening_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance;
  initializeFirebase();
  Settings.instance;
  runApp(MyApp());
}

void initializeFirebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Map<String, dynamic> broResult = message.data;
  print("is there a notification!?");
  print(message);
  if (broResult != null) {
    int id = int.parse(broResult["id"]);
    String messageBody = broResult["message_body"];
    String broupBoolean = broResult["broup"];
    bool broup = broupBoolean.toLowerCase() == 'true';
    print("notification with the following information");
    print(id);
    print(messageBody);
    print(broupBoolean);
    if (Platform.isAndroid) {
      if (broup) {
        print("sending the notification to the broup");
        if (broResult.containsKey("chat_name") && broResult.containsKey("alias")) {
          String chatName = broResult["chat_name"];
          String alias = broResult["alias"];
          String title = chatName;
          if (alias != null && alias != "") {
            title = alias;
          }
          NotificationService.instance.showNotification(id, chatName, alias, title, messageBody, true);
        } else {
          print("We are not sure what the alias is yet, so we will retrieve it first.");
          NotificationService.instance.showNotificationBroup(id, messageBody);
        }
      } else {
        String chatName = broResult["chat_name"];
        String alias = broResult["alias"];
        String title = chatName;
        if (alias != null && alias != "") {
          title = alias;
        }
        NotificationService.instance.showNotification(id, chatName, alias, title, messageBody, false);
      }
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Brocast",
      debugShowCheckedModeBanner: false,
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
