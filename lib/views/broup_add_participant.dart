import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'bro_home.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';
import 'broup_details.dart';

class BroupAddParticipant extends StatefulWidget {
  final Broup chat;

  BroupAddParticipant({required Key key, required this.chat}) : super(key: key);

  @override
  _BroupAddParticipantState createState() => _BroupAddParticipantState();
}

class _BroupAddParticipantState extends State<BroupAddParticipant> {
  Settings settings = Settings();
  BroList broList = BroList();
  SocketServices socketServices = SocketServices();

  bool showEmojiKeyboard = false;

  List<BroupAddBro> broupAddBros = [];
  List<BroupAddBro> broupAddBrosShownBros = [];

  late Broup chat;

  BroAdded? broToBeAddedToBroup;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  int newBroToAdd = -1;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    bromotionController.addListener(bromotionListener);

    BroList broList = BroList();
    List<Chat> broBros = broList.getBros();
    broupAddBros.clear();
    broupAddBrosShownBros.clear();
    for (Chat myBro in broBros) {
      if (!myBro.isBroup()) {
        bool inBroup = false;
        for (int participantId in chat.getParticipants()) {
          if (participantId == myBro.id) {
            inBroup = true;
          }
        }
        BroupAddBro broupAddBro =
            new BroupAddBro(false, inBroup, myBro as BroBros);
        broupAddBros.add(broupAddBro);
      }
    }
    setState(() {
      broupAddBrosShownBros = broupAddBros;
    });

    initAddParticipantSockets();

    BackButtonInterceptor.add(myInterceptor);
  }

  socketListener() {
    for (Chat ch4t in broList.getBros()) {
      if (ch4t.isBroup()) {
        if (ch4t.id == chat.id) {
          // This is the chat object of the current chat.
          // It's possible that someone else is adding a bro while the user is on this screen.
          // We will do a quick check if the change is equal to what the user has just changed themselves.
          List<int> ch4tParticipants = (ch4t as Broup).getParticipants();
          List<int> newParticipants = new List<int>.from(ch4tParticipants);
          newParticipants
              .removeWhere((bro) => chat.getParticipants().contains(bro));
          // newParticipants should be exactly one and equal to who the user tried to add.
          if (newBroToAdd == newParticipants[0]) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BroupDetails(key: UniqueKey(), chat: ch4t)));
          }
        }
      }
    }
  }

  void initAddParticipantSockets() {
    socketServices.socket.on('message_event_add_bro_to_broup_failed', (data) {
      addingBroToBroupFailed();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.removeListener(socketListener);
    socketServices.socket.off('message_event_add_bro_to_broup_failed');
    bromotionController.dispose();
    broNameController.dispose();
    super.dispose();
  }

  addingBroToBroupFailed() {
    newBroToAdd = -1;
    broToBeAddedToBroup = null;
    ShowToastComponent.showDialog(
        "Adding bro to the broup has failed", context);
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
      broupAddBrosShownBros = broupAddBros
          .where((element) => element
              .getBroBros()
              .getBroNameOrAlias()
              .toLowerCase()
              .contains(typedText.toLowerCase()))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      broupAddBrosShownBros = broupAddBros
          .where((element) => element
              .getBroBros()
              .getBroNameOrAlias()
              .toLowerCase()
              .contains(emojiField))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      broupAddBrosShownBros = broupAddBros
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
      broupAddBrosShownBros = broupAddBros;
    }
    setState(() {});
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
              builder: (context) =>
                  BroupDetails(key: UniqueKey(), chat: chat)));
    }
  }

  PreferredSize appBarAddBroupParticipants() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor:
              chat.getColor() != null ? chat.getColor() : Color(0xff145C9E),
          title: Column(children: [
            Container(
                child: Text("Add participants",
                    style: TextStyle(
                        color: getTextColor(chat.getColor()), fontSize: 20)))
          ]),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) =>
                    onSelectBroupAddParticipant(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(
                          value: 2, child: Text("Back to broup details")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelectBroupAddParticipant(BuildContext context, int item) {
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
                builder: (context) =>
                    BroupDetails(key: UniqueKey(), chat: chat)));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  Widget listOfBros() {
    return broupAddBrosShownBros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: broupAddBrosShownBros.length,
            itemBuilder: (context, index) {
              return broTileAddBroup(index);
            })
        : Container();
  }

  Widget broTileAddBroup(index) {
    return InkWell(
      onTap: () {
        selectBro(broupAddBrosShownBros[index]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: broupAddBrosShownBros[index]
            .getBroBros()
            .getColor()
            .withOpacity(0.6),
        child: Row(children: [
          SizedBox(width: 15),
          Container(
            width: MediaQuery.of(context).size.width - 15,
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
                              child: broupAddBrosShownBros[index].getBroBros().alias != null &&
                                      broupAddBrosShownBros[index]
                                          .getBroBros()
                                          .alias
                                          .isNotEmpty
                                  ? Container(
                                      child: Text(broupAddBrosShownBros[index].getBroBros().alias,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(
                                                  broupAddBrosShownBros[index]
                                                      .getBroBros()
                                                      .getColor()),
                                              fontSize: 20)))
                                  : Container(
                                      child: Text(
                                          broupAddBrosShownBros[index]
                                              .getBroBros()
                                              .chatName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(broupAddBrosShownBros[index].getBroBros().getColor()),
                                              fontSize: 20))),
                            ),
                            broupAddBrosShownBros[index].alreadyInBroup
                                ? Container(
                                    child: Text(
                                    "Already in Broup",
                                    style: TextStyle(
                                        color: getTextColor(
                                                broupAddBrosShownBros[index]
                                                    .getBroBros()
                                                    .getColor())
                                            .withOpacity(0.6),
                                        fontSize: 12),
                                  ))
                                : Container()
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
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Search for your bro", style: simpleTextStyle()),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Row(children: [
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
              ]),
            ),
            Container(
              child: Expanded(child: listOfBros()),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  bromotionController: bromotionController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode()),
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
          content: new Text("Add ${broBros.getBroNameOrAlias()} to the broup?",
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
    broToBeAddedToBroup = new BroAdded(broBros.id, chat.id, broBros.chatName);
    newBroToAdd = broBros.id;
    socketServices.socket.emit("message_event_add_bro_to_broup", {
      'token': settings.getToken(),
      'broup_id': chat.id,
      'bro_id': broBros.id
    });
    Navigator.of(context).pop();
  }
}

class BroupAddBro {
  late bool selected;
  late bool alreadyInBroup;
  late BroBros broBros;

  BroupAddBro(bool selected, bool alreadyInBroup, BroBros broBros) {
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
