import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/shared.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/storage.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import '../bro_profile/bro_profile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../chat_view/messaging_change_notifier.dart';

class BroSettings extends StatefulWidget {
  BroSettings({required Key key}) : super(key: key);

  @override
  _BroSettingsState createState() => _BroSettingsState();
}

class _BroSettingsState extends State<BroSettings> {
  bool toggleSwitchKeyboard = false;
  bool toggleSwitchSound = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  Storage storage = Storage();

  @override
  void initState() {
    super.initState();

    storage = Storage();
    socketServices.checkConnection();

    toggleSwitchKeyboard = settings.getEmojiKeyboardDarkMode();

  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggledEmojiKeyboardDarkMode(darkValue) {
    HelperFunction.setDarkKeyboard(darkValue).then((value) {
      settings.setEmojiKeyboardDarkMode(darkValue);
      setState(() {
        toggleSwitchKeyboard = darkValue;
      });
    });
  }

  backButtonFunctionality() {
    print("back settings");
    if (settings.doneRoutes.contains(routes.BroHomeRoute)) {
      settings.doneRoutes.removeLast();
      for (int i = 0; i < 200; i++) {
        String route = settings.doneRoutes.removeLast();
        Navigator.pop(context);
        if (route == routes.BroHomeRoute) {
          break;
        }
        if (settings.doneRoutes.length == 0) {
          break;
        }
      }
    } else {
      settings.doneRoutes = [];
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
    }
  }

  PreferredSize appBarSettings(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Settings",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: getTextColor(Colors.white)),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        // Navigate to profile. It's possible he's been there before.
        if (settings.doneRoutes.contains(routes.ProfileRoute)) {
          // We want to pop until we reach the BroHomeRoute
          // We remove one, because it's this page.
          settings.doneRoutes.removeLast();
          for (int i = 0; i < 200; i++) {
            String route = settings.doneRoutes.removeLast();
            Navigator.pop(context);
            if (route == routes.ProfileRoute) {
              break;
            }
            if (settings.doneRoutes.length == 0) {
              break;
            }
          }
        } else {
          // Probably he's not been there before, so we just push it.
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BroProfile(key: UniqueKey())));
        }
        break;
      case 1:
        // Navigate to Home
        if (settings.doneRoutes.contains(routes.BroHomeRoute)) {
          // We want to pop until we reach the BroHomeRoute
          // We remove one, because it's this page.
          settings.doneRoutes.removeLast();
          for (int i = 0; i < 200; i++) {
            String route = settings.doneRoutes.removeLast();
            Navigator.pop(context);
            if (route == routes.BroHomeRoute) {
              break;
            }
            if (settings.doneRoutes.length == 0) {
              break;
            }
          }
        } else {
          // TODO: How to test this?
          settings.doneRoutes = [];
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
        }
        break;
    }
  }

  clearMessages() async {
    await storage.clearMessages();
    showToastMessage("Messages cleared");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        print("didPop settings: $didPop");
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: appBarSettings(context),
        body: Container(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                    children: [
                      Container(
                          child: Text("BroCast",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 30))),
                  Container(
                      alignment: Alignment.center,
                      child:
                          Image.asset("assets/images/brocast_transparent.png")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Emoji keyboard Dark Mode",
                          style: simpleTextStyle()),
                      Switch(
                        value: toggleSwitchKeyboard,
                        onChanged: (value) {
                          toggledEmojiKeyboardDarkMode(value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                    ),
                    // onPressed: AppSettings.openNotificationSettings,
                    onPressed: () {
                      print("TODO: implement!");
                    },
                    child: Text('Open notification Settings'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      showDialogClearMessages(context);
                    },
                    child: Text('clear all messages'),
                  ),
                  SizedBox(height: 150),
                ]),
              ),
            ),
          ]),
        )
      ),
    );
  }

  showDialogClearMessages(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Are you sure?\nThis will clear ALL your messages!"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Clear"),
                onPressed: () {
                  clearMessages();
                },
              ),
            ],
          );
        });
  }
}
