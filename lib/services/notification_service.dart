import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService _instance = new NotificationService._internal();
  static get instance => _instance;

  var currentScreen;
  BroBros goToBro;
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
        String broId = broResult["id"];
        String chatName = broResult["chat_name"];
        String chatColour = broResult["chat_colour"];
        if (broId != null && chatName != null && chatColour != null) {
          BroBros broNotify = new BroBros(int.parse(broId), chatName, chatColour);
          if (this.currentScreen != null) {
            this.currentScreen.goToDifferentChat(broNotify);
          } else {
            this.goToBro = broNotify;
          }
        }
      }
    });
  }

  BroBros getGoToBro() {
    return this.goToBro;
  }

  void resetGoToBro() {
    this.goToBro = null;
  }

  void setScreen(var currentScreen) {
    this.currentScreen = currentScreen;
  }

  Future<void> showNotification(int broId, String chatName, String chatColour, String messageBody) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "brocast_notification",
            title: "$chatName:",
            body: messageBody,
            color: Colors.red,
            payload: {
              "id": broId.toString(),
              "chat_name": chatName,
              "chat_colour": chatColour
            }
        )
    );
    notificationId += 1;
  }

}
