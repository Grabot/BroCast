import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/user.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import "package:flutter/material.dart";
import 'bro_settings.dart';


class BroProfile extends StatefulWidget {
  BroProfile(
      {
        required Key key
      }) : super(key: key);

  @override
  _BroProfileState createState() => _BroProfileState();
}

class _BroProfileState extends State<BroProfile> with WidgetsBindingObserver {
  final passwordFormValidator = GlobalKey<FormState>();
  final bromotionValidator = GlobalKey<FormFieldState>();

  Settings settings = Settings();
  SocketServices socket = SocketServices();

  bool showEmojiKeyboard = false;
  bool bromotionEnabled = false;
  bool changePassword = false;
  bool showNotification = true;

  String broPassword = "";

  FocusNode focusNodeBromotion = new FocusNode();
  FocusNode focusNodePassword = new FocusNode();
  TextEditingController bromotionChangeController = new TextEditingController();
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController1 = new TextEditingController();
  TextEditingController newPasswordController2 = new TextEditingController();

  late Storage storage;

  late User currentUser;

  @override
  void initState() {
    super.initState();
    bromotionChangeController.addListener(bromotionListener);
    // initSockets(); // TODO: @SKools move to singelton?

    storage = Storage();

    currentUser = new User(-1, "", "", "", "", "", 0, 0);
    storage.selectUser().then((user) {
      if (user != null) {
        currentUser = user;
        bromotionChangeController.text = user.bromotion;
        oldPasswordController.text = user.password;
        setState(() {});
      }
    });

    WidgetsBinding.instance!.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSockets() {
    // TODO: @Skools move to singleton?
    // SocketServices.instance.socket.on('message_event_bromotion_change', (data) {
    //   if (data == "bromotion change successful") {
    //     onChangeBromotionSuccess();
    //   } else if (data == "broName bromotion combination taken") {
    //     onChangeBromotionFailedExists();
    //   } else {
    //     onChangeBromotionFailedUnknown();
    //   }
    // });
    // SocketServices.instance.socket.on('message_event_password_change', (data) {
    //   if (data == "password change successful") {
    //     onChangePasswordSuccess();
    //   } else {
    //     onChangePasswordFailed();
    //   }
    // });
  }

  bromotionListener() {
    bromotionChangeController.selection =
        TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionChangeController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText =
          bromotionChangeController.text.replaceFirst(lastEmoji, "");
      bromotionChangeController.text = newText;
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  void onChangePasswordSuccess() {
    if (mounted) {
      ShowToastComponent.showDialog("password changed successfully", context);
      broPassword = newPasswordController2.text;
      currentUser.password = broPassword;
      storage.updateUser(currentUser).then((value) {
        print("we have updated the user!");
        print(value);
        oldPasswordController.text = broPassword;
        newPasswordController1.text = "";
        newPasswordController2.text = "";
      });
    }
  }

  void onChangePasswordFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "changing password failed due to an unknown error.", context);
      setState(() {
        newPasswordController1.text = "";
        newPasswordController2.text = "";
      });
    }
  }

  void onChangeBromotionSuccess() {
    if (mounted) {
      ShowToastComponent.showDialog("bromotion changed successfully", context);
      currentUser.bromotion = bromotionChangeController.text;
      settings.setBromotion(currentUser.bromotion);
      storage.updateUser(currentUser).then((value) {
        print("we have updated the user!");
        print(value);
      });
    }
  }

  void onChangeBromotionFailedExists() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "BroName bromotion combination exists, please pick a different bromotion",
          context);
      setState(() {
        bromotionChangeController.text = currentUser.bromotion;
      });
    }
  }

  void onChangeBromotionFailedUnknown() {
    if (mounted) {
      ShowToastComponent.showDialog("an unknown Error has occurred", context);
      setState(() {
        bromotionChangeController.text = currentUser.bromotion;
      });
    }
  }

  void onChangePassword() {
    if (mounted) {
      focusNodePassword.requestFocus();
      setState(() {
        changePassword = true;
      });
    }
  }

  void onSavePassword() {
    if (mounted) {
      if (passwordFormValidator.currentState!.validate()) {
        // TODO: @Skools move to singleton?
        // if (SocketServices.instance.socket.connected) {
        //   SocketServices.instance.socket.emit("password_change", {
        //     "token": settings.getToken(),
        //     "password": newPasswordController1.text
        //   });
        // }
        setState(() {
          changePassword = false;
        });
      }
    }
  }

  void onSaveBromotion() {
    if (mounted) {
      if (bromotionValidator.currentState!.validate()) {
        // TODO: @Skools move to singleton?
        // if (SocketServices.instance.socket.connected) {
        //   SocketServices.instance.socket.emit("bromotion_change", {
        //     "token": settings.getToken(),
        //     "bromotion": bromotionChangeController.text
        //   });
        // }
        setState(() {
          bromotionEnabled = false;
          showEmojiKeyboard = false;
        });
      }
    }
  }

  void onChangeBromotion() {
    if (mounted) {
      focusNodeBromotion.requestFocus();
      setState(() {
        bromotionEnabled = true;
        showEmojiKeyboard = true;
      });
    }
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

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      // TODO: @Skools move to singleton?
      // SocketServices.instance.socket
      //     .off('message_event_bromotion_change', (data) => print(data));
      // SocketServices.instance.socket
      //     .off('message_event_password_change', (data) => print(data));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome(
        key: UniqueKey()
      )));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  PreferredSize appBarProfile(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title:
              Container(alignment: Alignment.centerLeft, child: Text("Profile")),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Settings")),
                      PopupMenuItem<int>(
                          value: 1,
                          child: Row(children: [
                            Icon(Icons.logout, color: Colors.black),
                            SizedBox(width: 8),
                            Text("Log Out")
                          ]))
                    ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings(
          key: UniqueKey()
        )));
        break;
      case 1:
        ResetRegistration resetRegistration = new ResetRegistration();
        resetRegistration.removeRegistrationId(settings.getBroId());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarProfile(context),
        body: Container(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(children: [
                  Container(
                      alignment: Alignment.center,
                      child:
                          Image.asset("assets/images/brocast_transparent.png")),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        "${currentUser.broName}",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      )),
                  SizedBox(height: 20),
                  Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: TextFormField(
                        key: bromotionValidator,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().isEmpty) {
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
                        style: TextStyle(color: Colors.white, fontSize: 40),
                        readOnly: true,
                        showCursor: true,
                      )),
                  bromotionEnabled
                      ? TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () {
                            onSaveBromotion();
                          },
                          child: Text('Save bromotion!'),
                        )
                      : TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            onChangeBromotion();
                          },
                          child: Text('Change bromotion'),
                        ),
                  changePassword
                      ? Container(
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
                                decoration:
                                    textFieldInputDecoration("Old password"),
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
                                decoration:
                                    textFieldInputDecoration("New password"),
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
                                decoration: textFieldInputDecoration(
                                    "Confirm new password"),
                              )
                            ],
                          ),
                        ))
                      : Container(),
                  changePassword
                      ? TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () {
                            onSavePassword();
                          },
                          child: Text('Update password'),
                        )
                      : TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            onChangePassword();
                          },
                          child: Text('Change password'),
                        ),
                  bromotionEnabled || changePassword
                      ? SizedBox(height: 30)
                      : SizedBox(height: 170),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: EmojiKeyboard(
                        bromotionController: bromotionChangeController,
                        emojiKeyboardHeight: 300,
                        showEmojiKeyboard: showEmojiKeyboard,
                        darkMode: settings.getEmojiKeyboardDarkMode()),
                  ),
                ]),
              ),
            ),
          ]),
        ));
  }
}
