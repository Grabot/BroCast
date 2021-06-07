import 'dart:convert';

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
  if (broResult != null) {
    String messageBody = broResult["message_body"];
    Map<String, dynamic> chat = jsonDecode(broResult["chat"]);
    int brosBroId = chat["bros_bro_id"];
    String chatName = chat["chat_name"];
    String chatColour = chat["chat_colour"];
    NotificationService.instance
        .showNotification(brosBroId, chatName, chatColour, messageBody);
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
