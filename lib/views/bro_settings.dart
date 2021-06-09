import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
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

    BackButtonInterceptor.add(myInterceptor);
  }

  void goToDifferentChat(BroBros chatBro) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BroMessaging(broBros: chatBro)));
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
          }
      ),
      title: Container(alignment: Alignment.centerLeft, child: Text("Settings")),
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
          ]
        )
      ]
    );
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
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(children: [
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      alignment: Alignment.center,
                      child:
                          Image.asset("assets/images/brocast_transparent.png")),
                  SizedBox(height: 40),
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
