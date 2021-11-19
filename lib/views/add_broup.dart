import 'dart:convert';

import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'bro_profile.dart';
import 'bro_settings.dart';

class AddBroup extends StatefulWidget {
  AddBroup({Key key}) : super(key: key);

  @override
  _AddBroupState createState() => _AddBroupState();
}

class _AddBroupState extends State<AddBroup> with WidgetsBindingObserver {

  GetBros getBros = new GetBros();

  final broupValidator = GlobalKey<FormFieldState>();

  bool showNotification = true;

  List<BroAddBroup> bros = [];
  List<BroAddBroup> shownBros = [];
  List<BroBros> broupParticipants = [];

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  TextEditingController broupNameController = new TextEditingController();

  bool showEmojiKeyboard = false;

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);
    initSockets();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<Chat> broBros = BroList.instance.getBros();
      if (broBros.isEmpty) {
        searchBros(Settings.instance.getToken());
      } else {
        bros.clear();
        shownBros.clear();
        broupParticipants.clear();
        for (Chat myBro in broBros) {
          if (!myBro.isBroup()) {
            BroAddBroup broAddBroup = new BroAddBroup(false, myBro);
            bros.add(broAddBroup);
          }
        }
        setState(() {
          shownBros = bros;
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSockets() {
    SocketServices.instance.socket
        .on('message_event_send_solo', (data) => messageReceivedSolo(data));
    SocketServices.instance.socket.on('message_event_add_broup_success', (data) {
      broupWasAdded();
    });
    SocketServices.instance.socket.on('message_event_add_broup_failed', (data) {
      broupAddingFailed();
    });
  }

  broupWasAdded() {
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome()));
    }
  }

  broupAddingFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "Broup could not be created at this time", context);
    }
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      if (data.containsKey("broup_id")) {
        for (Chat broup in BroList.instance.getBros()) {
          if (broup.isBroup()) {
            if (broup.id == data["broup_id"]) {
              if (showNotification && !broup.isMuted()) {
                NotificationService.instance
                    .showNotification(broup.id, broup.chatName, broup.alias, broup.getBroNameOrAlias(), data["body"], true);
              }
            }
          }
        }
      } else {
        for (Chat br0 in BroList.instance.getBros()) {
          if (!br0.isBroup()) {
            if (br0.id == data["sender_id"]) {
              if (showNotification && !br0.isMuted()) {
                NotificationService.instance
                    .showNotification(br0.id, br0.chatName, br0.alias, br0.getBroNameOrAlias(), data["body"], false);
              }
            }
          }
        }
      }
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

  searchBros(String token) {
    getBros.getBros(token).then((val) {
      if (!(val is String)) {
        setState(() {
          bros = val;
          shownBros = val;
          BroList.instance.setBros(bros);
        });
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  Widget appBarFindBros(BuildContext context) {
    return AppBar(
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
                    PopupMenuItem<int>(
                        value: 2,
                        child: Row(children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 8),
                          Text("Log Out")
                        ]))
                  ])
        ]);
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
          context, MaterialPageRoute(builder: (context) => BroCastHome()));
    }
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

  Widget broList() {
    return shownBros.isNotEmpty
        ? ListView.builder(
        shrinkWrap: true,
        itemCount: shownBros.length,
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
    for (BroAddBroup broAddBroup in bros) {
      if (broAddBroup.isSelected()) {
        broupParticipants.add(broAddBroup.getBroBros());
      }
    }
    setState(() {

    });
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
    for (BroAddBroup broAddBroup in bros) {
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
        child: Row(
          children:
          [
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20)),
                        ),
                        participant.chatDescription != ""
                            ? Container(
                          width:
                          MediaQuery.of(context).size.width - 40,
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
                      icon: Icon(
                          Icons.highlight_remove,
                          color: Colors.white
                      ),
                    )
                  )
                ],
              )
            )
          ]
        )
      )
    );
  }

  Widget broTileAddBroup(index) {
    return InkWell(
      onTap: () {
        selectBro(shownBros[index]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: shownBros[index].getBroBros().getColor().withOpacity(0.6),
        child: Row(
            children: [
              Container(
                width: 50,
                child: Checkbox(
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(getColor),
                  value: shownBros[index].isSelected(),
                  onChanged: (bool value) {
                    selectBro(shownBros[index]);
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width-50,
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
                                  child: shownBros[index].getBroBros().alias != null && shownBros[index].getBroBros().alias.isNotEmpty
                                      ? Container(
                                      child: Text(shownBros[index].getBroBros().alias,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(shownBros[index].getBroBros().getColor()), fontSize: 20)))
                                      : Container(
                                      child: Text(shownBros[index].getBroBros().chatName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(shownBros[index].getBroBros().getColor()), fontSize: 20))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  color: Colors.transparent,
                ),
              ),
            ]
        ),
      ),
    );
  }

  void onChangedBroNameField(String typedText, String emojiField) {
    if (emojiField.isEmpty && typedText.isNotEmpty) {
      shownBros = bros.where((element) =>
          element.getBroBros().getBroNameOrAlias().toLowerCase()
              .contains(typedText.toLowerCase())).toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      shownBros = bros.where((element) =>
          element.getBroBros().getBroNameOrAlias().toLowerCase()
              .contains(emojiField)).toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      shownBros = bros.where((element) =>
          element.getBroBros().getBroNameOrAlias().toLowerCase()
              .contains(typedText.toLowerCase()) &&
              element.getBroBros().getBroNameOrAlias().toLowerCase()
                  .contains(emojiField)).toList();
    } else {
      // both empty
      shownBros = bros;
    }
    setState(() {
    });
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
    List<int> participants = [];
    for (Chat partici in broupParticipants) {
      participants.add(partici.id);
    }
    if (broupValidator.currentState.validate()) {
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket.emit("message_event_add_broup",
            {
              "token": Settings.instance.getToken(),
              "broup_name": broupNameController.text,
              "participants": jsonEncode(participants)
            }
        );
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
                child: Text(
                  "Participants in bro group",
                  style: simpleTextStyle()
                ),
              ),
              Container(
                height: 120,
                child: broupParticipantsList()
              ),
              SizedBox(
                height: 10
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children:
                  [
                    Container(
                      width: MediaQuery.of(context).size.width-100,
                      child: TextFormField(
                        controller: broupNameController,
                        key: broupValidator,
                        validator: (val) {
                          if (val.isEmpty || val.trimRight().isEmpty) {
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
                            borderRadius: BorderRadius.all(Radius.circular(40))
                        ),
                        child: IconButton(
                          onPressed: () {
                            addBroup();
                          },
                          icon: Icon(
                              Icons.check,
                              color: Colors.white
                          ),
                        )
                    ),
                    SizedBox(width: 15),
                  ]
                ),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Search for your bro",
                    style: simpleTextStyle()
                ),
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
              SizedBox(
                  height: 10
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
          )
      ),
    );
  }
}

class BroAddBroup {

  bool selected;
  Chat broBros;

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