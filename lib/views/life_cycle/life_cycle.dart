import 'dart:io';

import 'package:brocast/utils/start_login.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:flutter/services.dart';

import '../../objects/me.dart';
import '../../services/auth/auth_service_social.dart';
import '../../utils/life_cycle_service.dart';
import '../../utils/locator.dart';
import '../../utils/navigation_service.dart';
import '../../utils/settings.dart';
import '../bro_home/bro_home.dart';
import '../sign_in/signin.dart';

class LifeCycle extends StatefulWidget {

  const LifeCycle({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<LifeCycle> createState() => _LifeCycleState();
}

class _LifeCycleState extends State<LifeCycle> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool lifeCycleLoggingIn = false;
  final NavigationService _navigationService = locator<NavigationService>();

  exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    try {
      switch (state) {
        case AppLifecycleState.paused:
          if (!lifeCycleLoggingIn) {
            if (MessagingChangeNotifier().broupId != -1) {
              AuthServiceSocial().chatOpen(MessagingChangeNotifier().broupId, false);
            }
            LifeCycleService().setAppStatus(0);
            // At this point we just exit the app.
          }
          // We want to close the app, but give it a second to finish some requests.
          Future.delayed(Duration(milliseconds: 100), () {
            exitApp();
          });
          break;
        case AppLifecycleState.resumed:
          // There are some issues when resuming the app. The socket connection is not sturdy or something.
          // We will check if any new events have been missed by logging in again.
          if (LifeCycleService().getAppStatus() == 1) {
            // The app was inactive, we don't want to login again.
            return;
          }
          lifeCycleLoggingIn = true;
          Me? me = Settings().getMe();
          if (me != null) {
            // we want to login again, but not if the previous state was
            // inactive, since it's just a short periodic look away state
            Settings settings = Settings();
            if (settings.loggingIn) {
              // Already logging in, we assume that after that other login
              // process is done it will navigate somewhere
              LifeCycleService().setAppStatus(1);
              return;
            }
            settings.setLoggingIn(true);
            loginCheck().then((loggedIn) {
              settings.setLoggingIn(false);
              lifeCycleLoggingIn = false;
              LifeCycleService().setAppStatus(1);
              print("App resumed logged in $loggedIn");
              if (!loggedIn) {
                _navigationService.navigateTo(routes.SignInRoute);
              }
            });
          } else {
            LifeCycleService().setAppStatus(1);
          }
          break;
        case AppLifecycleState.detached:
          if (!lifeCycleLoggingIn) {
            LifeCycleService().setAppStatus(2);
            print("App detached");
          }
          break;
        case AppLifecycleState.inactive:
          if (!lifeCycleLoggingIn) {
            // We don't actually care about the inactive state.
            // It means the app is running, but not in the foreground right now.
            // We will take this as active.
            // LifeCycleService().setAppStatus(3);
            print("App inactive");
          }
          break;
        default:
          break;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}