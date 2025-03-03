import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/base_url.dart';
import '../main.dart';
import '../services/auth/auth_service_social.dart';
import 'game_start_login.dart';
import 'locator.dart';
import 'navigation_service.dart';
import 'package:brocast/constants/route_paths.dart' as routes;



///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************

class NotificationController extends ChangeNotifier {
  /// *********************************************
  ///   SINGLETON PATTERN
  /// *********************************************

  static final NotificationController _instance = NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  /// *********************************************
  ///  OBSERVER PATTERN
  /// *********************************************

  String _firebaseTokenDevice = '';
  String get firebaseTokenDevice => _firebaseTokenDevice;
  String _firebaseTokenServer = '';
  String get firebaseTokenServer => _firebaseTokenServer;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  ReceivedAction? initialAction;

  // We keep track of whether the init function has been called
  // This is to prevent multiple calls to the init function
  bool initCalled = false;

  // We keep track of whether we need to update the FCM token on the server
  // After the user logs in we see if the token has to be updated
  bool updateTokenServer = false;

  final NavigationService _navigationService = locator<NavigationService>();

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************

  static Future<void> initializeLocalNotifications({required bool debug}) async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_bro_icon',
      [
        NotificationChannel(
          channelKey: 'channel_bro',
          channelName: 'Bro Channel',
          channelDescription: 'Notification channel for BroCast',
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.deepPurple,
          ledColor: Colors.deepPurple,
          playSound: true,
          soundSource: "resource://raw/res_brodio",
        )
      ],
      debug: debug,
    );

    // Get initial notification action is optional
    _instance.initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await AwesomeNotificationsFcm().initialize(
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        licenseKeys: licenceKeysAwesomeNotification,
        debug: debug);
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
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
    if (token != null) {
      _firebaseTokenServer = token;
    }

    if (_firebaseTokenDevice.isNotEmpty) {
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
      print("fcm token device: $_firebaseTokenDevice");
      SecureStorage().getFCMToken().then((value) {
        print("got fcm token from storage: $value");
        if (value == null) {
          SecureStorage().setFCMToken(_firebaseTokenDevice);
          print("update token. Empty locally");
          updateTokenServer = true;
        } else {
          if (value != _firebaseTokenDevice) {
            print("update token. Different token");
            SecureStorage().setFCMToken(_firebaseTokenDevice!);
            updateTokenServer = true;
          }
        }

        if (updateTokenServer) {
          print("update token straight away");
          // If this variable is set we update the token on the server no matter what.
          // If the token is null there is nothing we can do.
          if (_firebaseTokenDevice.isNotEmpty) {
            updateServer(_firebaseTokenDevice);
          }
        } else {
          if (_firebaseTokenDevice.isNotEmpty && _firebaseTokenServer.isNotEmpty) {
            // Do the check.
            print("compare tokens ${_firebaseTokenDevice != _firebaseTokenServer}");
            if (_firebaseTokenDevice != _firebaseTokenServer) {
              // Update the token on the server
              updateServer(_firebaseTokenDevice);
            }
          }
        }
      });
    }
  }

  updateServer(String newFCMToken) {
    AuthServiceSocial().updateFCMToken(newFCMToken).then((value) {
      if (value) {
        print("FCM token updated on server");
      }
    });
  }

  ///  *********************************************
  ///     LOCAL NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    print("getInitialNotificationAction");
    if (receivedAction == null) return;
    // The app was opened from the background
    _instance.checkNotification(receivedAction);
    print('App launched by a notification action: $receivedAction');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('onActionReceivedMethod received a notification action');
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print('Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
      return;
    } else {
      if (receivePort == null) {
        // onActionReceivedMethod was called inside a parallel dart isolate.
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          // Redirecting the execution to main isolate process (this process is
          // only necessary when you need to redirect the user to a new page or
          // use a valid context)
          sendPort.send(receivedAction);
          return;
        }
      }
    }

    return onActionReceivedImplementationMethod(receivedAction);
  }

  bool navigateChat = false;
  int navigateChatId = -1;
  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    print('Notification action received: $receivedAction');
    // App is open, handle the notification
    if (receivedAction.payload != null) {
      String? broup_id = receivedAction.payload!['broup_id'];
      if (broup_id != null) {
        int broupId = int.parse(broup_id);
        Storage().fetchBroup(broupId).then((value) {
          if (value != null) {
            _instance.navigateChat = true;
            _instance.navigateChatId = broupId;
            _instance.notifyListeners();
          }
        });
      }
    }
  }

  checkNotification(ReceivedAction receivedAction) {
    loginCheck().then((loggedIn) {
      if (receivedAction.payload != null) {
        String? broup_id = receivedAction.payload!['broup_id'];
        if (broup_id != null) {
          int broupId = int.parse(broup_id);
          if (loggedIn) {
            Storage().fetchBroup(broupId).then((value) {
              if (value != null) {
                print("going to broup");
                _instance._navigationService.navigateTo(routes.ChatRoute,
                    arguments: value);
              } else {
                print("going to home");
                _instance._navigationService.navigateTo(routes.BroHomeRoute);
              }
              return;
            });
          } else {
            print("going to signin");
            _instance._navigationService.navigateTo(routes.SignInRoute);
            return;
          }
        }
      }
    });
  }
  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
  ///  *********************************************

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    print('Silent data received');

    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print('mySilentDataHandle received a FcmSilentData execution');
    await executeLongTaskInBackground();
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    if (token.isNotEmpty) {
      print('Fcm token received $token');
    } else {
      print('Fcm token deleted');
    }

    _instance._firebaseTokenDevice = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    print('Native token received');

    _instance._nativeToken = token;
    _instance.notifyListeners();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  ///  *********************************************
  ///     REQUEST NOTIFICATION PERMISSIONS
  ///  *********************************************

  static Future<bool> displayNotificationRationale(BuildContext context) async {
    bool userAuthorized = false;
    // BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
  ///  *********************************************
  ///     LOCAL NOTIFICATION CREATION METHODS
  ///  *********************************************

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'channel_bro',
            title: 'Huston! The eagle has landed!',
            body:
            "A small step for a man, but a giant leap to Flutter's community!",
            payload: {'notificationId': '1234567890'})
    );
  }

  static Future<void> resetBadge() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> deleteToken() async {
    await AwesomeNotificationsFcm().deleteToken();
    await Future.delayed(Duration(seconds: 5));
    await requestFirebaseToken();
  }

  ///  *********************************************
  ///     REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        print('$exception');
      }
    } else {
      print('Firebase is not available on this project');
    }
    return '';
  }
}