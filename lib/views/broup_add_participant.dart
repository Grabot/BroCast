import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bro_profile.dart';
import 'bro_settings.dart';
import 'broup_details.dart';

class BroupAddParticipant extends StatefulWidget {
  final Broup chat;

  BroupAddParticipant({Key key, this.chat}) : super(key: key);

  @override
  _BroupAddParticipantState createState() => _BroupAddParticipantState();
}


class _BroupAddParticipantState extends State<BroupAddParticipant> with WidgetsBindingObserver {

  bool showEmojiKeyboard = false;
  bool showNotification = true;

  List<BroupAddBro> bros = [];
  List<BroupAddBro> shownBros = [];

  Broup chat;

  BroAdded broToBeAddedToBroup;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    broToBeAddedToBroup = null;
    bromotionController.addListener(bromotionListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<Chat> broBros = BroList.instance.getBros();
      bros.clear();
      shownBros.clear();
      for (Chat myBro in broBros) {
        if (!myBro.isBroup) {
          bool inBroup = false;
          for (int participantId in chat.getParticipants()) {
            if (participantId == myBro.id) {
              inBroup = true;
            }
          }
          BroupAddBro broupAddBro = new BroupAddBro(false, inBroup, myBro);
          bros.add(broupAddBro);
        }
      }
      setState(() {
        shownBros = bros;
      });
    });
    initSockets();
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  void initSockets() {
    SocketServices.instance.socket
        .on('message_event_send_solo', (data) => messageReceivedSolo(data));
    SocketServices.instance.socket.on('message_event_add_bro_to_broup_success', (data) {
      broWasAddedToBroup(data);
    });
    SocketServices.instance.socket.on('message_event_add_bro_to_broup_failed', (data) {
      addingBroToBroupFailed();
    });
  }

  broWasAddedToBroup(var data) {
    if (mounted) {
      if (data.containsKey("result")) {
        bool result = data["result"];
        if (result) {
          var newChat = data["chat"];

          List<dynamic> broIds = newChat["bro_ids"];
          List<int> broIdList = broIds.map((s) => s as int).toList();
          chat.setParticipants(broIdList);

          chat.setChatName(newChat["broup_name"]);

          if (broToBeAddedToBroup != null) {
            chat.addBro(broToBeAddedToBroup);
            Navigator.pushReplacement(
                context, MaterialPageRoute(
                builder: (context) => BroupDetails(chat: chat)));
          } else {
            print("error while adding bro to broup! This should not happen!");
          }
        }
      }
    }
  }

  addingBroToBroupFailed() {
    broToBeAddedToBroup = null;
    if (mounted) {
      ShowToastComponent.showDialog(
          "Adding bro to the broup has failed", context);
    }
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      for (Chat br0 in BroList.instance.getBros()) {
        if (!br0.isBroup) {
          if (br0.id == data["sender_id"]) {
            if (showNotification) {
              NotificationService.instance
                  .showNotification(br0.id, br0.chatName, "", data["body"]);
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

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
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

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroupDetails(chat: chat)));
    }
  }

  Widget appBarAddBroupParticipants() {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: getTextColor(chat.chatColor)),
            onPressed: () {
              backButtonFunctionality();
            }),
        backgroundColor:
        chat.chatColor != null ? chat.chatColor : Color(0xff145C9E),
        title: Column(
            children: [
                  Container(
                  child: Text("Add participants",
                      style: TextStyle(
                          color: getTextColor(chat.chatColor), fontSize: 20)))

            ]
        ),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelectBroupAddParticipant(context, item),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text("Profile")),
                PopupMenuItem<int>(value: 1, child: Text("Settings")),
                PopupMenuItem<int>(value: 2, child: Text("Back to broup details")),
              ])
        ]);
  }

  void onSelectBroupAddParticipant(BuildContext context, int item) {
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroupDetails(chat: chat)));
        break;
    }
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

  Widget broTileAddBroup(index) {
    return InkWell(
      onTap: () {
        selectBro(shownBros[index]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: shownBros[index].getBroBros().chatColor.withOpacity(0.6),
        child: Row(
            children: [
              SizedBox(width: 15),
              Container(
                width: MediaQuery.of(context).size.width-15,
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
                                  width: MediaQuery.of(context).size.width - 63,
                                  child: shownBros[index].getBroBros().alias != null && shownBros[index].getBroBros().alias.isNotEmpty
                                      ? Container(
                                      child: Text(shownBros[index].getBroBros().alias,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(shownBros[index].getBroBros().chatColor), fontSize: 20)))
                                      : Container(
                                      child: Text(shownBros[index].getBroBros().chatName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(shownBros[index].getBroBros().chatColor), fontSize: 20))),
                                ),
                                shownBros[index].alreadyInBroup
                                    ? Container(
                                      child: Text(
                                          "Already in Broup",
                                        style: TextStyle(color: getTextColor(shownBros[index].getBroBros().chatColor).withOpacity(0.6), fontSize: 12),
                                      )
                                    )
                                    : Container()
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

  void selectBro(BroupAddBro broAddBroup) {
    if (!broAddBroup.alreadyInBroup) {
      showDialogAddParticipant(context, broAddBroup.broBros);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarAddBroupParticipants(),
      body: Container(
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
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
                    ]
                    ),
                  ),
                  broList()
                ],
                ),
              ),
            ),
          ],
          ),
        ),
      );
  }

  void showDialogAddParticipant(BuildContext context, BroBros broBros) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text(
              "Add ${broBros.getBroNameOrAlias()} to the broup?",
            style: TextStyle(color: Colors.black, fontSize: 20)),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Ok"),
              onPressed: () {
                addTheBro(broBros);
              },
            ),
          ],
        );
      },
    );
  }

  void addTheBro(BroBros broBros) {
      if (SocketServices.instance.socket.connected) {
      broToBeAddedToBroup = new BroAdded(broBros.id, broBros.chatName);
      SocketServices.instance.socket.emit("message_event_add_bro_to_broup",
          {
            'token': Settings.instance.getToken(),
            'broup_id': chat.id,
            'bro_id': broBros.id
          }
      );
    }
    Navigator.of(context).pop();
  }
}

class BroupAddBro {

  bool selected;
  bool alreadyInBroup;
  Chat broBros;

  BroupAddBro(bool selected, bool alreadyInBroup, Chat broBros) {
    this.selected = selected;
    this.alreadyInBroup = alreadyInBroup;
    this.broBros = broBros;
  }

  getBroBros() {
    return this.broBros;
  }

  isAlreadyInBroup() {
    return this.alreadyInBroup;
  }

  setAlreadyInBroup(bool alreadyInBroup) {
    this.alreadyInBroup = alreadyInBroup;
  }

  isSelected() {
    return this.selected;
  }

  setSelected(bool selected) {
    this.selected = selected;
  }
}