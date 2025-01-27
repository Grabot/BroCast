import 'dart:convert';

import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';

class AddBroup extends StatefulWidget {
  AddBroup({required Key key}) : super(key: key);

  @override
  _AddBroupState createState() => _AddBroupState();
}

class _AddBroupState extends State<AddBroup> {
  GetBros getBros = new GetBros();
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  BroList broList = BroList();

  final broupValidator = GlobalKey<FormFieldState>();

  List<BroAddBroup> brosAddBroup = [];
  List<BroAddBroup> shownBrosAddBroup = [];
  List<BroBros> broupParticipants = [];

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController broupNameController = new TextEditingController();

  bool showEmojiKeyboard = false;
  bool pressedAddBroup = false;

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);
    socketServices.checkConnection();
    initAddBroupSockets();
    List<Chat> chats = broList.getBros();
    brosAddBroup.clear();
    shownBrosAddBroup.clear();
    broupParticipants.clear();
    for (Chat myBro in chats) {
      if (!myBro.isBroup()) {
        BroAddBroup broAddBroup = new BroAddBroup(false, myBro);
        brosAddBroup.add(broAddBroup);
      }
    }
    setState(() {
      shownBrosAddBroup = brosAddBroup;
    });
    BackButtonInterceptor.add(myInterceptor);
  }

  void initAddBroupSockets() {
    socketServices.socket.on('message_event_add_broup_success', (data) {
      broupWasAdded();
    });
    socketServices.socket.on('message_event_add_broup_failed', (data) {
      broupAddingFailed();
    });
  }

  broupWasAdded() {
    pressedAddBroup = false;
    // The broup was added with a different socket stream.
    // If that was successful we get this message
    // so we can go to the home screen to see the broup
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
  }

  broupAddingFailed() {
    pressedAddBroup = false;
    showToastMessage("Broup could not be created at this time");
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.socket.off('message_event_add_broup_success');
    socketServices.socket.off('message_event_add_broup_failed');
    bromotionController.removeListener(bromotionListener);
    bromotionController.dispose();
    broNameController.dispose();
    broupNameController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  PreferredSize appBarFindBros(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft, child: Text("Create new Broup")),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Home"))
                    ])
          ]),
    );
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
    onChangedBroNameField(broNameController.text, bromotionController.text);
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroCastHome(key: UniqueKey())));
    }
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  Widget broupParticipantsList() {
    return broupParticipants.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: broupParticipants.length,
            itemBuilder: (context, index) {
              return broupParticipantsTile(broupParticipants[index]);
            })
        : Container();
  }

  Widget listOfBros() {
    return shownBrosAddBroup.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: shownBrosAddBroup.length,
            itemBuilder: (context, index) {
              return broTileAddBroup(index);
            })
        : Container();
  }

  void selectBro(BroAddBroup broAddBroup) {
    broAddBroup.setSelected(!broAddBroup.isSelected());
    updateParticipantsBroup();
  }

  void updateParticipantsBroup() {
    broupParticipants.clear();
    for (BroAddBroup broAddBroup in brosAddBroup) {
      if (broAddBroup.isSelected()) {
        broupParticipants.add(broAddBroup.getBroBros());
      }
    }
    setState(() {});
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  void removeParticipant(Chat participant) {
    broupParticipants.remove(participant);
    for (BroAddBroup broAddBroup in brosAddBroup) {
      if (participant.id == broAddBroup.getBroBros().id) {
        broAddBroup.setSelected(false);
      }
    }
    onChangedBroNameField(broNameController.text, bromotionController.text);
  }

  Widget broupParticipantsTile(Chat participant) {
    return InkWell(
        onTap: () {
          removeParticipant(participant);
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: participant.getColor().withOpacity(0.3),
            child: Row(children: [
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          child: Text(participant.getBroNameOrAlias(),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                        participant.chatDescription != ""
                            ? Container(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Text(participant.chatDescription,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Container(
                      width: 40,
                      child: IconButton(
                        onPressed: () {
                          removeParticipant(participant);
                        },
                        icon: Icon(Icons.highlight_remove, color: Colors.white),
                      ))
                ],
              ))
            ])));
  }

  Widget broTileAddBroup(index) {
    return InkWell(
      onTap: () {
        selectBro(shownBrosAddBroup[index]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color:
            shownBrosAddBroup[index].getBroBros().getColor().withOpacity(0.6),
        child: Row(children: [
          Container(
            width: 50,
            child: Checkbox(
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: shownBrosAddBroup[index].isSelected(),
              onChanged: (bool? value) {
                selectBro(shownBrosAddBroup[index]);
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 50,
            child: Material(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 160,
                              child: shownBrosAddBroup[index].getBroBros().alias != null &&
                                      shownBrosAddBroup[index]
                                          .getBroBros()
                                          .alias
                                          .isNotEmpty
                                  ? Container(
                                      child: Text(shownBrosAddBroup[index].getBroBros().alias,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(
                                                  shownBrosAddBroup[index]
                                                      .getBroBros()
                                                      .getColor()),
                                              fontSize: 20)))
                                  : Container(
                                      child: Text(
                                          shownBrosAddBroup[index]
                                              .getBroBros()
                                              .chatName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(shownBrosAddBroup[index].getBroBros().getColor()),
                                              fontSize: 20))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              color: Colors.transparent,
            ),
          ),
        ]),
      ),
    );
  }

  void onChangedBroNameField(String typedText, String emojiField) {
    if (emojiField.isEmpty && typedText.isNotEmpty) {
      shownBrosAddBroup = brosAddBroup
          .where((element) => element
              .getBroBros()
              .getBroNameOrAlias()
              .toLowerCase()
              .contains(typedText.toLowerCase()))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      shownBrosAddBroup = brosAddBroup
          .where((element) => element
              .getBroBros()
              .getBroNameOrAlias()
              .toLowerCase()
              .contains(emojiField))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      shownBrosAddBroup = brosAddBroup
          .where((element) =>
              element
                  .getBroBros()
                  .getBroNameOrAlias()
                  .toLowerCase()
                  .contains(typedText.toLowerCase()) &&
              element
                  .getBroBros()
                  .getBroNameOrAlias()
                  .toLowerCase()
                  .contains(emojiField))
          .toList();
    } else {
      // both empty
      shownBrosAddBroup = brosAddBroup;
    }
    setState(() {});
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

  void addBroup() {
    if (!pressedAddBroup) {
      List<int> participants = [];
      for (Chat participi in broupParticipants) {
        participants.add(participi.id);
      }
      if (broupValidator.currentState!.validate()) {
        pressedAddBroup = true;
        socketServices.socket.emit("message_event_add_broup", {
          "token": settings.getToken(),
          "broup_name": broupNameController.text,
          "participants": jsonEncode(participants)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFindBros(context),
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child:
                    Text("Participants in bro group", style: simpleTextStyle()),
              ),
              Container(height: 120, child: broupParticipantsList()),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                    child: TextFormField(
                      controller: broupNameController,
                      key: broupValidator,
                      validator: (val) {
                        if (val == null ||
                            val.isEmpty ||
                            val.trimRight().isEmpty) {
                          return "Please provide a Broup name";
                        }
                        if (broupParticipants.length <= 1) {
                          return "Can't create broup with less than 2 bros";
                        }
                        return null;
                      },
                      textAlign: TextAlign.center,
                      style: simpleTextStyle(),
                      decoration:
                          textFieldInputDecoration("Type Broup name here"),
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: IconButton(
                        onPressed: () {
                          addBroup();
                        },
                        icon: Icon(Icons.check, color: Colors.white),
                      )),
                  SizedBox(width: 15),
                ]),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("Search for your bro", style: simpleTextStyle()),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        onTap: () {
                          onTapTextField();
                        },
                        onChanged: (text) {
                          onChangedBroNameField(text, bromotionController.text);
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
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(child: listOfBros()),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                    emojiController: bromotionController,
                    emojiKeyboardHeight: 300,
                    showEmojiKeyboard: showEmojiKeyboard,
                    darkMode: settings.getEmojiKeyboardDarkMode()),
              ),
            ],
          )),
    );
  }
}

class BroAddBroup {
  late bool selected;
  late Chat broBros;

  BroAddBroup(bool selected, Chat broBros) {
    this.selected = selected;
    this.broBros = broBros;
  }

  getBroBros() {
    return this.broBros;
  }

  isSelected() {
    return this.selected;
  }

  setSelected(bool selected) {
    this.selected = selected;
  }
}
