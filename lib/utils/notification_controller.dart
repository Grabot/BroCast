import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/utils/life_cycle_service.dart';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:flutter/material.dart';

import '../constants/base_url.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../services/auth/v1_4/auth_service_social.dart';
import 'start_login.dart';
import 'locator.dart';
import 'navigation_service.dart';

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

  bool navigateChat = false;
  int navigateChatId = -1;
  final NavigationService _navigationService = locator<NavigationService>();

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************

  static Future<void> initializeLocalNotifications({required bool debug}) async {
    // TODO: create a new notification channel for every broup that is created. To group the notfications together.
    // TODO: Maybe play around with notification layout types (messaging)
    await AwesomeNotifications().initialize(
      'resource://drawable/res_bro_icon',
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'channel_bro',
          channelName: 'Bro Channel',
          channelDescription: 'Notification channel for Brocast',
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          enableVibration: true,
          vibrationPattern: mediumVibrationPattern,
          defaultColor: Colors.teal,
          enableLights: true,
          ledColor: Colors.teal,
          playSound: true,
          soundSource: 'resource://raw/res_brodio',
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group'
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
  bool updatingFCMToken = false;
  getFCMTokenNotificationUtil(String? token) async {
    if (token != null) {
      _firebaseTokenServer = token;
    } else {
      _firebaseTokenServer = '';
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
      SecureStorage().getFCMToken().then((value) {
        if (value == null) {
          SecureStorage().setFCMToken(_firebaseTokenDevice);
          if (_firebaseTokenDevice.isNotEmpty) {
            if (!updatingFCMToken) {
              updatingFCMToken = true;
              updateServer(_firebaseTokenDevice);
            }
          }
        } else {
          if (value != _firebaseTokenDevice) {
            SecureStorage().setFCMToken(_firebaseTokenDevice);
            if (_firebaseTokenDevice.isNotEmpty) {
              if (!updatingFCMToken) {
                updatingFCMToken = true;
                updateServer(_firebaseTokenDevice);
              }
            }
          }
        }

        if (_firebaseTokenServer.isEmpty) {
          // If this variable is set we update the token on the server no matter what.
          // If the token is null there is nothing we can do.
          if (_firebaseTokenDevice.isNotEmpty) {
            if (!updatingFCMToken) {
              updatingFCMToken = true;
              updateServer(_firebaseTokenDevice);
            }
          }
        } else {
          if (_firebaseTokenDevice.isNotEmpty && _firebaseTokenServer.isNotEmpty) {
            // Do the check.
            if (_firebaseTokenDevice != _firebaseTokenServer) {
              // Update the token on the server
              if (!updatingFCMToken) {
                updatingFCMToken = true;
                updateServer(_firebaseTokenDevice);
              }
            }
          }
        }
      });
    }
  }

  updateServer(String newFCMToken) {
    // We will update the FCM token, but with a delay to allow the login process to finish.
    Future.delayed(Duration(seconds: 2), () {
      updatingFCMToken = false;
      AuthServiceSocial().updateFCMToken(newFCMToken);
    });
  }

  ///  *********************************************
  ///     LOCAL NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction == null) return;
    // The app was opened from the background
    _instance.checkNotification(receivedAction);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
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

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    // App is open, handle the notification
    // Here we don't use the `appOpen` variable.
    // If the user presses the notification the app goes on inactive for a little bit.
    if (LifeCycleService().appStatus != 1) {
      // Unless the app was not active, than we do the `
      _instance.checkNotification(receivedAction);
      return;
    }
    if (receivedAction.payload != null) {
      if (receivedAction.payload!.containsKey('broup_id')) {
        String? broup_id = receivedAction.payload!['broup_id'];
        if (broup_id != null) {
          int broupId = int.parse(broup_id);
          if (MessagingChangeNotifier().getBroupId() == broupId) {
            // The chat is already open, so we don't need to navigate to it.
            return;
          }
          Storage().fetchBroup(broupId).then((value) {
            if (value != null) {
              // The app should be open if it comes here, so there should be broups in the settings.
              Me? me = Settings().getMe();
              if (me != null) {
                for (Broup meBroup in me.broups) {
                  if (meBroup.broupId == broupId) {
                    _instance._navigationService.navigateTo(routes.ChatRoute,
                        arguments: meBroup);
                    return;
                  }
                }
              }
            }
          });
        }
      }
    }
  }

  checkNotification(ReceivedAction receivedAction) {
    // The app is not open yet, so quickly log in first.
    Settings settings = Settings();
    if (settings.loggingIn) {
      // Already logging in, we assume that after that other login
      // process is done it will navigate somewhere
      return;
    }
    loginCheck().then((loggedIn) {
      if (receivedAction.payload != null) {
        String? broup_id = receivedAction.payload!['broup_id'];
        if (broup_id != null) {
          int broupId = int.parse(broup_id);
          if (loggedIn) {
            Storage().fetchBroup(broupId).then((value) {
              _instance.navigateChat = true;
              _instance.navigateChatId = broupId;
              // The direct navigation to the chat is wonky, so we will instead navigate to home
              // From the home screen we will identify the navigation and navigate to the chat there.
              _instance._navigationService.navigateTo(routes.BroHomeRoute);
              return;
            });
          } else {
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
    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      // bg
    } else {
      // FOREGROUND
    }

    await executeLongTaskInBackground();
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    _instance._firebaseTokenDevice = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    _instance._nativeToken = token;
    _instance.notifyListeners();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************

  static Future<void> executeLongTaskInBackground() async {
  }

  static Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  ///  *********************************************
  ///     REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
      }
    }
    return '';
  }
}
