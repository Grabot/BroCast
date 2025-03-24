import 'package:brocast/utils/start_login.dart';
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../objects/me.dart';
import '../../utils/life_cycle_service.dart';
import '../../utils/settings.dart';
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    try {
      switch (state) {
        case AppLifecycleState.paused:
          if (!lifeCycleLoggingIn) {
            LifeCycleService().setAppStatus(0);
            print("App paused");
          }
          break;
        case AppLifecycleState.resumed:
          // There are some issues when resuming the app. The socket connection is not sturdy or something.
          // We will check if any new events have been missed by logging in again.
          print("App resumed");
          lifeCycleLoggingIn = true;
          Me? me = Settings().getMe();
          if (me != null) {
            loginCheck().then((loggedIn) {
              lifeCycleLoggingIn = false;
              if (loggedIn) {
                print("App resumed logged in");
                LifeCycleService().setAppStatus(1);
              } else {
                showToastMessage("There was an issue, please log in again");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignIn(
                              key: UniqueKey(),
                              showRegister: false
                          )
                  ),
                );
              }
            });
          } else {
            print("snelle check");
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
            LifeCycleService().setAppStatus(3);
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