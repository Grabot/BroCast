import 'package:brocast/services/auth/auth_service_settings.dart';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import "package:flutter/material.dart";
import '../../objects/me.dart';
import '../../utils/notification_controller.dart';
import '../change_avatar/change_avatar.dart';


class BroProfile extends StatefulWidget {
  BroProfile({required Key key}) : super(key: key);

  @override
  _BroProfileState createState() => _BroProfileState();
}

class _BroProfileState extends State<BroProfile> {
  final passwordFormValidator = GlobalKey<FormState>();
  final bromotionValidator = GlobalKey<FormFieldState>();
  final bronameValidator = GlobalKey<FormFieldState>();

  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  bool showEmojiKeyboard = false;
  bool bromotionEnabled = false;
  bool broNameEnabled = false;
  bool changePassword = false;

  FocusNode focusNodeBroname = new FocusNode();
  FocusNode focusNodeBromotion = new FocusNode();
  FocusNode focusNodePassword = new FocusNode();

  TextEditingController bromotionChangeController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController1 = new TextEditingController();
  TextEditingController newPasswordController2 = new TextEditingController();

  late Storage storage;

  ScrollController scrollController = ScrollController();

  bool passwordToChange = false;
  @override
  void initState() {
    super.initState();

    storage = Storage();
    Me? me = settings.getMe();
    bromotionChangeController.addListener(bromotionListener);
    if (me != null) {
      bromotionChangeController.text = me.getBromotion();
    }
    SecureStorage().getOrigin().then((value) {
      if (value != null) {
        // If origin is true it was a regular login which means it can change the password
        // If it's false it means that the login was via Google, Apple, Github or Reddit and there is no password
        setState(() {
          passwordToChange = value;
        });
      }
    });
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

  void onChangePassword() {
    focusNodePassword.requestFocus();
    Future.delayed(Duration(milliseconds: 800)).then((value) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
    setState(() {
      showEmojiKeyboard = false;
      changePassword = true;
      broNameEnabled = false;
      bromotionEnabled = false;
    });
  }

  void onSavePassword() {
    if (passwordFormValidator.currentState!.validate()) {
      AuthServiceSettings().changePassword(
          oldPasswordController.text, newPasswordController1.text).then((value) {
        if (value == "Password changed") {
          SecureStorage().setPassword(newPasswordController1.text);
          showToastMessage("Password changed successfully");
        } else {
          showToastMessage(value);
        }
        oldPasswordController.text = "";
        newPasswordController1.text = "";
        newPasswordController2.text = "";
        setState(() {
          changePassword = false;
        });
      }).catchError((error) {
        showToastMessage("an unknown Error has occurred");
      });
    }
  }

  onCancelPassword() {
    setState(() {
      oldPasswordController.text = "";
      newPasswordController1.text = "";
      newPasswordController2.text = "";
      changePassword = false;
    });
  }

  changeBroname() {
    String newBroname = broNameController.text;
    AuthServiceSettings().changeBroname(newBroname).then((value) {
      if (value) {
        showToastMessage("bro name changed successfully");
        broNameController.text = "";
        setState(() {});
      }
    });
    setState(() {
      bromotionEnabled = false;
      showEmojiKeyboard = false;
      broNameEnabled = false;
    });
  }

  showDialogChangeBroname(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Are you sure!?"),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You want to change your bro name from\n",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextSpan(
                    text: "${Settings().getMe()!.getBroName()}\n",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                    ),
                  ),
                  TextSpan(
                    text: "to",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextSpan(
                    text: "\n${broNameController.text}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                    ),
                  ),
                  TextSpan(
                    text: "\nChanging your bro name might cause confusion for your bros. Make sure they know about your name change!",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    bromotionEnabled = false;
                    showEmojiKeyboard = false;
                    broNameEnabled = false;
                  });
                },
              ),
              new TextButton(
                child: new Text("Change Bro name"),
                onPressed: () {
                  Navigator.of(context).pop();
                  changeBroname();
                },
              ),
            ],
          );
        });
  }

  onSaveBroname(BuildContext context) {
    if (bronameValidator.currentState!.validate()) {
      showDialogChangeBroname(context);
    }
  }

  onCancelBroname() {
    setState(() {
      broNameController.text = "";
      broNameEnabled = false;
    });
  }

  onSaveBromotion() {
    if (bromotionValidator.currentState!.validate()) {
      String newBromotion = bromotionChangeController.text;
      AuthServiceSettings().changeBromotion(newBromotion).then((value) {
        if (value == "Bromotion changed") {
          showToastMessage("bromotion changed successfully");
          SecureStorage().setBromotion(newBromotion);
          setState(() {
            settings.getMe()!.setBromotion(newBromotion);
          });
        } else {
          showToastMessage(value);
          setState(() {
            bromotionChangeController.text = settings.getMe()!.bromotion;
          });
        }
      }).catchError((error) {
        showToastMessage("an unknown Error has occurred");
        setState(() {
          bromotionChangeController.text = settings.getMe()!.bromotion;
        });
      });
      setState(() {
        bromotionEnabled = false;
        showEmojiKeyboard = false;
        broNameEnabled = false;
      });
    }
  }

  void onChangeBromotion() {
    focusNodeBromotion.requestFocus();
    setState(() {
      bromotionEnabled = true;
      showEmojiKeyboard = true;
      changePassword = false;
      broNameEnabled = false;
    });
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  onChangeBroname() {
    focusNodeBroname.requestFocus();
    Future.delayed(Duration(milliseconds: 800)).then((value) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent-80,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
    setState(() {
      showEmojiKeyboard = false;
      broNameEnabled = true;
      changePassword = false;
      bromotionEnabled = false;
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
    bromotionChangeController.removeListener(bromotionListener);
    bromotionChangeController.dispose();
    oldPasswordController.dispose();
    newPasswordController1.dispose();
    newPasswordController2.dispose();
    focusNodeBromotion.dispose();
    focusNodeBroname.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  void backButtonFunctionality() {
    broNameEnabled = false;
    changePassword = false;
    bromotionEnabled = false;
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      navigateToHome(context, settings);
    }
  }

  PreferredSize appBarProfile(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Profile",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Settings")),
                      PopupMenuItem<int>(value: 1, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToSettings(context, settings);
        break;
      case 1:
        navigateToHome(context, settings);
        break;
    }
  }

  Widget showBromotionWithOverflow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            alignment: Alignment.center,
            child: Text(
              Settings().getMe()!.bromotion,
              style: TextStyle(color: Colors.white, fontSize: 35),
            )
        ),
      ],
    );
  }

  bool hasTextOverflow(
      String text,
      TextStyle style,
      double textScaleFactor,
      double minWidth,
      double maxWidth,
      int maxLines,
      ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  Widget broAvatarBox() {
    double totalWidth = MediaQuery.of(context).size.width;
    return Container(
      width: totalWidth-200,
      height: totalWidth-200,
      child: avatarBox(totalWidth-200, totalWidth-200, settings.getMe()!.avatar),
    );
  }

  Widget currentUserDetails() {
    String nameString = "${settings.getMe()!.broName} ${settings.getMe()!.bromotion}";
    TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 35);
    bool broNameOverflow = false;
    if (hasTextOverflow(nameString, textStyle, 1.0, 60, MediaQuery.of(context).size.width, 2)) {
      broNameOverflow = true;
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                constraints: BoxConstraints(minWidth: 60, maxWidth: MediaQuery.of(context).size.width),
                alignment: Alignment.center,
                child: Text(
                  nameString,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontSize: 35),
                )
            ),
          ],
        ),
        broNameOverflow ? showBromotionWithOverflow() : Container(),
        broAvatarBox(),
      ]
    );
  }

  Widget avatarWidget() {
    return Column(
      children: [
        Container(
          child: TextButton(
            style: ButtonStyle(
              foregroundColor:
              WidgetStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeAvatar(
                        key: UniqueKey(),
                        isMe: true,
                        avatar: settings.getMe()!.avatar!,
                        isDefault: settings.getMe()!.avatarDefault,
                      )));
            },
            child: Text('Change avatar'),
          ),
        ),
      ],
    );
  }

  Widget passwordWidget() {
    if (!passwordToChange) {
      return Container();
    } else {
      if (changePassword) {
        return Column(
          children: [
            Container(
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
                )
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () {
                onSavePassword();
              },
              child: Text('Update password!'),
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(Colors.red),
              ),
              onPressed: () {
                onCancelPassword();
              },
              child: Text('Cancel password update'),
            )
          ],
        );
      } else {
        return TextButton(
          style: ButtonStyle(
            foregroundColor:
            WidgetStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            onChangePassword();
          },
          child: Text('Change password'),
        );
      }
    }
  }

  Widget bromotionWidget() {
    if (bromotionEnabled) {
      return Column(
        children: [
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
              )
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor:
              WidgetStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () {
              onSaveBromotion();
            },
            child: Text('Save new bromotion!'),
          ),
        ]
      );
    } else {
      return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () {
          onChangeBromotion();
        },
        child: Text('Change bromotion'),
      );
    }
  }

  Widget broNameWidget() {
    if (broNameEnabled) {
      return Column(
        children: [
          Column(
            children: [
              TextFormField(
                key: bronameValidator,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: broNameController,
                focusNode: focusNodeBroname,
                style: simpleTextStyle(),
                textAlign: TextAlign.center,
                decoration:
                textFieldInputDecoration("New bro name"),
              ),
            ],
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor:
              WidgetStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () {
              onSaveBroname(context);
            },
            child: Text('Save new bro name!'),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor:
              WidgetStateProperty.all<Color>(Colors.red),
            ),
            onPressed: () {
              onCancelBroname();
            },
            child: Text('Cancel bro name change!'),
          )
        ]
      );
    } else {
      return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.blue),
        ),
        onPressed: () {
          onChangeBroname();
        },
        child: Text('Change bro name'),
      );
    }
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
          appBar: appBarProfile(context),
          body: Stack(
            children: [
              Container(
              child: Column(
                  children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                        children: [
                      Container(
                          alignment: Alignment.center,
                          child:
                              Image.asset("assets/images/brocast_transparent.png")),
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Heey",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                      ),
                          SizedBox(height: 20),
                          currentUserDetails(),
                          SizedBox(height: 20),
                          broNameWidget(),
                          bromotionWidget(),
                          avatarWidget(),
                          passwordWidget(),
                          showEmojiKeyboard ? SizedBox(height: 400) : SizedBox(height: 100),
                        ]
                    ),
                  ),
                ),
              ]
              ),
            ),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                    emojiController: bromotionChangeController,
                    emojiKeyboardHeight: 350,
                    showEmojiKeyboard: showEmojiKeyboard,
                    darkMode: settings.getEmojiKeyboardDarkMode()),
              )
            ]
          )
      ),
    );
  }
}
