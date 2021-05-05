import 'package:back_button_interceptor/back_button_interceptor.dart';
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

  bool showEmojiKeyboard = false;
  bool bromotionEnabled = false;
  bool changePassword = false;

  SocketServices socket;

  String broName;
  String bromotion;
  String broPassword;

  FocusNode focusNode;
  TextEditingController bromotionChangeController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.socket == null) {
      socket = new SocketServices();
      socket.startSockConnection();
    } else {
      socket = widget.socket;
    }

    focusNode = new FocusNode();
    bromotionChangeController.addListener(bromotionListener);

    HelperFunction.getBroInformation().then((val) {
      if (val == null || val.length == 0) {
        // Something went wrong?
      } else {
        setState(() {
          broName = val[0];
          bromotion = val[1];
          bromotionChangeController.text= bromotion;
          broPassword = val[2];
        });
      }
    });
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
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => BroCastHome(socket: socket)
      ));
      return true;
    }
  }

  void onChangePassword() {
    setState(() {
      changePassword = true;
    });
  }

  void onSavePassword() {
    setState(() {
      changePassword = false;
    });
  }

  void onSaveBromotion() {
    setState(() {
      bromotionEnabled = false;
      showEmojiKeyboard = false;
    });
  }

  void onChangeBromotion() {
    focusNode.requestFocus();
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
                          child: TextField(
                            enabled: bromotionEnabled,
                            focusNode: focusNode,
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
                        child: Column(
                          children: [
                            TextField(
                              style: simpleTextStyle(),
                              textAlign: TextAlign.center,
                              decoration: textFieldInputDecoration("old password"),
                            ),
                            TextField(
                              style: simpleTextStyle(),
                              textAlign: TextAlign.center,
                              decoration: textFieldInputDecoration("new password"),
                            ),
                            TextField(
                              style: simpleTextStyle(),
                              textAlign: TextAlign.center,
                              decoration: textFieldInputDecoration("repeat new password"),
                            )
                          ],
                        ),
                      ) : Container(),
                      changePassword ? TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          onSavePassword();
                        },
                        child: Text('Save password'),
                      ) : TextButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          onChangePassword();
                        },
                        child: Text('Change password'),
                      ),
                      bromotionEnabled ? SizedBox(height: 30) : SizedBox(height: 150),
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

