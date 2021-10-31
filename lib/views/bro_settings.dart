import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import "package:flutter/material.dart";

import 'bro_messaging.dart';
import 'bro_profile.dart';

class BroSettings extends StatefulWidget {
  BroSettings({Key key}) : super(key: key);

  @override
  _BroSettingsState createState() => _BroSettingsState();
}

class _BroSettingsState extends State<BroSettings> with WidgetsBindingObserver {
  bool toggleSwitch = false;
  bool showNotification = true;

  @override
  void initState() {
    super.initState();

    HelperFunction.getKeyboardDarkMode().then((val) {
      if (val == null) {
        setState(() {
          toggleSwitch = false;
          Settings.instance.setEmojiKeyboardDarkMode(false);
        });
      } else {
        setState(() {
          toggleSwitch = val;
          Settings.instance.setEmojiKeyboardDarkMode(toggleSwitch);
        });
      }
    });
    initSockets();
    NotificationService.instance.setScreen(this);
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSockets() {
    SocketServices.instance.socket
        .on('message_event_send_solo', (data) => messageReceivedSolo(data));
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      for (Chat br0 in BroList.instance.getBros()) {
        if (!br0.isBroup) {
          if (br0.id == data["sender_id"]) {
            if (showNotification) {
              NotificationService.instance
                  .showNotification(br0.id, br0.chatName, "", data["body"]);
            }
          }
        }
      }
    }
  }

  void goToDifferentChat(Chat chatBro) {
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroMessaging(chat: chatBro)));
    }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  void toggledEmojiKeyboardDarkMode(value) {
    HelperFunction.setKeyboardDarkMode(value);
    Settings.instance.setEmojiKeyboardDarkMode(value);
    setState(() {
      toggleSwitch = value;
    });
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => BroCastHome()));
  }

  Widget appBarSettings(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              backButtonFunctionality();
            }),
        title:
            Container(alignment: Alignment.centerLeft, child: Text("Settings")),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelect(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Profile")),
                    PopupMenuItem<int>(
                        value: 1,
                        child: Row(children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 8),
                          Text("Log Out")
                        ]))
                  ])
        ]);
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile()));
        break;
      case 1:
        HelperFunction.logOutBro().then((value) {
          ResetRegistration resetRegistration = new ResetRegistration();
          resetRegistration.removeRegistrationId(Settings.instance.getBroId());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        });
        break;
    }
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
                        value: toggleSwitch,
                        onChanged: (value) {
                          toggledEmojiKeyboardDarkMode(value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 300),
                ]),
              ),
            ),
          ]),
        ));
  }
}
