import 'package:brocast/services/auth/v1_4/auth_service_login.dart';
import 'package:brocast/utils/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/utils.dart';

class ForgotPassword extends StatefulWidget {

  final bool showRegister;

  ForgotPassword({
    required Key key,
    required this.showRegister
  }) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  bool showEmojiKeyboard = false;

  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  ScrollController signScrollController = ScrollController();

  FocusNode focusEmail = FocusNode();

  bool emojiKeyboardDarkMode = false;

  @override
  void initState() {
    setState(() {
      emojiKeyboardDarkMode = settings.getEmojiKeyboardDarkMode();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
    }));
    super.initState();
  }

  backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      // There is nowhere else to go from this screen but back to the sign in screen.
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        backButtonFunctionality();
        break;
    }
  }

  forgotPasswordInformation() {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            children: [
              TextSpan(
                  text: "Please enter your e-mail address. We will send you an e-mail with a link.\n"
              ),
              TextSpan(
                  text: "If you did not create an account with Brocast or created it using Google, Apple, Reddit or Github. Than no email will be send."
              )
            ]
        )
    );

  }

  forgotPasswordForm() {
    // The form only validates the fields that are in view.
    if (formKey.currentState!.validate()) {
      String emailToSend = emailController.text;
      AuthServiceLogin().getForgotPassword(emailToSend).then((value) {
        if (value) {
          showToastMessage("An email will be send to $emailToSend. This might take a few minutes");
        }
        backButtonFunctionality();
      });
    }
  }

  Widget emailTextField() {
    return Expanded(
      child: TextFormField(
        focusNode: focusEmail,
        onTap: () {
        },
        validator: (val) {
          if (val != null) {
            if (!emailValid(val)) {
              return "Email not formatted correctly";
            }
          }
          return val == null || val.isEmpty
              ? "Please provide an Email"
              : null;
        },
        controller: emailController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(),
        decoration: textFieldInputDecoration("Email"),
      ),
    );
  }

  Widget emailInputField() {
    return Row(
      children: [
        SizedBox(width: 20),
        emailTextField(),
        SizedBox(width: 20),
      ],
    );
  }

  Widget signInButton() {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          forgotPasswordForm();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xBf007EF4),
              const Color(0xff2A75BC)
            ]),
            borderRadius: BorderRadius.circular(30)),
        child: Text("Submit",
            style: simpleTextStyle())
      ),
    );
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
          appBar: AppBar(
            backgroundColor: Color(0xff145C9E),
            title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Forgot password",
                    style: TextStyle(color: Colors.white)
                )),
            actions: [
              PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (item) => onSelect(context, item),
                  itemBuilder: (context) => [
                        PopupMenuItem<int>(value: 0, child: Text("Back to Sign in")),
                      ]),
            ],
          ),
          body: Stack(children: [
              isLoading
                  ? Container(child: Center(child: CircularProgressIndicator()))
                  : Container(),
              Container(
                child: Column(
                    children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: signScrollController,
                      reverse: true,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        "assets/images/brocast_transparent.png")
                                ),
                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
                                      forgotPasswordInformation(),
                                      SizedBox(height: 20),
                                      emailInputField(),
                                      SizedBox(height: 20),
                                      signInButton(),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 300),
                              ],
                            ),
                      ),
                    ),
                  ),
                ]
                ),
              ),
            ]),
          ),
    );
  }
}
