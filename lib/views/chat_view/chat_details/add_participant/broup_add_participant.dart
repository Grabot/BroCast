import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/chat_messaging.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../objects/bro.dart';
import '../../../../objects/broup.dart';
import '../../../../objects/me.dart';
import '../../../../utils/notification_controller.dart';
import '../../../../utils/storage.dart';
import '../../../bro_home/bro_home.dart';
import '../../../bro_profile/bro_profile.dart';
import '../../../bro_settings/bro_settings.dart';
import '../chat_details.dart';
import 'models/broup_add_bro.dart';

class BroupAddParticipant extends StatefulWidget {
  final Broup chat;

  BroupAddParticipant({required Key key, required this.chat}) : super(key: key);

  @override
  _BroupAddParticipantState createState() => _BroupAddParticipantState();
}

class _BroupAddParticipantState extends State<BroupAddParticipant> {
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  bool showEmojiKeyboard = false;

  List<BroupAddBro> broupAddBros = [];
  List<BroupAddBro> broupAddBrosShownBros = [];

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    socketServices.addListener(socketListener);
    bromotionController.addListener(bromotionListener);

    notificationController = NotificationController();
    notificationController.addListener(notificationListener);

    broupAddBros.clear();
    broupAddBrosShownBros.clear();
    Me? me = Settings().getMe();
    if (me != null) {
      for (Broup myBro in me!.broups) {
        if (myBro.private && !myBro.removed) {
          bool inBroup = false;
          for (int participantId in myBro.getBroIds()) {
            // In a private chat there are 2 ids, me and the other bro
            if (participantId != me.getId()) {
              // Check if the ID of `myBro` is in the `chat.getBroIds()`
              for (int chatParticipantId in widget.chat.getBroIds()) {
                if (participantId == chatParticipantId) {
                  inBroup = true;
                  break;
                }
              }
            }
          }
          print("bro ${myBro.getBroupName()} In broup: $inBroup");
          BroupAddBro broupAddBro =
          new BroupAddBro(false, inBroup, myBro);
          broupAddBros.add(broupAddBro);
        }
      }
    }
    broupAddBrosShownBros = broupAddBros;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
      });
    });
  }

  socketListener() {
  }

  notificationListener() {
    if (notificationController.navigateChat) {
      notificationController.navigateChat = false;
      int chatId = notificationController.navigateChatId;
      Storage().fetchBroup(chatId).then((broup) {
        if (broup != null) {
          notificationController.navigateChat = false;
          notificationController.navigateChatId = -1;
          navigateToChat(context, settings, broup);
        }
      });
    }
  }

  @override
  void dispose() {
    socketServices.removeListener(socketListener);
    bromotionController.removeListener(bromotionListener);
    bromotionController.dispose();
    notificationController.removeListener(notificationListener);
    broNameController.dispose();
    super.dispose();
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

  navigateToDetails() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChatDetails(
                key: UniqueKey(),
                chat: widget.chat)));
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      navigateToDetails();
    }
  }

  PreferredSize appBarAddBroupParticipants() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: getTextColor(widget.chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor:
          widget.chat.getColor() != null ? widget.chat.getColor() : Color(0xff145C9E),
          title: Column(children: [
            Container(
                child: Text("Add participants",
                    style: TextStyle(
                        color: getTextColor(widget.chat.getColor()), fontSize: 20)))
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
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        navigateToDetails();
        break;
      case 3:
        navigateToHome(context, settings);
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
                                              .getBroupName(),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
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
              !showEmojiKeyboard ? SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ) : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                    emojiController: bromotionController,
                    emojiKeyboardHeight: 400,
                    showEmojiKeyboard: showEmojiKeyboard,
                    darkMode: settings.getEmojiKeyboardDarkMode()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogAddParticipant(BuildContext context, Broup broBroup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Add ${broBroup.getBroupNameOrAlias()} to the broup?",
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
                addTheBro(broBroup);
              },
            ),
          ],
        );
      },
    );
  }

  void addTheBro(Broup broBroup) {
    // Pop to close the popup
    Navigator.of(context).pop();

    int newBroId = -1;
    Me? me = settings.getMe();
    if (me != null) {
      for (int broId in broBroup.getBroIds()) {
        if (me.getId() != broId) {
          newBroId = broId;
          break;
        }
      }
    }
    if (newBroId != -1) {
      AuthServiceSocial().addBroToBroup(widget.chat.broupId, newBroId).then((value) {
        print("adding to broup: $value");
        if (value) {
          List<int> broIdsToRetrieve = [...widget.chat.getBroIds()];
          for (Bro bro in widget.chat.getBroupBros()) {
            broIdsToRetrieve.remove(bro.id);
          }
          for (Broup broup in me!.broups) {
            if (broup.private) {
              for (Bro bro in broup.getBroupBros()) {
                if (bro.id == newBroId) {
                  widget.chat.addBro(bro);
                  broIdsToRetrieve.remove(newBroId);
                  if (broIdsToRetrieve.isEmpty) {
                    widget.chat.retrievedBros = true;
                    break;
                  }
                }
              }
            }
          }
          // broIdsToRetrieve should be length 1 with newBroId,
          // but we check anyway. If there are more still, we retrieve them
          if (broIdsToRetrieve.isNotEmpty) {
            AuthServiceSocial().retrieveBros(broIdsToRetrieve).then((value) {
              if (value.isNotEmpty) {
                for (Bro bro in value) {
                  widget.chat.addBro(bro);
                  Storage().addBro(bro);
                }
              }
            });
          }
          navigateToDetails();
        }
      });
    }
  }
}
