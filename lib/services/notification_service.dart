import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static NotificationService _instance = new NotificationService._internal();

  static get instance => _instance;

  var currentScreen;
  Chat goToChat;
  int notificationId = 1;

  NotificationService._internal() {
    this.goToChat = null;

    AwesomeNotifications().initialize(
        'resource://drawable/res_bro_icon',
        [
          NotificationChannel(
              channelKey: "brocast_notification",
              channelName: "BroCast main",
              channelDescription: "BroCast main notification channel",
              groupKey: 'custom_sound',
              groupSort: GroupSort.Desc,
              groupAlertBehavior: GroupAlertBehavior.Children,
              playSound: true,
              soundSource: 'resource://raw/res_brodio',
              defaultColor: Color(0xff6b6e97),
              ledColor: Color(0xff6b6e97),
              vibrationPattern: Int64List.fromList([0, 500, 100, 150]),
              importance: NotificationImportance.High),
        ],
        debug: true);

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
        if (broId != null && chatName != null) {
          if (BroList.instance.getBros().isEmpty) {
            Chat broNotify =
                new BroBros(int.parse(broId), chatName, "", "", "", 0, null, "", false, false, false);
            if (this.currentScreen != null) {
              this.currentScreen.goToDifferentChat(broNotify);
            } else {
              this.goToChat = broNotify;
            }
          } else {
            for (Chat br0 in BroList.instance.getBros()) {
              if (br0.id == int.parse(broId)) {
                if (this.currentScreen != null) {
                  this.currentScreen.goToDifferentChat(br0);
                } else {
                  this.goToChat = br0;
                }
              }
            }
          }
        }
      }
    });
  }

  Chat getGoToBro() {
    return this.goToChat;
  }

  void resetGoToBro() {
    this.goToChat = null;
  }

  void setScreen(var currentScreen) {
    this.currentScreen = currentScreen;
  }

  Future<void> showNotification(
      int broId, String chatName, String chatColour, String messageBody) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "brocast_notification",
            title: "$chatName:",
            body: messageBody,
            color: Color(0xff6b6e97),
            payload: {"id": broId.toString(), "chat_name": chatName}));
    notificationId += 1;
  }

  dismissAllNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
  }
}
