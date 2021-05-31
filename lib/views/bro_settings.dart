import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import "package:flutter/material.dart";

import 'bro_messaging.dart';

class BroSettings extends StatefulWidget {

  // final SocketServices socket;

  BroSettings({ Key key }): super(key: key);

  @override
  _BroSettingsState createState() => _BroSettingsState();
}

class _BroSettingsState extends State<BroSettings> {

  bool toggleSwitch = false;

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

    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  void goToDifferentChat(BroBros chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(broBros: chatBro)
    ));
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroCastHome()
    ));
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void toggledEmojiKeyboardDarkMode(value) {
    HelperFunction.setKeyboardDarkMode(value);
    Settings.instance.setEmojiKeyboardDarkMode(value);
    setState(() {
      toggleSwitch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(context, true, "Settings"),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children:
                    [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/brocast.png")
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "Emoji keyboard Dark Mode",
                              style: simpleTextStyle()
                          ),
                          Switch(
                            value: toggleSwitch,
                            onChanged: (value){
                              toggledEmojiKeyboardDarkMode(value);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 300),
                    ]
                  ),
                ),
              ),
            ]
          ),
        )
      );
  }
}

