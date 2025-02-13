import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/services/delete_broup.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/report_bro.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/broup_add_participant.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

import '../../../services/auth/auth_service_settings.dart';
import '../../../utils/new/storage.dart';
import '../../bro_home/bro_home.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';
import '../broup_messaging/broup_messaging.dart';
import 'models/bro_tile_details.dart';

class ChatDetails extends StatefulWidget {
  final Broup chat;

  ChatDetails({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;

  late int amountInGroup;

  late CircleColorPickerController circleColorPickerController;

  late Color currentColor;
  Color? previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  late Broup chat;

  late Storage storage;

  bool meAdmin = false;

  double iconSize = 30;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    storage = Storage();
    amountInGroup = chat.getBroIds().length;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    BackButtonInterceptor.add(myInterceptor);

    chatDescriptionController.text = chat.broupDescription;
    chatAliasController.text = chat.alias;

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.getColor(),
    );
    currentColor = chat.getColor();
  }

  checkMeAdmin() {
    // meAdmin = false;
    meAdmin = true;
    // for (int adminId in chat.getAdmins()) {
    //   if (adminId == settings.getBroId()) {
    //     // We are admin
    //     setState(() {
    //       meAdmin = true;
    //     });
    //   }
    // }
  }

  socketListener() {
    setState(() {

    });
  }

  addNewBro(int addBroId) {
    // socketServices.socket
    //     .on('message_event_add_bro_success', (data) => broWasAdded(data));
    // socketServices.socket.on('message_event_add_bro_failed', (data) {
    //   broAddingFailed();
    // });
    // socketServices.socket.emit("message_event_add_bro",
    //     {"token": settings.getToken(), "bros_bro_id": addBroId});
  }

  broWasAdded(data) {
    // BroBros broBros = new BroBros(
    //     data["bros_bro_id"],
    //     data["chat_name"],
    //     data["chat_description"],
    //     data["alias"],
    //     data["chat_colour"],
    //     data["unread_messages"],
    //     data["last_time_activity"],
    //     data["room_name"],
    //     data["blocked"] ? 1 : 0,
    //     data["mute"] ? 1 : 0,
    //     0);
    // broList.addChat(broBros);
    // storage.addChat(broBros).then((value) {
    //   broList.updateBroupBrosForBroBros(broBros);
    //   Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => BroCastHome(key: UniqueKey())));
    // });
  }

  broAddingFailed() {
    showToastMessage("Bro could not be added at this time");
  }

  broupWasMuted(var data) {
    // if (data.containsKey("result")) {
    //   bool result = data["result"];
    //   if (result) {
    //     setState(() {
    //       chat.setMuted(data["mute"]);
    //     });
    //   }
    // }
  }

  broupMutingFailed() {
    showToastMessage("Broup muting failed at this time.");
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  void backButtonFunctionality() {
    if (changeDescription) {
      setState(() {
        chatDescriptionController.text = previousDescription;
        changeDescription = false;
        FocusScope.of(context).unfocus();
      });
    } else if (changeAlias) {
      setState(() {
        chatAliasController.text = previousAlias;
        changeAlias = false;
        FocusScope.of(context).unfocus();
      });
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BroupMessaging(key: UniqueKey(), chat: chat)));
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.removeListener(socketListener);
    chatDescriptionController.dispose();
    chatAliasController.dispose();
    focusNodeDescription.dispose();
    focusNodeAlias.dispose();
    super.dispose();
  }

  PreferredSize appBarChatDetails() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor: chat.getColor(),
          title: Text(chat.getBroupNameOrAlias(),
              style: TextStyle(
                  color: getTextColor(chat.getColor()), fontSize: 20)),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelectChat(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(
                          value: 2, child: Text("Back to broup")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BroupMessaging(key: UniqueKey(), chat: chat)));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  void onTapDescriptionField() {
    previousDescription = chatDescriptionController.text;
    focusNodeDescription.requestFocus();
    setState(() {
      changeDescription = true;
    });
  }

  void onTapAliasField() {
    previousAlias = chatAliasController.text;
    focusNodeAlias.requestFocus();
    setState(() {
      changeAlias = true;
    });
  }

