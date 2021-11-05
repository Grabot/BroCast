import 'dart:convert';
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
    String messageBody = broResult["message_body"];
    Map<String, dynamic> chat = jsonDecode(broResult["chat"]);
    if (chat.containsKey("broup_name")) {
      // It's a broup
      int broupId = chat["id"];
      String chatName = chat["broup_name"];
      if (Platform.isAndroid) {
        NotificationService.instance.showNotification(
            broupId, chatName, messageBody, true);
      }
    } else {
      // It's a normal chat
      int broId = chat["bros_bro_id"];
      String chatName = chat["chat_name"];
      if (Platform.isAndroid) {
        NotificationService.instance.showNotification(
            broId, chatName, messageBody, false);
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
