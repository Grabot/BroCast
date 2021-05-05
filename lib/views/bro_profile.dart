import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import "package:flutter/material.dart";

class BroProfile extends StatefulWidget {

  final SocketServices socket;

  BroProfile({ Key key, this.socket }): super(key: key);

  @override
  _BroProfileState createState() => _BroProfileState();
}

class _BroProfileState extends State<BroProfile> {

  final passwordFormValidator = GlobalKey<FormState>();
  final bromotionValidator = GlobalKey<FormFieldState>();

  bool showEmojiKeyboard = false;
  bool bromotionEnabled = false;
  bool changePassword = false;

  SocketServices socket;

  String token;
  String broName;
  String bromotion;
  String broPassword;

  FocusNode focusNodeBromotion;
  FocusNode focusNodePassword;
  TextEditingController bromotionChangeController = new TextEditingController();
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController1 = new TextEditingController();
  TextEditingController newPasswordController2 = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.socket == null) {
      socket = new SocketServices();
      socket.startSockConnection();
    } else {
      socket = widget.socket;
    }

    focusNodeBromotion = new FocusNode();
    focusNodePassword = new FocusNode();
    bromotionChangeController.addListener(bromotionListener);

    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        // We assume this won't happen
        print("no token available, big error");
      } else {
        token = val;
      }
    });

    HelperFunction.getBroInformation().then((val) {
      if (val == null || val.length == 0) {
        // Something went wrong?
      } else {
        setState(() {
          broName = val[0];
          bromotion = val[1];
          bromotionChangeController.text= bromotion;
          broPassword = val[2];
          oldPasswordController.text = broPassword;
        });
      }
    });
    socket.listenForProfileChange(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  bromotionListener() {
    bromotionChangeController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionChangeController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionChangeController.text.replaceFirst(lastEmoji, "");
      bromotionChangeController.text = newText;
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      socket.stopListeningForProfileChange();
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => BroCastHome(socket: socket)
      ));
      return true;
    }
  }

  void onChangePasswordSuccess() {
    broPassword = newPasswordController2.text;
    HelperFunction.setBroInformation(broName, bromotion, broPassword);
    setState(() {
      oldPasswordController.text = broPassword;
      newPasswordController1.text = "";
      newPasswordController2.text = "";
    });
  }

  void onChangePasswordFailed() {
    ShowToastComponent.showDialog("changing password failed due to an unknown error.", context);
    setState(() {
      newPasswordController1.text = "";
      newPasswordController2.text = "";
    });
  }

  void onChangeBromotionSuccess() {
    bromotion = bromotionChangeController.text;
    HelperFunction.setBroInformation(broName, bromotion, broPassword);
  }

  void onChangeBromotionFailedExists() {
    ShowToastComponent.showDialog("BroName bromotion combination exists, please pick a different bromotion", context);
    bromotionChangeController.text = bromotion;
  }

  void onChangeBromotionFailedUnknown() {
    ShowToastComponent.showDialog("an unknown Error has occurred", context);
    bromotionChangeController.text = bromotion;
  }

  void onChangePassword() {
    focusNodePassword.requestFocus();
    setState(() {
      changePassword = true;
    });
  }

  void onSavePassword() {
    if (passwordFormValidator.currentState.validate()) {
      socket.changePassword(token, newPasswordController1.text);
      setState(() {
        changePassword = false;
      });
    }
  }

  void onSaveBromotion() {
    if (bromotionValidator.currentState.validate()) {
      print("going to try to change the bromotion ${bromotionChangeController.text}");
      socket.changeBromotion(token, bromotionChangeController.text);
      setState(() {
        bromotionEnabled = false;
        showEmojiKeyboard = false;
      });
    }
  }

  void onChangeBromotion() {
    focusNodeBromotion.requestFocus();
    setState(() {
      bromotionEnabled = true;
      showEmojiKeyboard = true;
    });
  }

  void onTapEmojiField() {
    if (bromotionEnabled) {
      if (!showEmojiKeyboard) {
        setState(() {
          showEmojiKeyboard = true;
        });
      }
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
              title: Container(
              alignment: Alignment.centerLeft,
              child: Text("Profile")
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children:
                    [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        alignment: Alignment.center,
                        child: Image.asset("assets/images/brocast.png")
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            "$broName",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25
                            ),
                          )
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 60,
                          alignment: Alignment.center,
                          child: TextFormField(
                            key: bromotionValidator,
                            validator: (value) {
                              if (value == null || value.isEmpty || value.trim().isEmpty) {
                                return '"😢?😄!"';
                              }
                              return null;
                            },
                            enabled: bromotionEnabled,
                            focusNode: focusNodeBromotion,
                            onTap: () {
                              onTapEmojiField();
                            },
                            controller: bromotionChangeController,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 40
                            ),
                            readOnly: true,
                            showCursor: true,
                          )
                      ),
                      bromotionEnabled ? TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          onSaveBromotion();
                        },
                        child: Text('Save bromotion!'),
                      ) : TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          onChangeBromotion();
                        },
                        child: Text('Change bromotion'),
                      ),
                      changePassword ? Container(
                        child: Form(
                          key: passwordFormValidator,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                controller: oldPasswordController,
                                style: simpleTextStyle(),
                                textAlign: TextAlign.center,
                                decoration: textFieldInputDecoration("Old password"),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  if (newPasswordController2.text != value) {
                                    return "Password confirmation doesn't match the password";
                                  }
                                  if (value == broPassword) {
                                    return "password is the same as old password";
                                  }
                                  return null;
                                },
                                obscureText: true,
                                controller: newPasswordController1,
                                focusNode: focusNodePassword,
                                style: simpleTextStyle(),
                                textAlign: TextAlign.center,
                                decoration: textFieldInputDecoration("New password"),
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  if (newPasswordController1.text != value) {
                                    return "Password confirmation doesn't match the password";
                                  }
                                  if (value == broPassword) {
                                    return "password is the same as old password";
                                  }
                                  return null;
                                },
                                obscureText: true,
                                controller: newPasswordController2,
                                style: simpleTextStyle(),
                                textAlign: TextAlign.center,
                                decoration: textFieldInputDecoration("Confirm new password"),
                              )
                            ],
                          ),
                        )
                      ) : Container(),
                      changePassword ? TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          onSavePassword();
                        },
                        child: Text('Update password'),
                      ) : TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          onChangePassword();
                        },
                        child: Text('Change password'),
                      ),
                      bromotionEnabled || changePassword ? SizedBox(height: 30) : SizedBox(height: 170),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: EmojiKeyboard(
                            bromotionController: bromotionChangeController,
                            emojiKeyboardHeight: 320,
                            showEmojiKeyboard: showEmojiKeyboard
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ]
          ),
        )
      );
  }
}

