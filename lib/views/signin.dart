import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/user.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth/auth_service_login.dart';
import '../services/auth/models/register_request.dart';
import '../utils/utils.dart';

class SignIn extends StatefulWidget {
  SignIn({required Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  bool showEmojiKeyboard = false;

  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool emojiKeyboardDarkMode = false;

  late Storage storage;

  bool loginBroName = true;
  bool signUpMode = false;

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    bromotionController.addListener(bromotionListener);

    storage = Storage();

    setState(() {
      emojiKeyboardDarkMode = settings.getEmojiKeyboardDarkMode();
    });
    super.initState();
  }

  bromotionListener() {
    bromotionController.selection =
        TextSelection.fromPosition(TextPosition(offset: 0));
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
    bromotionController.addListener(bromotionListener);
    broNameController.dispose();
    emailController.dispose();
    bromotionController.dispose();
    passwordController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
        break;
    }
  }

  register() {
    String broNameLogin = broNameController.text.trimRight();
    String bromotionLogin = bromotionController.text;
    String passwordLogin = passwordController.text;
    String emailLogin = emailController.text;

    print("broNameLogin: $broNameLogin");
    print("bromotionLogin: $bromotionLogin");
    print("passwordLogin: $passwordLogin");
    print("emailLogin: $emailLogin");
    // This issue should not be possible, but check if the required fields are filled anyway
    if (emailLogin == "" || broNameLogin == "" || bromotionLogin == "" || passwordLogin == "") {
      showToastMessage("Please fill in the email, bro name, bromotion and password field");
      return;
    }
    isLoading = true;
    AuthServiceLogin authService = AuthServiceLogin();
    RegisterRequest registerRequest = RegisterRequest(emailLogin, broNameLogin, bromotionLogin, passwordLogin);
    authService.getRegister(registerRequest).then((loginResponse) {
      if (loginResponse.getResult()) {
        isLoading = false;
        // TODO: move to main screen?
        setState(() {});
      } else if (!loginResponse.getResult()) {
        showToastMessage(loginResponse.getMessage());
        isLoading = false;
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
      isLoading = false;
    });
  }

  login() {
    String broNameLogin = broNameController.text.trimRight();
    String bromotionLogin = bromotionController.text;
    String passwordLogin = passwordController.text;
    String emailLogin = emailController.text;

    if (loginBroName) {
      // This issue should not be possible, but check if the required fields are filled anyway
      if (broNameLogin == "" || bromotionLogin == "" || passwordLogin == "") {
        showToastMessage("Please fill in the bro name, bromotion and password field");
        return;
      }
    } else {
      if (emailLogin == "" || passwordLogin == "") {
        showToastMessage("Please fill in the email and password field.");
        return;
      }
    }

    // signInName(broNameSignup, bromotionSignup, passwordSignup);
  }

  signInForm() {
    // The form only validates the fields that are in view.
    if (formKey.currentState!.validate()) {
      if (signUpMode) {
        register();
      } else {
        login();
      }
    }
  }

  Widget broNameTextField() {
    return Expanded(
      child: TextFormField(
        onTap: () {
          if (!isLoading) {
            onTapTextField();
          }
        },
        validator: (val) {
          return val == null || val.isEmpty
              ? "Please provide your bro name"
              : null;
        },
        controller: broNameController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(),
        decoration: textFieldInputDecoration("Bro name"),
      ),
    );
  }

  Widget bromotionTextField() {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        onTap: () {
          if (!isLoading) {
            onTapEmojiField();
          }
        },
        validator: (val) {
          return val == null || val.trim().isEmpty
              ? "😢?😄!"
              : null;
        },
        controller: bromotionController,
        style: simpleTextStyle(),
        textAlign: TextAlign.center,
        decoration: textFieldInputDecoration("😀"),
        readOnly: true,
        showCursor: true,
      ),
    );
  }

  Widget broNameAndBromotionInputField() {
    return Row(
      children: [
        SizedBox(width: 20),
        broNameTextField(),
        SizedBox(width: 20),
        bromotionTextField(),
        SizedBox(width: 20),
      ],
    );
  }

  Widget emailTextField() {
    return Expanded(
      child: TextFormField(
        onTap: () {
          if (!isLoading) {
            onTapTextField();
          }
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

  Widget switchBroNameEmail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          onTap: () {
            if (!isLoading) {
              setState(() {
                loginBroName = !loginBroName;
              });
            }
          },
          child: Row(
            children: [
              loginBroName ? Text(
                "Switch to email",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ) : Text(
                "Switch to Bro name",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
              Icon(Icons.sync, color: Colors.green),
            ]
          ),
        ),
      ],
    );
  }

  Widget passwordInputField() {
    return Row(
      children:
      [
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            onTap: () {
              if (!isLoading) {
                onTapTextField();
              }
            },
            obscureText: true,
            validator: (val) {
              return val == null || val.isEmpty
                  ? "Please provide a password"
                  : null;
            },
            controller: passwordController,
            textAlign: TextAlign.center,
            style: simpleTextStyle(),
            decoration: textFieldInputDecoration("Password"),
          ),
        ),
        SizedBox(width: 20),
      ]
    );
  }

  Widget forgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          onTap: () {
            if (!isLoading) {
              setState(() {
                print("TODO: forgot password");
              });
            }
          },
          child: Row(
              children: [
                Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ]
          ),
        ),
      ],
    );
  }

  Widget signInButton() {
    return GestureDetector(
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
            gradient: LinearGradient(colors: [
              const Color(0xBf007EF4),
              const Color(0xff2A75BC)
            ]),
            borderRadius: BorderRadius.circular(30)),
        child: signUpMode
            ? Text("Register",
            style: simpleTextStyle())
            : Text("Login",
            style: simpleTextStyle()),
      ),
    );
  }

  Widget switchLoginRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: signUpMode
              ? Text(
            "Already have an account?  ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16),
          )
              : Text(
            "Don't have an account?  ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isLoading) {
                setState(() {
                  signUpMode = !signUpMode;
                });
              }
            },
            child: signUpMode
                ? Text(
              "Login now!",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration:
                  TextDecoration.underline),
            )
                : Text(
              "Register now!",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration:
                  TextDecoration.underline),
            ),
          ),
        )
      ],
    );
  }

  Widget loginView() {
    return Column(
      children: [
        loginBroName
            ? broNameAndBromotionInputField()
            : emailInputField(),
        switchBroNameEmail(),
        passwordInputField(),
        SizedBox(height:10),
        forgotPassword(),
      ],
    );
  }

  Widget registerView() {
    return Column(
      children: [
        broNameAndBromotionInputField(),
        emailInputField(),
        passwordInputField(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
              alignment: Alignment.centerLeft, child: Text("Brocast")),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Exit Brocast")),
                    ]),
          ],
        ),
        body: Stack(children: [
            isLoading
                ? Container(child: Center(child: CircularProgressIndicator()))
                : Container(),
            Container(
              child: Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
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
                                    signUpMode ? registerView() : loginView(),
                                    SizedBox(height: 40),
                                    signInButton(),
                                    SizedBox(height:10),
                                    switchLoginRegister()
                                  ],
                                ),
                              ),
                              SizedBox(height: 100),
                            ],
                          ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: EmojiKeyboard(
                        emojiController: bromotionController,
                        emojiKeyboardHeight: 300,
                        showEmojiKeyboard: showEmojiKeyboard,
                        darkMode: emojiKeyboardDarkMode)),
              ]),
            ),
          ]),
        );
  }
}
