
import 'package:brocast/objects/bro.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {

  static NotificationService _instance = new NotificationService._internal();
  static get instance => _instance;

  var openScreen;

  NotificationService._internal() {
    print("this is now initialized");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) => notificationWhileOpen(message));

    init();
  }

  void init() async {
    print("this also");
    await Firebase.initializeApp();
  }

  void setScreen(var screen) {
    this.openScreen = screen;
  }

  void notificationWhileOpen(RemoteMessage message) {
    Map<String, dynamic> broResult = message.data;
    if (broResult != null) {
      String broName = broResult["bro_name"];
      String bromotion = broResult["bromotion"];
      String broId = broResult["id"];
      if (broName != null && bromotion != null && broId != null) {
        Bro broNotify = Bro(int.parse(broId), broName, bromotion);
        // This should be implemented in every screen
        openScreen.goToDifferentChat(broNotify);
      }
    }
  }

  Future<String> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}