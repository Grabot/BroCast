import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/user.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/notification_util.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bro_home.dart';

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool isLoading = false;
  bool acceptEULA = false;
  late Storage storage;

  @override
  void initState() {
    NotificationUtil();

    // Initialize the db on startup
    storage = Storage();
    storage.database;
    HelperFunction.getEULA().then((val) {
      if (val == null || val == false) {
        // first time opening this app!
        setState(() {
          acceptEULA = true;
        });
      } else {
        acceptEULA = false;
        startUp();
      }
    });
    super.initState();
  }

  void startUp() {
    setState(() {
      isLoading = true;
    });

    storage.selectUser().then((user) async {
      if (user != null) {
        BroList broList = BroList();
        broList.searchBros(user.token).then((value) {
          if (value) {
            user.recheckBros = 0;
            user.updateActivityTime();
            storage.updateUser(user).then((value) {});
            Auth auth = Auth();
            auth.signInUser(user).then((value) {
              if (mounted && value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BroCastHome(key: UniqueKey())));
              } else {
                if (mounted) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignIn(key: UniqueKey())));
                }
              }
            });
          } else {
            ShowToastComponent.showDialog(
                "cannot retrieve brocast information at this time.", context);
            setState(() {
              isLoading = false;
            });
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SignIn(key: UniqueKey())));
          }
        });
      } else {
        // no user in database! But maybe in shared preferences
        HelperFunction.getBroToken().then((tok) {
          if (tok == null || tok == "") {
            // no token currently in the shared preferences, maybe name and password?
            HelperFunction.getBroInformation().then((val) {
              if (val != null && val.length != 0) {
                String broName = val[0];
                String bromotion = val[1];
                String broPassword = val[2];
                Auth auth = Auth();
                User user =
                    new User(-1, broName, bromotion, broPassword, "", "", 1, 0);
                auth.signInUser(user).then((value) {
                  if (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BroCastHome(key: UniqueKey())));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignIn(key: UniqueKey())));
                  }
                });
              } else {
                // If there is nothing in the shared preferences than we will assume that it is a new user and we go to the sign in screen
                setState(() {
                  isLoading = false;
                });
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignIn(key: UniqueKey())));
              }
            });
          } else {
            // There is a token. We will create a user with what we find in the shared preferences.
            HelperFunction.getBroInformation().then((val) {
              if (val != null && val.length != 0) {
                // we will assume that it can get this information
                String broName = val[0];
                String bromotion = val[1];
                String broPassword = val[2];

                Auth auth = Auth();
                User user = new User(
                    -1, broName, bromotion, broPassword, tok, "", 1, 0);
                auth.signInUser(user).then((value) {
                  if (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BroCastHome(key: UniqueKey())));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignIn(key: UniqueKey())));
                  }
                });
              } else {
                // that didin't seem to work, let's pray that just the token works
                Auth auth = Auth();
                User user = new User(-1, "", "", "", tok, "", 1, 0);
                auth.signInUser(user).then((value) {
                  if (value) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BroCastHome(key: UniqueKey())));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignIn(key: UniqueKey())));
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  void agreeAndContinue() {
    HelperFunction.setEULA(true).then((val) {
      startUp();
    });
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
                                child: Text("Welcome to Brocast!",
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
                              child: Text('Agree and continue'),
                              onPressed: () {
                                agreeAndContinue();
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
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
                            Text(
                              "Zwaar developers",
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                          ]),
                        )),
                      ])))
              : Container(
                  child: Center(
                      // The opening screen will always be a loading screen,
                      // so we also show the circular progress indicator
                      child: CircularProgressIndicator()))
        ],
      ),
    );
  }
}
