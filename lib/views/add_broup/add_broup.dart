import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../services/auth/auth_service_social.dart';
import '../../utils/notification_controller.dart';
import '../../utils/socket_services.dart';
import '../../utils/storage.dart';
import '../bro_profile/bro_profile.dart';
import '../bro_settings/bro_settings.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import 'models/participant_item.dart';


class AddBroup extends StatefulWidget {
  AddBroup({required Key key}) : super(key: key);

  @override
  _AddBroupState createState() => _AddBroupState();
}

class _AddBroupState extends State<AddBroup> {
  Settings settings = Settings();
  Storage storage = Storage();
  final broupValidator = GlobalKey<FormFieldState>();

  List<ParticipantItem> participants = [];
  List<ParticipantItem> shownParticipants = [];
  List<ParticipantItem> broupParticipants = [];

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController broupNameController = new TextEditingController();

  bool showEmojiKeyboard = false;
  bool pressedAddBroup = false;

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);

    // Loop over the broups and add all the bro's in those in your id list.
    // It should only be the private chats, so the bro's you have added.
    List<Bro> currentBros = [];
    List<int> broIdsToRetrieve = [];
    Me? me = settings.getMe();
    if (me != null) {
      for (Broup broup in me.broups) {
        if (broup.private && !broup.removed) {
          participants.add(ParticipantItem(false, broup));
          for (int broId in broup.broIds) {
            if (broId != me.id) {
              if (!broIdsToRetrieve.contains(broId)) {
                broIdsToRetrieve.add(broId);
              }
            }
          }
          for (Bro bro in broup.broupBros) {
            if (me.id != bro.id) {
              currentBros.add(bro);
            }
          }
        }
      }
    }

    for (Bro bro in currentBros) {
      broIdsToRetrieve.remove(bro.id);
    }

    // TODO: Check if bro is retrieved from storage to then not retrieve from server?
    storage.fetchAllBros().then((brosDB) {
      AuthServiceSocial().retrieveBros(broIdsToRetrieve).then((value) {
        print("got bros from the server ${value}");
        if (value.isNotEmpty) {
          bool foundInDB = false;
          for (Bro bro in value) {
            for (Bro broDB in brosDB) {
              if (bro.id == broDB.id) {
                foundInDB = true;
                storage.updateBro(bro);
                break;
              }
            }
            if (!foundInDB) {
              storage.addBro(bro);
            }
          }
          setState(() {
            shownParticipants = participants;
          });
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SocketServices().startSocketConnection();
      setState(() {
        shownParticipants = participants;
      });
    });
  }

  @override
  void dispose() {
    bromotionController.removeListener(bromotionListener);
    bromotionController.dispose();
    broNameController.dispose();
    broupNameController.dispose();
    super.dispose();
  }

  PreferredSize appBarFindBros(BuildContext context) {
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
                  "Create new Broup",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
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
      navigateToHome(context, settings);
    }
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        navigateToHome(context, settings);
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
    return shownParticipants.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: shownParticipants.length,
            itemBuilder: (context, index) {
              return participantTile(index);
            })
        : Container();
  }

  void selectBro(ParticipantItem selectedParticipant) {
    selectedParticipant.setSelected(!selectedParticipant.isSelected());
    updateParticipantsBroup();
  }

  void updateParticipantsBroup() {
    // If you select it twice this is called twice but it won't be added.
    // So we clear the list and check who is selected
    broupParticipants.clear();
    for (ParticipantItem broParticipant in participants) {
      if (broParticipant.isSelected()) {
        broupParticipants.add(broParticipant);
      }
    }
    setState(() {});
  }

  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  void removeParticipant(ParticipantItem participant) {
    broupParticipants.remove(participant);
    for (ParticipantItem broParticipant in participants) {
      if (broParticipant.getBroup().broupId == participant.getBroup().broupId) {
        broParticipant.setSelected(false);
      }
    }
    setState(() {});
  }

  Widget broupParticipantsTile(ParticipantItem participant) {
    return InkWell(
        onTap: () {
          removeParticipant(participant);
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: participant.getBroup().getColor().withOpacity(0.3),
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
                          child: Text(participant.getBroup().getBroupNameOrAlias(),
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                        participant.getBroup().broupDescription != ""
                            ? Container(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Text(participant.getBroup().broupDescription,
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

  Widget participantTile(index) {
    return InkWell(
      onTap: () {
        selectBro(shownParticipants[index]);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: shownParticipants[index].getBroup().getColor().withOpacity(0.6),
        child: Row(children: [
          Container(
            width: 50,
            child: Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(getColor),
              value: shownParticipants[index].isSelected(),
              onChanged: (bool? value) {
                selectBro(shownParticipants[index]);
              },
            ),
          ),
          Container(
            child: avatarBox(
                50,
                50,
                shownParticipants[index].broup.getAvatar()
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 100,
            child: Material(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 160,
                              child: Container(
                                      child: Text(shownParticipants[index].getBroup().getBroupNameOrAlias(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: getTextColor(
                                                  shownParticipants[index]
                                                      .getBroup()
                                                      .getColor()),
                                              fontSize: 20)))
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
      shownParticipants = participants
          .where((element) => element
              .getBroup()
              .getBroupNameOrAlias()
              .toLowerCase()
              .contains(typedText.toLowerCase()))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      shownParticipants = participants
          .where((element) => element
              .getBroup()
              .getBroupNameOrAlias()
              .toLowerCase()
              .contains(emojiField))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      shownParticipants = participants
          .where((element) =>
              element
                  .getBroup()
                  .getBroupNameOrAlias()
                  .toLowerCase()
                  .contains(typedText.toLowerCase()) &&
              element
                  .getBroup()
                  .getBroNameOrAlias()
                  .toLowerCase()
                  .contains(emojiField))
          .toList();
    } else {
      // both empty
      shownParticipants = participants;
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
      if (broupValidator.currentState!.validate()) {
        pressedAddBroup = true;
        List<int> participantIds = [];
        for (ParticipantItem participant in broupParticipants) {
          for (int broId in participant.getBroup().broIds) {
            // We will be added with the request
            if (broId != settings.getMe()!.id) {
              participantIds.add(broId);
            }
          }
        }
        String broupName = broupNameController.text;
        AuthServiceSocial().addNewBroup(participantIds.toList(), broupName).then((value) {
          pressedAddBroup = false;
          if (value) {
            navigateToHome(context, settings);
          } else {
            showToastMessage("something went wrong, please try again");
          }
        });
      }
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
                !showEmojiKeyboard ? SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ) : Container(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                      emojiController: bromotionController,
                      emojiKeyboardHeight: 350,
                      showEmojiKeyboard: showEmojiKeyboard,
                      darkMode: settings.getEmojiKeyboardDarkMode()),
                ),
              ],
            )),
      ),
    );
  }
}

