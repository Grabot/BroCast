import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:brocast/services/auth/v1_4/auth_service_login.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/sign_in/signin.dart';
import "package:flutter/material.dart";


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
                icon: Icon(Icons.more_vert, color: Colors.white),
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

  deleteAccount() {
    AuthServiceLogin().deleteAccount().then((baseResponse) {
      if (baseResponse.getResult()) {
        Storage().clearDatabase();
        Navigator.of(context).pop();
        actuallyLogout(settings, socketServices, context);
        showToastMessage("Account deleted");

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SignIn(
                key: UniqueKey(),
                showRegister: false
            )));
      }
    });;
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
                          child: Text("Brocast",
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
                    onPressed: () async {
                      await AwesomeNotifications().showNotificationConfigPage();
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open notification Settings',
                            style: TextStyle(color: Colors.blue, fontSize: 18)
                          ),
                      ]
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      showDialogClearMessages(context);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'clear all messages',
                            style: TextStyle(color: Colors.blue, fontSize: 18)
                          ),
                      ]
                    ),
                  ),
                      TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          showDialogDeleteAccount(context);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 20),
                              Text(
                                "Delete account",
                                  style: TextStyle(color: Colors.blue, fontSize: 18)
                              ),
                            ]),
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
            title: new Text("Clear messages?"),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Are you sure?\nThis will clear ALL your messages!",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
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

  showDialogDeleteAccount(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Delete account?"),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Are you sure?\nThis will delete your account and all the data associated with it!",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Delete"),
                onPressed: () {
                  deleteAccount();
                },
              ),
            ],
          );
        });
  }
}
