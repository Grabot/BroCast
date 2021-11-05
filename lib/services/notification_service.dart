import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:flutter/material.dart';

import 'get_chat.dart';

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
      Chat chatNotify;
      print(broResult);
      if (broResult != null) {
        String boolString = broResult["broup"];
        bool broup = boolString.toLowerCase() == 'true';
        if (broup) {
          // a broup
          int broupId = int.parse(broResult["id"]);
          String chatName = broResult["chat_name"];
          String alias = broResult["alias"];
          chatNotify = new Broup(broupId, chatName, "", alias, "", 0, null, "", false, false, true);
          print("set a broup notification");
        } else {
          // A normal chat.
          int broId = int.parse(broResult["id"]);
          chatNotify = new BroBros(broId, broResult["chat_name"], "", "", "", 0, null, "", false, false, false);
          for (Chat br0 in BroList.instance.getBros()) {
            if (!br0.isBroup) {
              if (br0.id == broId) {
                print("found a bro");
                chatNotify = br0;
              }
            }
          }
        }
      }
      if (chatNotify != null) {
        print("successfully found a chat");
        if (this.currentScreen != null) {
          print("we have a screen 'active' going there now");
          this.currentScreen.goToDifferentChat(chatNotify);
        } else {
          print("we set the object and wait for the app to startup");
          this.goToChat = chatNotify;
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

  Future<void> showNotificationBroup(int id, String messageBody) async {
    // Got a message from a broup
    print("Got a message from a broup");
    // First check if you have the list of bros in your memory
    Chat broupToNotify;
    for (Chat broup in BroList.instance.getBros()) {
      if (broup.isBroup) {
        if (broup.id == id) {
          print("found the correct broup");
          broupToNotify = broup;
          await displayNotification(
              broupToNotify.id,
              broupToNotify.chatName,
              broupToNotify.alias,
              broupToNotify.getBroNameOrAlias(),
              messageBody,
              true
          );
          return;
        }
      }
    }
    if (broupToNotify == null) {
      print("No broup was found, probably because the app was closed and it was not in memory.");
      HelperFunction.getBroId().then((val) {
        if (val == null || val == "") {
          // We didn't have any id, we assume this won't happen
        } else {
          GetChat getChat = new GetChat();
          getChat.getBroup(val, id).then((value) async {
            if (value != "an unknown error has occurred") {
              print("found the broup and going to set it.");
              broupToNotify = value;
              await displayNotification(
                  broupToNotify.id,
                  broupToNotify.chatName,
                  broupToNotify.alias,
                  broupToNotify.getBroNameOrAlias(),
                  messageBody,
                  true
              );
            }
          });
        }
      });
    }
    // If we didn't find anything we don't show a notification, we assume this won't happen
  }

  Future<void> showNotification(
      int id, String chatName, String alias, String title, String messageBody, bool broup) async {
    await displayNotification(
        id,
        chatName,
        alias,
        title,
        messageBody,
        broup
    );
  }

  displayNotification(int id, String chatName, String alias, String title, String messageBody, bool broup) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "brocast_notification",
            title: "$title:",
            body: messageBody,
            color: Color(0xff6b6e97),
            payload: {
              "id": id.toString(),
              "chat_name": chatName,
              "alias": alias,
              "broup": broup.toString()
            }));
    notificationId += 1;
  }

  dismissAllNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
  }
}
