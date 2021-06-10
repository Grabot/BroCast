import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';

import 'bro_home.dart';

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool isLoading = false;
  Auth auth = new Auth();

  @override
  void initState() {
    NotificationService.instance.setScreen(null);
    HelperFunction.getKeyboardDarkMode().then((val) {
      if (val == null) {
        // no dark mode setting set yet.
        Settings.instance.setEmojiKeyboardDarkMode(false);
      } else {
        setState(() {
          Settings.instance.setEmojiKeyboardDarkMode(val);
        });
      }
    });
    SocketServices.instance;
    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      } else {
        signIn(val.toString());
      }
    });
    super.initState();
  }

  signIn(String token) {
    setState(() {
      isLoading = true;
    });

    auth.signIn("", "", "", token).then((val) {
      if (val.toString() == "") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroCastHome()));
      } else {
        if (val == "The given credentials are not correct!") {
          // token didn't work, going to check if a username is given and try to log in using password username
          HelperFunction.getBroInformation().then((val) {
            if (val == null || val.length == 0) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignIn()));
            } else {
              String broName = val[0];
              String bromotion = val[1];
              String broPassword = val[2];
              signInName(broName, bromotion, broPassword);
            }
          });
        } else {
          ShowToastComponent.showDialog(val.toString(), context);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        }
      }
    });
  }

  signInName(String broName, String bromotion, String password) {
    auth.signIn(broName, bromotion, password, "").then((val) {
      if (val.toString() == "") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroCastHome()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      }
    });
  }

  void goToDifferentChat(BroBros chatBro) {
    // not doing it here, first log in.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
              alignment: Alignment.centerLeft, child: Text("Brocast"))),
      body: Stack(
        children: [
          Container(
              child: Center(
                  // The opening screen will always be a loading screen,
                  // so we also show the circular progress indicator
                  child: CircularProgressIndicator()))
        ],
      ),
    );
  }
}
