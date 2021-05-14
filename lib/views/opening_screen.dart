import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/notification_services.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'bro_home.dart';
import 'bro_messaging.dart';

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {

  bool isLoading = false;
  Auth auth = new Auth();

  @override
  void initState() {
    NotificationService.instance;
    NotificationService.instance.setScreen(this);
    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        // TODO: @Skools go to signin screen
        // no token yet
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
        goHomeOrToChatNotification();
      } else {
        if (val == "The given credentials are not correct!") {
          // token didn't work, going to check if a username is given and try to log in using password username
          HelperFunction.getBroInformation().then((val) {
            if (val == null || val.length == 0) {
              // TODO: @SKools go to signin screen
            } else {
              String broName = val[0];
              String bromotion = val[1];
              String broPassword = val[2];
              singInName(broName, bromotion, broPassword);
            }
          });
        } else {
          ShowToastComponent.showDialog(val.toString(), context);
          // TODO: @SKools go to signin screen
        }
      }
    });
  }

  singInName(String broName, String bromotion, String password) {
    auth.signIn(broName, bromotion, password, "").then((val) {
      if (val.toString() == "") {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroCastHome()
        ));
      } else {
        // TODO: @SKools navigate to sign in screen
      }
    });
  }

  void goHomeOrToChatNotification() async {
    await Firebase.initializeApp();
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Map<String, dynamic> broResult = initialMessage.data;
      if (broResult != null) {
        String broName = broResult["bro_name"];
        String bromotion = broResult["bromotion"];
        String broId = broResult["id"];
        if (broName != null && bromotion != null && broId != null) {
          Bro broNotify = Bro(int.parse(broId), broName, bromotion);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => BroMessaging(bro: broNotify)
          ));
        }
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => BroCastHome()
      ));
    }
  }

  void goToDifferentChat(Bro chatBro) {
    // not doing it here, first log in.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(context, false),
        body: Stack(
        ),
    );
  }
}