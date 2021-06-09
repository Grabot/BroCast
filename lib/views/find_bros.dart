import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/search.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

import 'bro_profile.dart';
import 'bro_settings.dart';

class FindBros extends StatefulWidget {
  FindBros({Key key}) : super(key: key);

  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {
  Search search = new Search();

  bool isSearching = false;
  List<Bro> bros = [];

  bool showEmojiKeyboard = false;

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    SocketServices.instance.listenForAddingBro(this);
    bromotionController.addListener(bromotionListener);
    initSockets();
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSockets() {
    SocketServices.instance.socket.on('message_event_send_solo', (data) => messageReceivedSolo(data));
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      for (BroBros br0 in BroList.instance.getBros()) {
        if (br0.id == data["sender_id"]) {
          NotificationService.instance
              .showNotification(br0.id, br0.chatName, "", data["body"]);
        }
      }
    }
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

  broWasAdded() {
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome()));
    }
  }

  broAddingFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "Bro could not be added at this time", context);
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    SocketServices.instance.stopListeningForAddingBro();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
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

  void goToDifferentChat(BroBros chatBro) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BroMessaging(broBros: chatBro)));
  }

  searchBros() {
    if (formFieldKey.currentState.validate()) {
      setState(() {
        isSearching = true;
      });

      search
          .searchBro(broNameController.text, bromotionController.text)
          .then((val) {
        if (!(val is String)) {
          setState(() {
            bros = val;
          });
        } else {
          ShowToastComponent.showDialog(val.toString(), context);
        }
        setState(() {
          isSearching = false;
        });
      });
    }
  }

  Widget broList() {
    return bros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: bros.length,
            itemBuilder: (context, index) {
              return BroTileSearch(bros[index]);
            })
        : Container();
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome()));
    }
  }

  Widget appBarFindBros(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              backButtonFunctionality();
            }
        ),
      title: Container(alignment: Alignment.centerLeft, child: Text("Find Bros")),
      actions: [
      PopupMenuButton<int>(
          onSelected: (item) => onSelect(context, item),
          itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text("Profile")),
            PopupMenuItem<int>(value: 1, child: Text("Settings")),
            PopupMenuItem<int>(
                value: 2,
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Log Out")
                ]))
          ])
      ]
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings()));
        break;
      case 2:
        HelperFunction.logOutBro().then((value) {
          ResetRegistration resetRegistration = new ResetRegistration();
          resetRegistration.removeRegistrationId(Settings.instance.getBroId());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFindBros(context),
      body: Container(
        child: Column(
          children: [
            Text(
                "search for your bro using their bro name \n(bromotion optional)",
                style: simpleTextStyle()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      key: formFieldKey,
                      onTap: () {
                        onTapTextField();
                      },
                      validator: (val) {
                        return val.isEmpty ? "Please provide a bro name" : null;
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
                        onTapEmojiField();
                      },
                      controller: bromotionController,
                      style: simpleTextStyle(),
                      textAlign: TextAlign.center,
                      decoration: textFieldInputDecoration("😀"),
                      readOnly: true,
                      showCursor: true,
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      searchBros();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: const Color(0x36FFFFFF),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.search)),
                  )
                ],
              ),
            ),
            Expanded(child: broList()),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  bromotionController: bromotionController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: Settings.instance.getEmojiKeyboardDarkMode()),
            ),
          ],
        ),
      ),
    );
  }
}

class BroTileSearch extends StatelessWidget {
  final Bro bro;

  BroTileSearch(this.bro);

  addBro(BuildContext context) {
    SocketServices.instance.addBro(Settings.instance.getToken(), bro.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(bro.getFullBroName(), style: simpleTextStyle()),
          Spacer(),
          GestureDetector(
            onTap: () {
              addBro(context);
            },
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Add")),
          )
        ],
      ),
    );
  }
}
