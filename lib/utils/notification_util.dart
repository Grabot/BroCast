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
import 'package:logging/logging.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:brocast/constants/route_paths.dart' as routes;


const String androidChannelId = "custom_sound";
const String androidChannelName = "Brocast notification";
const String androidChannelDescription = "Custom Bro Sound for notifications";

const MethodChannel _channel
    = MethodChannel('nl.brocast/channel_bro');

class NotificationUtil {

  int currentChatId = -1;
  int currentIsBroup = -1;

  static final NotificationUtil _instance = NotificationUtil._internal();

  final NavigationService _navigationService = locator<NavigationService>();

  NotificationUtil._internal() {

    Logger.root.level = Level.SEVERE;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });

    setupFirebase();
  }

  factory NotificationUtil() {
    return _instance;
  }

  String? firebaseToken;

  Map<String, String> channelMap = {
    "id": androidChannelId,
    "name": androidChannelName,
    "description": androidChannelDescription
  };

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
            = FlutterLocalNotificationsPlugin();
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
    const AndroidInitializationSettings androidSettings
              = AndroidInitializationSettings('res_bro_icon');

    const IOSInitializationSettings iosSettings = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false
    );

    const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings
    );

    await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onSelectNotification: selectNotification
    );
  }

  Future selectNotification(String? payload) async {
    print("selected the notification");
    print("payload $payload");
    print(payload);
    int broId = int.parse(payload!.split(";")[0]);
    int isBroup = int.parse(payload.split(";")[1]);
    print(broId);
    print(isBroup);
    notificationNavigate(broId, isBroup);
  }

  void notificationNavigate(int id, int isBroup) {
    var storage = Storage();
    storage.selectChat(id.toString(), isBroup.toString()).then((value) {
      if (value != null) {
        Chat chat = value;
        print("found a chat");
        print(chat);
        if (chat.isBroup()) {
          print("navigate to the broup!");
          _navigationService.navigateTo(routes.BroupRoute, arguments: chat as Broup);
        } else {
          print("navigate to the bro bros!");
          _navigationService.navigateTo(routes.BroRoute, arguments: chat as BroBros);
        }
      } else {
        print("navigate to the bro home 3!");
        _navigationService.navigateTo(routes.HomeRoute);
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

    NotificationPermissions.requestNotificationPermissions(
        iosSettings: const NotificationSettingsIos(
            sound: true, badge: true, alert: true))
        .then((_) {
      print("notifications allowed");
    });

    platformChannelSpecifics = const NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannelId,
          androidChannelName,
          androidChannelDescription,
          playSound: true,
          priority: Priority.high,
          importance: Importance.high,
        ),
        iOS: IOSNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 0,
            sound: "res_brodio.aiff"
        ));
  }

  Future<void> initializeFirebaseService() async {
    FirebaseMessaging.instance;
    firebaseToken = await FirebaseMessaging.instance.getToken();

    print("registration id: \n$firebaseToken");
    if (firebaseToken == null || firebaseToken == "") {
      return;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // open message when the app is in the foreground.
      // Here we create a notification for both android and ios
      // So no action is taken, except creating a notifciation
      print('A new onMessage event was published!');
      print("message: $message");
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      var data = message.data;
      print("message title $title");
      print("message body $body");
      print("message data $data");
      print("data? ${data["id"]}");
      print("broup? ${data["broup"]}");
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
      print("message title $title");
      print("message body $body");
      print("message data $data");
      print(data["id"]);
      int broId = int.parse(data["id"]);
      int isBroup = int.parse(data["broup"]);
      print('A new onMessageOpenedApp event was published!');
      print("message: $message");
      notificationNavigate(broId, isBroup);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) {
        return;
      }

      String? title = message.notification!.title;
      String? body = message.notification!.body;
      var data = message.data;
      print("message title $title");
      print("message body $body");
      print("message data $data");
      print(data["id"]);
      int broId = int.parse(data["id"]);
      int isBroup = int.parse(data["broup"]);
      print('A new onMessageOpenedApp event was published!');
      print("message: $message");

      notificationNavigate(broId, isBroup);
    });
  }

  createNotificationChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
      print("channel created");
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _showNotification(String title, String body, int broId, int isBroup) async {

    print("message title $title");
    print("message body $body");
    print("bro id $broId");
    print("broup?  $isBroup");

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: broId.toString() + ";" + isBroup.toString()
    );
  }

  void showNotification(String title, String body, int broId, int isBroup) {
    _showNotification(title, body, broId, isBroup);
  }

  String getFirebaseToken() {
    return this.firebaseToken == null ? "" : this.firebaseToken!;
  }
}