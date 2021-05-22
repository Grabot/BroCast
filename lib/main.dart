import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/views/opening_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'objects/bro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      // Insert here your friendly dialog box before call the request method
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  AwesomeNotifications().actionStream.listen(
          (receivedNotification){
            print("this is what you received");
            print(receivedNotification);
            print(receivedNotification.payload);

            Map<String, dynamic> broResult = receivedNotification.payload;
            if (broResult != null) {
              String broName = broResult["bro_name"];
              String bromotion = broResult["bromotion"];
              String messageBody = broResult["message_body"];
              String broId = broResult["id"];
              print("we did something!");
              print(broName);
              print(bromotion);
              print(messageBody);
              if (broName != null && bromotion != null && broId != null) {
                Bro broNotify = Bro(int.parse(broId), broName, bromotion);
                // This should be implemented in every screen
                // TODO: @Skools go to the correct chat
                // TODO: Refactor all of this to not be in the main dart file.
                // openScreen.goToDifferentChat(broNotify);
              }
            }
      }
  );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

int notificationId = 1;
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');

  print('message also contained a notification: ${message.notification}');
  print('message has data: ${message.data}');

  Map<String, dynamic> broResult = message.data;
  if (broResult != null) {
    String broName = broResult["bro_name"];
    String bromotion = broResult["bromotion"];
    String messageBody = broResult["message_body"];
    String broId = broResult["id"];
    showNotification(broId, broName, bromotion, messageBody);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BroCast",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpeningScreen(),
    );
  }
}
