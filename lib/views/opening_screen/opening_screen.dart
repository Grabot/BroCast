import 'dart:io';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/sign_in/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/game_start_login.dart';
import '../../utils/notification_controller.dart';

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool isLoading = false;
  bool acceptEULA = false;

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    HelperFunction.getEULA().then((val) {
      if (val == null || val == false) {
        // first time opening this app!
        setState(() {
          acceptEULA = true;
        });
      } else {
        acceptEULA = false;
        startUp(false);
      }
    });
    super.initState();
  }

  exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void startUp(bool showRegister) {
    setState(() {
      isLoading = true;
    });
    // TODO: If the user logs in with a different user that is in the storage. Make sure you clear the storage before adding the new data.
    loginCheck().then((loggedIn) {
      if (loggedIn) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(
                    key: UniqueKey(),
                )
            ),
            // ModalRoute.withName(routes.BroHomeRoute)
        );
        return;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SignIn(
                  key: UniqueKey(),
                  showRegister: showRegister
                )
            ),
            // ModalRoute.withName(routes.SignInRoute)
        );
        return;
      }
    });
  }

  void agreeAndContinue() {
    HelperFunction.setEULA(true).then((val) {
      startUp(true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          exitApp();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff145C9E),
            title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    "BroCast",
                    style: TextStyle(color: Colors.white)
                )
            )),
        body: Stack(
          children: [
            acceptEULA
                ? Container(
                    child: Container(
                        alignment: Alignment.center,
                        child: Column(children: [
                          Expanded(
                              child: SingleChildScrollView(
                            reverse: true,
                            child: Column(children: [
                              SizedBox(height: 40),
                              Container(
                                  child: Text("Welcome to BroCast!",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30))),
                              Container(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                      "assets/images/brocast_transparent.png")),
                              SizedBox(height: 50),
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Read our ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            launch(brocastPrivacyUrl);
                                          },
                                          child: Text(
                                            "privacy policy.",
                                            style: TextStyle(
                                                color: Colors.lightBlue,
                                                fontSize: 16,
                                                decoration:
                                                    TextDecoration.underline),
                                          ))
                                    ]),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Tap \"Agree and continue\" to ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ]),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "accept the ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            launch(brocastTermsUrl);
                                          },
                                          child: Text(
                                            "Terms and Service.",
                                            style: TextStyle(
                                                color: Colors.lightBlue,
                                                fontSize: 16,
                                                decoration:
                                                    TextDecoration.underline),
                                          ))
                                    ]),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                child: Text(
                                  'Agree and continue',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)
                                ),
                                onPressed: () {
                                  agreeAndContinue();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 80, vertical: 5),
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(height: 80),
                              Text(
                                "from",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 12),
                              ),
                              SizedBox(height: 6),
                              zwaarDevelopersLogo(200, true),
                              Text(
                                "developers",
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 20),
                              ),
                              SizedBox(height: 40),
                            ]
                            ),
                          )
                        ),
                      ]
                    )
                  )
                ) : Container(
                    child: Center(
                        // The opening screen will always be a loading screen,
                        // so we also show the circular progress indicator
                        child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }
}
