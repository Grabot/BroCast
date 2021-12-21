import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import "package:flutter/material.dart";
import 'package:app_settings/app_settings.dart';
import 'bro_profile.dart';


class BroSettings extends StatefulWidget {
  BroSettings(
      {
        required Key key
      }) : super(key: key);

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
    storage.selectUser().then((value) {
      if (value != null) {
        // This has to be true, otherwise he couldn't have logged in!
        value.keyboardDarkMode = darkValue ? 1 : 0;
        storage.updateUser(value).then((value) {
        });
      }
    });
    settings.setEmojiKeyboardDarkMode(darkValue);
    setState(() {
      toggleSwitchKeyboard = darkValue;
    });
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => BroCastHome(
      key: UniqueKey()
    )));
  }

  PreferredSize appBarSettings(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
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
                      PopupMenuItem<int>(value: 1, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile(
          key: UniqueKey()
        )));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroCastHome(
            key: UniqueKey()
        )));
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
                      MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: AppSettings.openNotificationSettings,
                    child: Text('Open notification Settings'),
                  ),
                  SizedBox(height: 300),
                ]),
              ),
            ),
          ]),
        ));
  }
}
