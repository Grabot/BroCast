import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/user.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
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
  Auth auth = new Auth();

  late Storage storage;

  @override
  void initState() {
    storage = Storage();

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

    SocketServices.instance;
    storage.selectUser().then((user) async {
      if (user != null) {
        signIn(user);
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
      }
    });
  }

  signIn(User user) {
    setState(() {
      isLoading = true;
    });

    auth.signIn("", "", "", user.token).then((val) {
      if (val.toString() == "") {
        // TODO: @Skools do the login/navigation different?
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) =>
              BroCastHome(
                  key: UniqueKey()
              )));
        }
      } else {
        if (val == "The given credentials are not correct!") {
          // token didn't work, going to check if a username is given and try to log in using password username
          if (user.broName.isNotEmpty && user.bromotion.isNotEmpty && user.password.isNotEmpty) {
            signInName(user.broName, user.bromotion, user.password);
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignIn()));
            }
          }
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
            context, MaterialPageRoute(builder: (context) => BroCastHome(
            key: UniqueKey()
        )));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
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
          acceptEULA ? Container(
            child: Container(
                alignment: Alignment.center,
              child: Column(children: [
              Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(children: [
                  SizedBox(height:40),
                  Container(
                      child: Text(
                          "Welcome to Brocast!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30
                          )
                      )
                  ),
                  Container(
                      alignment: Alignment.center,
                      child:
                      Image.asset("assets/images/brocast_transparent.png")
                  ),
                  SizedBox(height: 50),
                  Container(
                    width: MediaQuery.of(context).size.width*1,
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
                        )
                    )
                        ]
                ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tap \"Agree and continue\" to ",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ]
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*1,
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
                              )
                          )
                        ]
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Agree and continue'),
                    onPressed: () {
                      agreeAndContinue();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 5),
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
                ]
                ),
              )
              ),
              ]
              )
            )
          )
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
