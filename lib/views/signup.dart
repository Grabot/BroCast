import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/emoji/keyboard/emoji_keyboard.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broHome.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;
  bool showEmojiKeyboard = false;
  static const double emojiKeyboardHeight = 290;

  Auth auth = new Auth();

  final formKey = GlobalKey<FormState>();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  signUp() {
    if (formKey.currentState.validate()) {
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
  }

  void onTapTextField() {
    print("Tapped the text field");
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onTapEmojiField() {
    print("Tapped the emoji field");
    if (!showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = true;
      });
    }
  }

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(context),
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
                                                return val.isEmpty ? "Please provide bromotion": null;
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
                                          signUp();
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
                                        child: Text("Sign up", style: simpleTextStyle()),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text("Already have an account? ", style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16
                                          ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (!isLoading) {
                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                    builder: (context) => SignIn()
                                                ));
                                              }
                                            },
                                            child: Text("Login now!", style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                decoration: TextDecoration.underline
                                            ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 80),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        curve: Curves.fastOutSlowIn,
                        height: showEmojiKeyboard ? emojiKeyboardHeight : 0,
                        width: MediaQuery.of(context).size.width,
                        duration: new Duration(seconds: 1),
                        child: Container(
                            alignment: Alignment.bottomCenter,
                            child: EmojiKeyboard(
                              bromotionController: bromotionController,
                              emojiKeyboardHeight: emojiKeyboardHeight,
                              signingScreen: true
                            )
                        )
                      )
                    ]),
              ),
            ]
        )
    );
  }
}