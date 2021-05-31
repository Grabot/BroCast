import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool isLoading = false;
  bool showEmojiKeyboard = false;

  bool signUpMode;

  Auth auth = new Auth();

  final formKey = GlobalKey<FormState>();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool emojiKeyboardDarkMode = false;

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    bromotionController.addListener(bromotionListener);
    signUpMode = false;
    NotificationService.instance.setScreen(this);
    // If credentials are stored we will automatically sign in, but we will also set it on the textfields just for usability reasons (in case logging in fails)
    HelperFunction.getBroInformation().then((val) {
      if (val == null || val.length == 0) {
        setState(() {
          isLoading = false;
        });
        // no token yet
      } else {
        String broName = val[0];
        String bromotion = val[1];
        String password = val[2];
        broNameController.text = broName;
        bromotionController.text = bromotion;
        passwordController.text = password;
      }
    });
    HelperFunction.getKeyboardDarkMode().then((val) {
      if (val == null) {
        // no dark mode setting set yet.
      } else {
        setState(() {
          emojiKeyboardDarkMode = val;
        });
      }
    });
    super.initState();
  }

  void goToDifferentChat(BroBros chatBro) {
    // not doing it here, first log in.
  }

  bromotionListener() {
    bromotionController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionController.text.replaceFirst(lastEmoji, "");
      bromotionController.text = newText;
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      return false;
    }
  }

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onTapEmojiField() {
    if (!showEmojiKeyboard) {
      // We add a quick delay, this is to ensure that the keyboard is gone at this point.
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  signInForm() {
    if (formKey.currentState.validate()) {
      if (signUpMode) {
        signUp();
      } else {
        signInName(broNameController.text, bromotionController.text, passwordController.text);
      }
    }
  }

  signUp() {
    setState(() {
      isLoading = true;
    });

    auth.signUp(broNameController.text, bromotionController.text, passwordController.text).then((val) {
      if (val.toString() == "") {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroCastHome()
        ));
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  signInName(String broName, String bromotion, String password) {
    auth.signIn(broName, bromotion, password, "").then((val) {
      if (val.toString() == "") {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroCastHome()
        ));
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, false, "Bro Cast"),
      // TODO: @Skools check if this is really needed (without it the emoji keyboard jumps on top of the other for a split second)
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          isLoading ? Container(
              child: Center(
                  child: CircularProgressIndicator())
          ) : Container(),
          Container(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Container(
                              height: 120.0,
                              width: 120.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/brocast_transparent.png'),
                                  fit: BoxFit.fill,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 100),
                            Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      onTap: () {
                                        if (!isLoading) {
                                          onTapTextField();
                                        }
                                      },
                                      validator: (val) {
                                        return val.isEmpty ? "Please provide a bro name": null;
                                      },
                                      controller: broNameController,
                                      textAlign: TextAlign.center,
                                      style: simpleTextStyle(),
                                      decoration: textFieldInputDecoration("Bro name"),
                                    ),
                                  ),
                                  SizedBox(width: 50),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      onTap: () {
                                        if (!isLoading) {
                                          onTapEmojiField();
                                        }
                                      },
                                      validator: (val) {
                                        return val.trim().isEmpty ? "😢?😄!": null;
                                      },
                                      controller: bromotionController,
                                      style: simpleTextStyle(),
                                      textAlign: TextAlign.center,
                                      decoration: textFieldInputDecoration("😀"),
                                      readOnly: true,
                                      showCursor: true,
                                    ),
                                  ),
                                ]
                            ),
                            SizedBox(height: 30),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              child: TextFormField(
                                onTap: () {
                                  if (!isLoading) {
                                    onTapTextField();
                                  }
                                },
                                obscureText: true,
                                validator: (val) {
                                  return val.isEmpty ? "Please provide a password": null;
                                },
                                controller: passwordController,
                                textAlign: TextAlign.center,
                                style: simpleTextStyle(),
                                decoration: textFieldInputDecoration("Password"),
                              ),
                            ),
                            SizedBox(height: 60),
                            GestureDetector(
                              onTap: () {
                                if (!isLoading) {
                                  signInForm();
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color(0xBf007EF4),
                                          const Color(0xff2A75BC)
                                        ]
                                    ),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: signUpMode ? Text("Sign up", style: simpleTextStyle()) : Text("Sign in", style: simpleTextStyle()),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Text("Don't have an account?  ", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16
                                  ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!isLoading) {
                                        setState(() {
                                          signUpMode = !signUpMode;
                                        });
                                        // Navigator.pushReplacement(context, MaterialPageRoute(
                                        //     builder: (context) => SignUp()
                                        // ));
                                      }
                                    },
                                    child: signUpMode ? Text("Login now!", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: TextDecoration.underline
                                      ),
                                    ) : Text("Register now!", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        decoration: TextDecoration.underline
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 60),
                          ],
                        )
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                  bromotionController: bromotionController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: Settings.instance.getEmojiKeyboardDarkMode()
                ),
              ),
            ]),
          ),
        ]
      )
    );
  }
}