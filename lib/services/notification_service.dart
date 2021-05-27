import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/objects/bro.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService _instance = new NotificationService._internal();
  static get instance => _instance;

  var currentScreen;
  Bro goToBro;
  int notificationId = 1;

  NotificationService._internal() {

    this.goToBro = null;

    AwesomeNotifications().initialize(
        'resource://drawable/bro_fire',
        [
          NotificationChannel(
              channelKey: "brocast_notification",
              channelName: "BroCast main",
              channelDescription: "BroCast main notification channel",
              groupKey: 'custom_sound',
              groupSort: GroupSort.Desc,
              groupAlertBehavior: GroupAlertBehavior.Children,
              playSound: true,
              soundSource: 'resource://raw/brodio',
              defaultColor: Colors.red,
              ledColor: Colors.red,
              vibrationPattern: Int64List.fromList([0, 500, 100, 150]),
              importance: NotificationImportance.High),
        ],
        debug: true
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().actionStream.listen((receivedNotification) {

      Map<String, dynamic> broResult = receivedNotification.payload;
      if (broResult != null) {
        String broName = broResult["bro_name"];
        String bromotion = broResult["bromotion"];
        String broId = broResult["id"];
        if (broName != null && bromotion != null && broId != null) {
          Bro broNotify = Bro(int.parse(broId), broName, bromotion);
          if (this.currentScreen != null) {
            this.currentScreen.goToDifferentChat(broNotify);
          } else {
            this.goToBro = broNotify;
          }
        }
      }
    });
  }

  Bro getGoToBro() {
    return this.goToBro;
  }

  void resetGoToBro() {
    this.goToBro = null;
  }

  void setScreen(var currentScreen) {
    this.currentScreen = currentScreen;
  }

  Future<void> showNotification(String broId, String broName, String bromotion, String messageBody) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "brocast_notification",
            title: "$broName $bromotion:",
            body: messageBody,
            color: Colors.red,
            payload: {
              "id": broId,
              "bro_name": broName,
              "bromotion": bromotion,
              "message_body": messageBody
            }
        )
    );
    notificationId += 1;
  }

}
