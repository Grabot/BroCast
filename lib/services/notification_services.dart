
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
    await Firebase.initializeApp();

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    // request permissions for showing notification in iOS
    firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    // add listener for foreground push notifications
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      print("received message foreground");
      print('[onMessage] message: $remoteMessage');
      // showNotification(remoteMessage);
    });
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