import 'dart:io';

import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/navigation_service.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/utils/storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../services/settings.dart';

const String androidChannelId = "custom_sound";
const String androidChannelName = "Bro notifications";
const String androidChannelDescription = "Custom Bro Sound for notifications";
const String groupKey = 'custom_sound_brouping';

const MethodChannel _channel = MethodChannel('nl.brocast/channel_bro');

class NotificationUtil {
  int currentChatId = -1;
  int currentIsBroup = -1;

  bool fromNotification = false;

  static final NotificationUtil _instance = NotificationUtil._internal();

  final NavigationService _navigationService = locator<NavigationService>();

  NotificationUtil._internal() {
    setupFirebase();
  }

  factory NotificationUtil() {
    return _instance;
  }

  isFromNotification() {
    return fromNotification;
  }

  String? firebaseToken;

  Map<String, String> channelMap = {
    "id": androidChannelId,
    "name": androidChannelName,
    "description": androidChannelDescription
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationDetails platformChannelSpecifics;

  clearChat() {
    currentChatId = -1;
    currentIsBroup = -1;
  }

  currentChat(int currentChatId, int currentIsBroup) {
    this.currentChatId = currentChatId;
    this.currentIsBroup = currentIsBroup;
  }

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('res_bro_icon');

    const IOSInitializationSettings iosSettings = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false);

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String? payload) async {
    int broId = int.parse(payload!.split(";")[0]);
    int isBroup = int.parse(payload.split(";")[1]);
    notificationNavigate(broId, isBroup);
  }

  void notificationNavigate(int id, int isBroup) {
    fromNotification = true;
    Storage storage = Storage();
    storage.selectChat(id.toString(), isBroup.toString()).then((value) {
      // When we open a notification we will retrieve the user and set the data
      // This will be used in the rest of the app.
      Settings settings = Settings();
      if (value != null) {
        storage.selectUser().then((user) async {
          if (user != null) {
            settings.setEmojiKeyboardDarkMode(user.getKeyboardDarkMode());
            settings.setBroId(user.id);
            settings.setBroName(user.broName);
            settings.setBromotion(user.bromotion);
            settings.setToken(user.token);

            Chat chat = value;
            if (chat.isBroup()) {
              _navigationService.navigateTo(routes.BroupRoute,
                  arguments: chat as Broup);
            } else {
              _navigationService.navigateTo(routes.BroRoute,
                  arguments: chat as BroBros);
            }
          } else {
            // We will assume that there is a user, otherwise go to opening
            _navigationService.navigateTo(routes.OpeningRoute);
          }
        });
      } else {
        // We will assume that there is a chat, otherwise go to opening
        _navigationService.navigateTo(routes.OpeningRoute);
      }
    });
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  setupFirebase() async {
    await Firebase.initializeApp();
    initializeLocalNotifications();
    initializeFirebaseService();

    createNotificationChannel();
    
    if (!Platform.isAndroid) {
      NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(
              sound: true, badge: true, alert: true))
          .then((_) {});
    }


    platformChannelSpecifics = const NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannelId,
          androidChannelName,
          channelDescription: androidChannelDescription,
          groupKey: groupKey,
          setAsGroupSummary: true,
          playSound: true
        ),
        iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 0,
            sound: "res_brodio.aiff"));
  }

  Future<void> initializeFirebaseService() async {
    FirebaseMessaging.instance;
    firebaseToken = await FirebaseMessaging.instance.getToken();

    if (firebaseToken == null || firebaseToken == "") {
      return;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // open message when the app is in the foreground.
      // Here we create a notification for both android and ios
      // So no action is taken, except creating a notification
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      var data = message.data;
      int broId = int.parse(data["id"]);
      int isBroup = int.parse(data["broup"]);
      if (broId != currentChatId && isBroup != currentIsBroup) {
        _showNotification(title!, body!, broId, isBroup);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // open message when the app is in the background, but not terminated.
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      var data = message.data;
      int broId = int.parse(data["id"]);
      int isBroup = int.parse(data["broup"]);
      notificationNavigate(broId, isBroup);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) {
        return;
      }

      String? title = message.notification!.title;
      String? body = message.notification!.body;
      var data = message.data;
      int broId = int.parse(data["id"]);
      int isBroup = int.parse(data["broup"]);

      notificationNavigate(broId, isBroup);
    });
  }

  createNotificationChannel() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('createNotificationChannel', channelMap);
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }

  Future<void> _showNotification(
      String title, String body, int broId, int isBroup) async {
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: broId.toString() + ";" + isBroup.toString());
  }

  String getFirebaseToken() {
    return this.firebaseToken == null ? "" : this.firebaseToken!;
  }
}
