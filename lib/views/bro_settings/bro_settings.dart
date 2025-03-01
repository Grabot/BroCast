import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";

import '../../utils/notification_controller.dart';

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
  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();

    storage = Storage();
    socketServices.checkConnection();

    notificationController = NotificationController();
    notificationController.addListener(notificationListener);

    toggleSwitchKeyboard = settings.getEmojiKeyboardDarkMode();

  }

  @override
  void dispose() {
    notificationController.removeListener(notificationListener);
    super.dispose();
  }

  notificationListener() {
    if (notificationController.navigateChat) {
      notificationController.navigateChat = false;
      int chatId = notificationController.navigateChatId;
      storage.fetchBroup(chatId).then((broup) {
        if (broup != null) {
          notificationController.navigateChat = false;
          notificationController.navigateChatId = -1;
          navigateToChat(context, settings, broup);
        }
      });
    }
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
    navigateToHome(context, settings);
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
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToHome(context, settings);
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
