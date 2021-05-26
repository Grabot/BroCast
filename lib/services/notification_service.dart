import 'dart:typed_data';
import 'package:brocast/objects/bro.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static NotificationService _instance = new NotificationService._internal();
  static get instance => _instance;

  int notificationId = 1;

  NotificationService._internal() {

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
      print("this is what you received");
      print(receivedNotification);
      print(receivedNotification.payload);

      Map<String, dynamic> broResult = receivedNotification.payload;
      if (broResult != null) {
        String broName = broResult["bro_name"];
        String bromotion = broResult["bromotion"];
        String messageBody = broResult["message_body"];
        String broId = broResult["id"];
        if (broName != null && bromotion != null && broId != null) {
          Bro broNotify = Bro(int.parse(broId), broName, bromotion);
          // This should be implemented in every screen
          // TODO: @Skools go to the correct chat
          // TODO: Refactor all of this to not be in the main dart file.
          // openScreen.goToDifferentChat(broNotify);
        }
      }
    });
  }

  Future<void> showNotification(String broId, String broName, String bromotion, String messageBody) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 1,
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
  }

}
