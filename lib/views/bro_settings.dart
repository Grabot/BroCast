import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/storage.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import "package:flutter/material.dart";
import 'package:app_settings/app_settings.dart';
import 'package:flutter/scheduler.dart';
import 'bro_profile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

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

    BackButtonInterceptor.add(myInterceptor);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      settings.doneRoutes.add(routes.ChatRoute);
    });
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void toggledEmojiKeyboardDarkMode(darkValue) {
    // storage.selectUser().then((value) {
    //   if (value != null) {
    //     // This has to be true, otherwise he couldn't have logged in!
    //     value.keyboardDarkMode = darkValue ? 1 : 0;
    //     storage.updateUser(value).then((value) {});
    //   }
    // });
    settings.setEmojiKeyboardDarkMode(darkValue);
    setState(() {
      toggleSwitchKeyboard = darkValue;
    });
  }

  void backButtonFunctionality() {
    if (settings.doneRoutes.contains(routes.BroHomeRoute)) {
      // We want to pop until we reach the BroHomeRoute
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  clearMessages() async {
    await storage.clearMessages();
    showToastMessage("Messages cleared");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarSettings(context),
        body: Container(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(children: [
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
                  // TextButton(
                  //   style: ButtonStyle(
                  //     foregroundColor:
                  //         MaterialStateProperty.all<Color>(Colors.blue),
                  //   ),
                  //   onPressed: AppSettings.openNotificationSettings,
                  //   child: Text('Open notification Settings'),
                  // ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: clearMessages,
                    child: Text('clear all messages'),
                  ),
                  SizedBox(height: 150),
                ]),
              ),
            ),
          ]),
        ));
  }
}
