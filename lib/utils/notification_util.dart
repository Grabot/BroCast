import 'dart:async';

import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../firebase_options.dart';
import '../objects/broup.dart';
import 'locator.dart';
import 'navigation_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationUtil().setupFlutterNotifications();
  await NotificationUtil().showNotification(message);
}

class NotificationUtil {
  static final NotificationUtil instance = NotificationUtil._internal();

  NotificationUtil._internal() {
    // Do something?
  }

  factory NotificationUtil() {
    return instance;
  }

  final NavigationService _navigationService = locator<NavigationService>();

  // We keep track of whether the init function has been called
  // This is to prevent multiple calls to the init function
  bool initCalled = false;

  String? FCMTokenDevice;
  String? FCMTokenServer;
  // We keep track of whether we need to update the FCM token on the server
  // After the user logs in we see if the token has to be updated
  bool updateTokenServer = false;

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;


  Future<void> initializeNotificationUtil() async {
    if (initCalled) {
      return;
    }
    initCalled = true;
    // Request permission
    await _requestPermission();

    // Setup message handlers
    await _setupMessageHandlers();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    getFCMTokenRegister();
  }


  getFCMTokenRegister() async {
    FCMTokenDevice = await _messaging.getToken();
    if (FCMTokenDevice != null) {
      SecureStorage().setFCMToken(FCMTokenDevice!);
    }
    print("fcm token device: $FCMTokenDevice");
  }

  // Only do this for broname/email password sign in?
  // Other ways to check FCM token? timestamp?
  // No need to check so often because it can only change due to the following events
  // - The app is restored on a new device
  // - The user uninstalls or re-installs the app
  // - The user clears app data
  // - The app becomes active again after FCM has expired its existing token
  // For each of these events it should be fine to do it this way.
  // - The app is restored on a new device
  //   - The user must login via broname/email password
  // - The user uninstalls or re-installs the app
  //   - The user must login via broname/email password
  // - The user clears app data
  //    - The user must login via broname/email password
  // - The app becomes active again after FCM has expired its existing token
  //    - Perhaps keep track of a timestamp with the last check time?
  //      The stale time is 270 days, but setting it a bit lower seems fine.
  getFCMTokenNotificationUtil(String? token) async {
    print("getFCMTokenNotificationUtil");
    print("token from server: $token");
    FCMTokenServer = token;
    if (FCMTokenDevice == null) {
      FCMTokenDevice = await _messaging.getToken();
    }
    if (FCMTokenDevice != null) {
      // local checks for FCM. after getting the FCM token for this device
      // - if the fcm token is empty in secure storage than update it locally
      //   and on the server
      // - else compare the fcm token with the storage.
      //  - if for some reason the fcm token generated is now different from
      //    what was in storage. Update it on the server and locally
      //  - else things are good and we do the main server check.
      //    This is to be expected
      // - The main check will always be checking the current FCM from the
      //   device with the on we get from the server when logging in.
      //   If they are different we update the server and locally.
      //   We only send it from the server if you log in using username/email
      //   password. If you log in via tokens we assume you use it often enough
      //   such that the token will be the same.
      print("fcm token device: $FCMTokenDevice");
      SecureStorage().getFCMToken().then((value) {
        print("got fcm token from storage: $value");
        if (value == null) {
          SecureStorage().setFCMToken(FCMTokenDevice!);
          print("update token. Empty locally");
          updateTokenServer = true;
        } else {
          if (value != FCMTokenDevice) {
            print("update token. Different token");
            SecureStorage().setFCMToken(FCMTokenDevice!);
            updateTokenServer = true;
          }
        }

        if (updateTokenServer) {
          print("update token straight away");
          // If this variable is set we update the token on the server no matter what.
          // If the token is null there is nothing we can do.
          if (FCMTokenDevice != null) {
            updateServer(FCMTokenDevice!);
          }
        } else {
          if (FCMTokenDevice != null && FCMTokenServer != null) {
            // Do the check.
            print("compare tokens ${FCMTokenDevice != FCMTokenServer}");
            if (FCMTokenDevice != FCMTokenServer) {
              // Update the token on the server
              updateServer(FCMTokenDevice!);
            }
          }
        }
      });
    }
  }

  getFCMTokenServer() {
    return FCMTokenServer;
  }

  setFCMTokenServer(String? token) {
    FCMTokenServer = token;
  }

  updateServer(String newFCMToken) {
    AuthServiceSocial().updateFCMToken(newFCMToken).then((value) {
      if (value) {
        print("FCM token updated on server");
      }
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'channel_id',
      'channel_name',
      description: 'This channel is used for notifications.',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('res_brodio'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios setup
    final initializationSettingsDarwin = DarwinInitializationSettings(
      notificationCategories: [
      DarwinNotificationCategory(
      'demoCategory',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'id_3',
          'Action 3',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
    ],
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // flutter notification setup
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  void onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog w ith the notification details, tap ok to go to another page
    print("on did receive local notification???");
  }

  Future<void> showNotification(RemoteMessage message) async {
    print("show notification");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            channelDescription: 'This channel is used for notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            sound: RawResourceAndroidNotificationSound('res_brodio'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print("opened app? ${initialMessage.data}");
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) async {
    print("handling background message ${message.data}");
    if (message.data.containsKey("broup_id")) {
      int broup_id = int.parse(message.data["broup_id"]);
      print("broup_id: $broup_id");
      Broup? notificationBroup = await Storage().fetchBroup(1);
      if (notificationBroup != null) {
        print("notification broup: ${notificationBroup.broupId}");
        // We first reset the routes. So that the home is not on the stack
        // and we can navigate to the chat.
        // When we navigate to the details or something things will work normally
        // But when we want to go back to home we don't see it on the stack
        // And we push replacement.
        Settings settings = Settings();
        settings.doneRoutes = [];
        settings.doneRoutes.add(routes.ChatRoute);
        _navigationService.navigateTo(routes.BroupRoute,
            arguments: notificationBroup);
        return;
      } else {
        _navigationService.navigateTo(routes.BroHomeRoute);
        return;
      }
    }
    print("navigate to home");
    _navigationService.navigateTo(routes.BroHomeRoute);
  }
}