  updateDescription() {
    if (previousDescription != chatDescriptionController.text) {
      String newBroupDescription = chatDescriptionController.text;
      print("changing the description to $newBroupDescription");
      AuthServiceSettings().changeDescriptionBroup(chat.getBroupId(), newBroupDescription).then((val) {
        if (val) {
          // The details are updated via sockets.
          setState(() {});
        } else {
          showToastMessage("something went wrong with changing the description");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
    setState(() {
      FocusScope.of(context).unfocus();
      changeDescription = false;
    });
  }

  updateAlias() {
    if (previousAlias != chatAliasController.text) {
      String newBroupAlias = chatAliasController.text;
      print("changing the alias to $newBroupAlias");
      AuthServiceSettings().changeAliasBroup(chat.getBroupId(), newBroupAlias).then((val) {
        if (val) {
          // Since this is only visible for the bro
          // we don't get an update via sockets
          // So we update it once we have received a response from the server
          chat.alias = newBroupAlias;
          storage.updateBroup(chat);
          setState(() {});
        } else {
          showToastMessage("something went wrong with changing the alias");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
    setState(() {
      FocusScope.of(context).unfocus();
      changeAlias = false;
    });
  }

  updateColour() {
    previousColor = currentColor;
    setState(() {
      changeColour = true;
    });
  }

  saveColour() {
    // if (currentColor != chat.getColor()) {
    //   String newColour = currentColor.value.toRadixString(16).substring(2, 8);
    //   socketServices.socket.emit("message_event_change_broup_colour", {
    //     "token": "settings.getToken()",
    //     "broup_id": chat.id,
    //     "colour": newColour
    //   });
    // }
    // setState(() {
    //   changeColour = false;
    // });
  }

  void broupAliasUpdateFailed() {
    chatAliasController.text = previousAlias;
    showToastMessage("Updating the bro alias has failed");
  }

  void broupDetailUpdateFailed() {
    currentColor = previousColor!;
    circleColorPickerController.color = previousColor!;
    showToastMessage("Updating the bro chat has failed");
  }

  void broupAddAdminFailed() {
    showToastMessage("Adding the bro as admin has failed");
  }

  void broupDismissAdminSuccess(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        // for (Bro bro in chat.getBroupBros()) {
        //   if (bro.id == data["old_admin"]) {
        //     bro.setAdmin(false);
        //     chat.dismissAdmin(data["old_admin"]);
        //     // if (settings.getBroId() == data["old_admin"]) {
        //     //   meAdmin = false;
        //     // }
        //     break;
        //   }
        // }
        setState(() {});
      } else {
        broupAddAdminFailed();
      }
    } else {
      broupAddAdminFailed();
    }
  }

  void broupDismissAdminFailed() {
    showToastMessage("Dismissing the bro from his admin role has failed");
  }

  void broupRemoveBroFailed() {
    showToastMessage("Removing the bro from the broup has failed");
  }

  void broupColourUpdateFailed() {
    chatDescriptionController.text = previousDescription;
    showToastMessage("Updating the bro colour has failed");
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  Widget participantsList() {
    return Container(
        alignment: Alignment.center,
        child: brosInBroupList()
    );
  }

  Widget brosInBroupList() {
    return chat.getBroupBros().isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: chat.getBroupBros().length,
            itemBuilder: (context, index) {
              return BroTileDetails(
                  key: UniqueKey(),
                  bro: chat.getBroupBros()[index],
                  broupId: chat.broupId,
                  userAdmin: true,  // TODO: fix?
                  addNewBro: addNewBro
              );
            })
        : Container();
  }

  addParticipant() {
    // Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             BroupAddParticipant(key: UniqueKey(), chat: chat)));
  }

  Widget broCastLogo() {
    return Container(
        alignment: Alignment.center,
        child:
        Image.asset("assets/images/brocast_transparent.png"));
  }

  Widget broupNameHeader() {
    if (chat.alias.isNotEmpty) {
      return Column(children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${chat.alias}",
              style: TextStyle(
                  color: Colors.white, fontSize: 25),
            )),
        SizedBox(height: 10),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${chat.broupName}",
              style: TextStyle(
                  color: Colors.white, fontSize: 16),
            ))
      ]);
    } else {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            "${chat.broupName}",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ));
    }
  }

  Widget broHasLeft() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            "You're no longer a participant in this Broup",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          )),
        Container(
          child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(
                    Colors.red),
              ),
              onPressed: () {
                showDialogDelete(
                    context, chat.getBroupNameOrAlias());
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 20),
                    Text(
                      'Delete Broup',
                      style: simpleTextStyle(),
                    ),
                  ])),
        )
    ]
    );
  }

  Widget chatAliasWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: TextFormField(
            focusNode: focusNodeAlias,
            onTap: () {
              onTapAliasField();
            },
            controller: chatAliasController,
            style: simpleTextStyle(),
            textAlign: TextAlign.center,
            decoration: textFieldInputDecoration(
                "No chat alias yet"),
          ),
        ),
        SizedBox(width: 5),
        changeAlias
            ? Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateAlias();
              }),
        )
            : Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.edit,
                  color: Colors.white),
              onPressed: () {
                onTapAliasField();
              }),
        ),
      ],
    );
  }

  Widget chatColourWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: InkWell(
            onTap: () {
              updateColour();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Color:",
                  style: simpleTextStyle(),
                ),
                SizedBox(width: 20),
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: chat.getColor(),
                      borderRadius:
                      BorderRadius.circular(40)),
                ),
              ],
            ),
          ),
        ),
        changeColour ? Column(
            children: [
              CircleColorPicker(
                controller: circleColorPickerController,
                textStyle: simpleTextStyle(),
                onChanged: (colour) {
                  setState(() => onColorChange(colour));
                },
              ),
              IconButton(
                  iconSize: iconSize,
                  icon: Icon(Icons.check,
                      color: Colors.green),
                  onPressed: () {
                    saveColour();
                  }),
            ]) : Container(),
      ]
    );
  }

  Widget broupDescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // 20 padding on both sides, 5 sizedbox and 18 for button
          width:
          MediaQuery.of(context).size.width - 100,
          child: TextFormField(
            focusNode: focusNodeDescription,
            maxLines: null,
            onTap: () {
              onTapDescriptionField();
            },
            controller: chatDescriptionController,
            style: simpleTextStyle(),
            textAlign: TextAlign.center,
            decoration: textFieldInputDecoration(
                "No chat description yet"),
          ),
        ),
        SizedBox(width: 5),
        changeDescription
            ? Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateDescription();
              }),
        )
            : Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.edit,
                  color: Colors.white),
              onPressed: () {
                onTapDescriptionField();
              }),
        ),
      ],
    );
  }

  Widget chatDetailsParticipants() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          child: Text(
              "" +
                  amountInGroup.toString() +
                  " Participants",
              style: simpleTextStyle()),
        ),
        SizedBox(height: 10),
        meAdmin ? InkWell(
          onTap: () {
            addParticipant();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 24, vertical: 6),
            child: Row(children: [
              Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                          Radius.circular(40))),
                  child: IconButton(
                    onPressed: () {
                      addParticipant();
                    },
                    icon: Icon(Icons.person_add,
                        color: Colors.white),
                  )),
              SizedBox(width: 20),
              Text(
                "Add participants",
                style: TextStyle(
                    color: Colors.grey, fontSize: 20),
              ),
            ]),
          ),
        ) : Container(),
        Container(
            alignment: Alignment.center,
            child: brosInBroupList()),
      ],
    );
  }

  Widget muteChatWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          chat.isMuted()
              ? showDialogUnMuteBroup(context)
              : showDialogMuteBroup(context);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  chat.isMuted()
                      ? Icons.volume_up
                      : Icons.volume_mute,
                  color: chat.isMuted()
                      ? Colors.grey
                      : Colors.red),
              SizedBox(width: 20),
              chat.isMuted()
                  ? Text(
                'Unmute Broup',
                style: simpleTextStyle(),
              )
                  : Text(
                'Mute Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget leaveBroupWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          showDialogExitBroup(context, chat.broupName);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.exit_to_app,
                  color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Leave Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget chatDetailWidget() {
    return Container(
      child: Column(
          children: [
            chatAliasWidget(),
            SizedBox(height: 20),
            chatColourWidget(),
            SizedBox(height: 20),
            broupDescriptionWidget(),
            SizedBox(height: 50),
            chatDetailsParticipants(),
            SizedBox(height: 10),
            muteChatWidget(),
            SizedBox(height: 10),
            leaveBroupWidget(),
            SizedBox(height: 10),
      ]),
    );
  }

  Widget reportBroupWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () {
          showDialogReport(context, chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thumb_down, color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Report Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarChatDetails(),
        body: Container(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  broCastLogo(),
                  broupNameHeader(),
                  SizedBox(height: 20),
                  chat.hasLeft()
                      ? broHasLeft()
                      : chatDetailWidget(),
                  reportBroupWidget(),
                  SizedBox(height: 20),
                ]),
              ),
            ),
          ]),
        ));
  }

  void exitBroup() {
    // socketServices.socket.emit("message_event_change_broup_remove_bro", {
    //   "token": settings.getToken(),
    //   "broup_id": chat.id,
    //   "bro_id": settings.getBroId()
    // });
    Navigator.of(context).pop();
  }

  void showDialogExitBroup(BuildContext context, String broupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Leave Broup $broupName!"),
          content: new Text("Are you sure you want to leave this broup?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Leave Broup"),
              onPressed: () {
                exitBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogReport(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Report broup $chatName!"),
          content: new Text(
              "Are you sure you want to report this broup? The most recent messages from this broup will be forwarded to Zwaar developers to assess possible deletion of the broup. This broup and the messages will be removed from your bro list and the former broup can't send you messages anymore. This former broup will not be notified of the report."),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Report"),
              onPressed: () {
                reportTheBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogDelete(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete broup $chatName!"),
          content: new Text("Are you sure you want to delete this broup?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Delete"),
              onPressed: () {
                deleteTheBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTheBroup() {
    // deleteBroup.deleteBroup(settings.getToken(), chat.id).then((val) {
    //   if (val is Broup) {
    //     Broup deletedBroup = val;
    //     broList.deleteChat(deletedBroup);
    //     storage.deleteChat(deletedBroup).then((value) {
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => BroCastHome(key: UniqueKey())));
    //     });
    //   } else {
    //     if (val == "an unknown error has occurred") {
    //       showToastMessage("An unknown error has occurred");
    //     } else {
    //       showToastMessage("There was an error with the server, we apologize for the inconvenience.");
    //     }
    //   }
    // });
    Navigator.of(context).pop();
  }

  void reportTheBroup() {
    // reportBro.reportBroup(settings.getToken(), chat.id).then((val) {
    //   if (val is Broup) {
    //     Broup broupToRemove = val;
    //     broList.deleteChat(broupToRemove);
    //     storage.deleteChat(broupToRemove).then((value) {
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => BroCastHome(key: UniqueKey())));
    //     });
    //   } else {
    //     if (val == "an unknown error has occurred") {
    //       showToastMessage("An unknown error has occurred");
    //     } else {
    //       showToastMessage("There was an error with the server, we apologize for the inconvenience.");
    //     }
    //   }
    // });
    Navigator.of(context).pop();
  }

  void showDialogUnMuteBroup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Unmute notifications?"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Unmute"),
                onPressed: () {
                  unmuteTheBroup();
                },
              ),
            ],
          );
        });
  }

  void showDialogMuteBroup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Mute notifications for..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(4, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedRadio = index);
                      },
                      child: Row(children: [
                        Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => selectedRadio = value);
                              }
                            }),
                        index == 0
                            ? Container(child: Text("1 hour"))
                            : Container(),
                        index == 1
                            ? Container(child: Text("8 hours"))
                            : Container(),
                        index == 2
                            ? Container(child: Text("1 week"))
                            : Container(),
                        index == 3
                            ? Container(child: Text("Indefinitely"))
                            : Container(),
                      ]),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Mute"),
                onPressed: () {
                  muteTheBroup(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  void unmuteTheBroup() {
    // socketServices.socket.emit("message_event_change_broup_mute", {
    //   "token": settings.getToken(),
    //   "broup_id": chat.id,
    //   "bro_id": settings.getBroId(),
    //   "mute": -1
    // });
    Navigator.of(context).pop();
  }

  void muteTheBroup(int selectedRadio) {
    // socketServices.socket.emit("message_event_change_broup_mute", {
    //   "token": settings.getToken(),
    //   "broup_id": chat.id,
    //   "bro_id": settings.getBroId(),
    //   "mute": selectedRadio
    // });
    Navigator.of(context).pop();
  }
}

// class BroTile extends StatefulWidget {
//   final Bro bro;
//   final String broName;
//   final int broupId;
//   final bool userAdmin;
//   final void Function(int) addNewBro;
//
//   BroTile(
//       {required Key key,
//       required this.bro,
//       required this.broName,
//       required this.broupId,
//       required this.userAdmin,
//       required this.addNewBro})
//       : super(key: key);
//
//   @override
//   _BroTileState createState() => _BroTileState();
// }
//
// class _BroTileState extends State<BroTile> {
//   Settings settings = Settings();
//
//   var _tapPosition;
//
//   selectBro(BuildContext context) {
//     // if (widget.bro.id != settings.getBroId()) {
//     //   showDialog(
//     //       context: context,
//     //       builder: (BuildContext context) {
//     //         return AlertDialog(actions: <Widget>[
//     //           widget.userAdmin
//     //               ? getPopupItemsAdmin(
//     //                   context,
//     //                   widget.broName,
//     //                   widget.bro,
//     //                   widget.broupId,
//     //                   true,
//     //                   settings.getToken(),
//     //                   widget.addNewBro)
//     //               : getPopupItemsNormal(
//     //                   context,
//     //                   widget.broName,
//     //                   widget.bro,
//     //                   widget.broupId,
//     //                   true,
//     //                   settings.getToken(),
//     //                   widget.addNewBro)
//     //         ]);
//     //       });
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Material(
//         child: GestureDetector(
//           onLongPress: _showBroupPopupMenu,
//           onTapDown: _storePosition,
//           child: InkWell(
//             onTap: () {
//               selectBro(context);
//             },
//             child: Row(children: [
//               Container(
//                 width: widget.bro.isAdmin()
//                     ? MediaQuery.of(context).size.width - 124
//                     : MediaQuery.of(context).size.width,
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 child: Text(widget.broName, style: simpleTextStyle()),
//               ),
//               widget.bro.isAdmin()
//                   ? Container(
//                       width: 100,
//                       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//                       decoration: BoxDecoration(
//                           border: Border.all(color: Colors.green)),
//                       child: Text(
//                         "admin",
//                         style: TextStyle(color: Colors.green, fontSize: 16),
//                         textAlign: TextAlign.center,
//                       ))
//                   : Container(),
//             ]),
//           ),
//         ),
//         color: Colors.transparent,
//       ),
//     );
//   }
//
//   void _showBroupPopupMenu() {
//     // if (widget.bro.id != settings.getBroId()) {
//     //   final RenderBox overlay =
//     //       Overlay.of(context)!.context.findRenderObject() as RenderBox;
//     //
//     //   showMenu(
//     //           context: context,
//     //           items: [
//     //             BroupParticipantPopup(
//     //                 key: UniqueKey(),
//     //                 broName: widget.broName,
//     //                 bro: widget.bro,
//     //                 broupId: widget.broupId,
//     //                 userAdmin: widget.userAdmin,
//     //                 addNewBro: widget.addNewBro)
//     //           ],
//     //           position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
//     //               Offset.zero & overlay.size))
//     //       .then((int? delta) {
//     //     return;
//     //   });
//     // }
//   }
//
//   void _storePosition(TapDownDetails details) {
//     _tapPosition = details.globalPosition;
//   }
// }
//
// class BroupParticipantPopup extends PopupMenuEntry<int> {
//   final String broName;
//   final Bro bro;
//   final int broupId;
//   final bool userAdmin;
//   final void Function(int) addNewBro;
//
//   BroupParticipantPopup(
//       {required Key key,
//       required this.broName,
//       required this.bro,
//       required this.broupId,
//       required this.userAdmin,
//       required this.addNewBro})
//       : super(key: key);
//
//   @override
//   bool represents(int? n) => n == 1 || n == -1;
//
//   @override
//   BroupParticipantPopupState createState() => BroupParticipantPopupState();
//
//   @override
//   double get height => 1;
// }
//
// class BroupParticipantPopupState extends State<BroupParticipantPopup> {
//   Settings settings = Settings();
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.userAdmin
//         ? getPopupItemsAdmin(context, widget.broName, widget.bro,
//             widget.broupId, false, "settings.getToken()", widget.addNewBro)
//         : getPopupItemsNormal(context, widget.broName, widget.bro,
//             widget.broupId, false,"settings.getToken()", widget.addNewBro);
//   }
// }
//
// void buttonMessage(BuildContext context, Bro bro, bool alertDialog) {
//   if (alertDialog) {
//     Navigator.of(context).pop();
//   } else {
//     Navigator.pop<int>(context, 1);
//   }
//   BroList broList = BroList();
//   for (Chat br0 in broList.getBros()) {
//     if (!br0.isBroup()) {
//       if (br0.id == bro.id) {
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     BroMessaging(key: UniqueKey(), chat: br0 as BroBros)));
//       }
//     }
//   }
// }
//
// void buttonAddBro(
//     BuildContext context, Bro bro, bool alertDialog, String token, addNewBro) {
//   addNewBro(bro.id);
//   if (alertDialog) {
//     Navigator.of(context).pop();
//   } else {
//     Navigator.pop<int>(context, 1);
//   }
// }
//
// void buttonMakeAdmin(BuildContext context, Bro bro, int broupId,
//     bool alertDialog, String token) {
//   if (alertDialog) {
//     Navigator.of(context).pop();
//   } else {
//     Navigator.pop<int>(context, 2);
//   }
//   SocketServices socketServices = SocketServices();
//   socketServices.socket.emit("message_event_change_broup_add_admin",
//       {"token": token, "broup_id": broupId, "bro_id": bro.id});
// }
//
// void buttonDismissAdmin(BuildContext context, Bro bro, int broupId,
//     bool alertDialog, String token) {
//   if (alertDialog) {
//     Navigator.of(context).pop();
//   } else {
//     Navigator.pop<int>(context, 3);
//   }
//   SocketServices socketServices = SocketServices();
//   socketServices.socket.emit("message_event_change_broup_dismiss_admin",
//       {"token": token, "broup_id": broupId, "bro_id": bro.id});
// }
//
// void buttonRemove(BuildContext context, Bro bro, int broupId, bool alertDialog,
//     String token) {
//   if (alertDialog) {
//     Navigator.of(context).pop();
//   } else {
//     Navigator.pop<int>(context, 3);
//   }
//   SocketServices socketServices = SocketServices();
//   socketServices.socket.emit("message_event_change_broup_remove_bro",
//       {"token": token, "broup_id": broupId, "bro_id": bro.id});
// }
//
// Widget getPopupItemsAdmin(BuildContext context, String broName, Bro bro,
//     int broupId, bool alertDialog, String token, addNewBro) {
//   return Column(
//     children: [
//       bro is BroAdded
//           ? Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonMessage(context, bro, alertDialog);
//                   },
//                   child: Text(
//                     'Message $broName',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             )
//           : Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonAddBro(context, bro, alertDialog, token, addNewBro);
//                   },
//                   child: Text(
//                     'Add $broName',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             ),
//       bro.isAdmin()
//           ? Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonDismissAdmin(
//                         context, bro, broupId, alertDialog, token);
//                   },
//                   child: Text(
//                     'Dismiss as admin',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             )
//           : Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonMakeAdmin(context, bro, broupId, alertDialog, token);
//                   },
//                   child: Text(
//                     'Make Broup admin',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             ),
//       Container(
//         alignment: Alignment.centerLeft,
//         child: TextButton(
//             onPressed: () {
//               buttonRemove(context, bro, broupId, alertDialog, token);
//             },
//             child: Text(
//               'Remove $broName',
//               style: TextStyle(color: Colors.black, fontSize: 14),
//             )),
//       )
//     ],
//   );
// }
//
// Widget getPopupItemsNormal(BuildContext context, String broName, Bro bro,
//     int broupId, bool alertDialog, String token, addNewBro) {
//   return Column(
//     children: [
//       bro is BroAdded
//           ? Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonMessage(context, bro, alertDialog);
//                   },
//                   child: Text(
//                     'Message $broName',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             )
//           : Container(
//               alignment: Alignment.centerLeft,
//               child: TextButton(
//                   onPressed: () {
//                     buttonAddBro(context, bro, alertDialog, token, addNewBro);
//                   },
//                   child: Text(
//                     'Add $broName',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(color: Colors.black, fontSize: 14),
//                   )),
//             ),
//     ],
//   );
// }
