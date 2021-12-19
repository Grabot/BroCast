import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/delete_broup.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/report_bro.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broup_add_participant.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'bro_home.dart';
import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';
import 'broup_messaging.dart';


class BroupDetails extends StatefulWidget {
  final Broup chat;

  BroupDetails(
      {
        required Key key,
        required this.chat
      }) : super(key: key);

  @override
  _BroupDetailsState createState() => _BroupDetailsState();
}

class _BroupDetailsState extends State<BroupDetails> {

  Settings settings = Settings();
  GetChat getChat = new GetChat();
  SocketServices socketServices = SocketServices();
  BroList broList = BroList();

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

  ReportBro reportBro = new ReportBro();
  DeleteBroup deleteBroup = new DeleteBroup();

  bool meAdmin = false;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    storage = Storage();
    amountInGroup = chat.getBroupBros().length;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    BackButtonInterceptor.add(myInterceptor);

    // Retrieve again from db to ensure up to date data.
    storage.selectChat(chat.id.toString(), chat.broup.toString()).then((value) {
      chat = value as Broup;
      storage.fetchAllBrosOfBroup(chat.id.toString()).then((broupBros) {
        broList.updateAliases(broupBros);
        chat.setBroupBros(broupBros);
        checkMeAdmin();
      });
    });

    // We retrieved the chat locally, but we will also get it from the server
    // If anything has changed, we can update it locally
    getChat.getBroup(settings.getBroId(), chat.id).then((value) {
      if (value is Broup) {
        List<Bro> broupBros = [];
        if (value.participants.length != chat.participants.length) {
          // someone was added(removed( and you didn't get updated, add them now
          broList.chatChangedCheckForAdded(chat.id, value.getParticipants(), value.getAdmins(), [], broupBros);
          broList.chatCheckForDBRemoved(chat.id, value.getParticipants());
        } else {
          broupBros = chat.getBroupBros();
          broList.updateBroupBrosAdmins(broupBros, value.getAdmins());
        }
        chat = value;
        chat.setBroupBros(broupBros);
        chat.unreadMessages = 0;
        broList.updateChat(chat);
        storage.updateChat(chat).then((value) {
        });
        setState(() {});
      }
    });

    chatDescriptionController.text = chat.chatDescription;
    chatAliasController.text = chat.alias;

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.getColor(),
    );
    currentColor = chat.getColor();
    initBroupDetailsSockets();
  }

  checkMeAdmin() {
    meAdmin = false;
    for (int adminId in chat.getAdmins()) {
      if (adminId == settings.getBroId()) {
        // We are admin
        setState(() {
          meAdmin = true;
        });
      }
    }
  }

  void initBroupDetailsSockets() {
    socketServices.socket
        .on('message_event_change_broup_details_failed', (data) {
      broupDetailUpdateFailed();
    });
    socketServices.socket
        .on('message_event_change_broup_alias_failed', (data) {
      broupAliasUpdateFailed();
    });
    socketServices.socket
        .on('message_event_change_broup_colour_failed', (data) {
      broupColourUpdateFailed();
    });
    socketServices.socket
        .on('message_event_change_broup_add_admin_failed', (data) {
      broupAddAdminFailed();
    });
    socketServices.socket
        .on('message_event_change_broup_dismiss_admin_success', (data) {
      broupDismissAdminSuccess(data);
    });
    socketServices.socket
        .on('message_event_change_broup_dismiss_admin_failed', (data) {
      broupDismissAdminFailed();
    });
    socketServices.socket
        .on('message_event_change_broup_remove_bro_failed', (data) {
      broupRemoveBroFailed();
    });
    socketServices.socket.on('message_event_add_bro_failed', (data) {
      broAddingFailed();
    });
    socketServices.socket.on('message_event_change_broup_mute_failed', (data) {
      broupMutingFailed();
    });
  }

  socketListener() {
    print("something happened with the broup details sockets stuff");
    // There was some update to the bro list.
    // Check the list and see if the change was to this chat object.
    for(Chat ch4t in broList.getBros()) {
      if (ch4t.isBroup()) {
        if (ch4t.id == chat.id) {
          // This is the chat object of the current chat.
          // We update the screen for any changes.
          // We know if it gets here that it is a Broup object and that
          // it is the same Broup object as the current open chat
          chat = ch4t as Broup;
          if (!focusNodeDescription.hasFocus) {
            print("description does NOT have focus");
            chatDescriptionController.text = ch4t.chatDescription;
          } else {
            print("description has focus");
            previousDescription = ch4t.chatDescription;
          }
          currentColor = ch4t.getColor();
          circleColorPickerController.color = ch4t.getColor();
          chatAliasController.text = ch4t.alias;
          setState(() {
            checkMeAdmin();
          });
        }
      }
    }
  }

  addNewBro(int addBroId) {
    socketServices.socket.on('message_event_add_bro_success', (data) =>
        broWasAdded(data));
    socketServices.socket.on('message_event_add_bro_failed', (data) {
      broAddingFailed();
    });
    socketServices.socket.emit("message_event_add_bro",
        {"token": settings.getToken(), "bros_bro_id": addBroId}
    );
  }

  broWasAdded(data) {
    print("a bro was added! Probably by you");
    BroBros broBros = new BroBros(
        data["bros_bro_id"],
        data["chat_name"],
        data["chat_description"],
        data["alias"],
        data["chat_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        data["blocked"] ? 1 : 0,
        data["mute"] ? 1 : 0,
        0
    );
    broList.addChat(broBros);
    storage.addChat(broBros).then((value) {
      print("Going to update all the broup for this new bro");
      broList.updateBroupBrosForBroBros(broBros);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) =>
          BroCastHome(
              key: UniqueKey()
          )));
    });
  }

  broAddingFailed() {
    ShowToastComponent.showDialog(
        "Bro could not be added at this time", context);
  }

  broupWasMuted(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        setState(() {
          chat.setMuted(data["mute"]);
        });
      }
    }
  }

  broupMutingFailed() {
    ShowToastComponent.showDialog(
        "Broup muting failed at this time.", context);
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => BroupMessaging(
              key: UniqueKey(),
              chat: chat
          )));
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.removeListener(socketListener);
    socketServices.socket.off('message_event_change_broup_details_failed');
    socketServices.socket.off('message_event_change_broup_alias_failed');
    socketServices.socket.off('message_event_change_broup_colour_failed');
    socketServices.socket.off('message_event_change_broup_add_admin_failed');
    socketServices.socket.off('message_event_change_broup_dismiss_admin_success');
    socketServices.socket.off('message_event_change_broup_dismiss_admin_failed');
    socketServices.socket.off('message_event_change_broup_remove_bro_failed');
    socketServices.socket.off('message_event_add_bro_success');
    socketServices.socket.off('message_event_add_bro_failed');
    socketServices.socket.off('message_event_change_broup_mute_failed');
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
              icon: Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor: chat.getColor(),
          title: Text(chat.getBroNameOrAlias(),
              style: TextStyle(
                  color: getTextColor(chat.getColor()), fontSize: 20)),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelectChat(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Back to broup")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile(
          key: UniqueKey()
        )));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings(
          key: UniqueKey()
        )));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroupMessaging(
                    key: UniqueKey(),
                    chat: chat
                )));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) =>
            BroCastHome(
                key: UniqueKey()
            )));
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

  void updateDescription() {
    if (previousDescription != chatDescriptionController.text) {
        socketServices.socket
            .emit("message_event_change_broup_details", {
          "token": settings.getToken(),
          "broup_id": chat.id,
          "description": chatDescriptionController.text
        });
      setState(() {
        FocusScope.of(context).unfocus();
        changeDescription = false;
      });
    } else {
      setState(() {
        FocusScope.of(context).unfocus();
        changeDescription = false;
      });
    }
  }

  void updateAlias() {
    if (previousAlias != chatAliasController.text) {
      socketServices.socket
          .emit("message_event_change_broup_alias", {
        "token": settings.getToken(),
        "broup_id": chat.id,
        "alias": chatAliasController.text
      });
      setState(() {
        FocusScope.of(context).unfocus();
        changeAlias = false;
      });
    } else {
      setState(() {
        FocusScope.of(context).unfocus();
        changeAlias = false;
      });
    }
  }

  updateColour() {
    previousColor = currentColor;
    setState(() {
      changeColour = true;
    });
  }

  saveColour() {
    if (currentColor != chat.getColor()) {
      String newColour = currentColor.value.toRadixString(16).substring(2, 8);
      socketServices.socket
          .emit("message_event_change_broup_colour", {
        "token": settings.getToken(),
        "broup_id": chat.id,
        "colour": newColour
      });
    }
    setState(() {
      changeColour = false;
    });
  }

  void broupAliasUpdateFailed() {
    chatAliasController.text = previousAlias;
    ShowToastComponent.showDialog(
        "Updating the bro alias has failed", context);
  }

  void broupDetailUpdateFailed() {
    currentColor = previousColor!;
    circleColorPickerController.color = previousColor!;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void broupAddAdminFailed() {
    ShowToastComponent.showDialog(
        "Adding the bro as admin has failed", context);
  }

  void broupDismissAdminSuccess(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        for (Bro bro in chat.getBroupBros()) {
          if (bro.id == data["old_admin"]) {
            bro.setAdmin(false);
            chat.dismissAdmin(data["old_admin"]);
            if (settings.getBroId() == data["old_admin"]) {
              meAdmin = false;
            }
            break;
          }
        }
        setState(() {});
      } else {
        broupAddAdminFailed();
      }
    } else {
      broupAddAdminFailed();
    }
  }

  void broupDismissAdminFailed() {
    ShowToastComponent.showDialog(
        "Dismissing the bro from his admin role has failed", context);
  }

  void broupRemoveBroFailed() {
    ShowToastComponent.showDialog(
        "Removing the bro from the broup has failed", context);
  }

  void broupColourUpdateFailed() {
    chatDescriptionController.text = previousDescription;
    ShowToastComponent.showDialog(
        "Updating the bro colour has failed", context);
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  Widget brosInBroupList() {
    return chat.getBroupBros().isNotEmpty
        ? ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: chat.getBroupBros().length,
        itemBuilder: (context, index) {
          return getBroupBro(index);
        })
        : Container();
  }

  getBroupBro(int index) {
    Bro bro = chat.getBroupBros()[index];
    String broName = bro.getFullName();
    for (Chat br0 in broList.getBros()) {
      if (!br0.isBroup()) {
        if (bro.id == br0.id) {
          // If he has added the bro and given it an alias, we take it over.
          broName = br0.getBroNameOrAlias();
        }
      }
    }
    return BroTile(
        key: UniqueKey(),
        bro: bro,
        broName: broName,
        broupId: chat.id,
        userAdmin: meAdmin,
        addNewBro: addNewBro
    );
  }

  addParticipant() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(
            builder: (context) => BroupAddParticipant(
              key: UniqueKey(),
              chat: chat
            )));
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
                  Container(
                      alignment: Alignment.center,
                      child:
                          Image.asset("assets/images/brocast_transparent.png")),
                  chat.alias != null && chat.alias.isNotEmpty
                      ? Column(
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.center,
                            child: Text(
                              "${chat.alias}",
                              style: TextStyle(color: Colors.white, fontSize: 25),
                            )),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            alignment: Alignment.center,
                            child: Text(
                              "${chat.chatName}",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ))
                      ]
                  )
                  : Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      child: Text(
                        "${chat.chatName}",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      )),
              SizedBox(height: 20),
              chat.hasLeft() ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: Text(
                    "You're no longer a participant in this Broup",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ))
              : Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(
                            // 20 padding on both sides, 5 sizedbox and 18 for button
                            width: MediaQuery.of(context).size.width-45,
                            child: TextFormField(
                              focusNode: focusNodeAlias,
                              onTap: () {
                                onTapAliasField();
                              },
                              controller: chatAliasController,
                              style: simpleTextStyle(),
                              textAlign: TextAlign.center,
                              decoration: textFieldInputDecoration("No broup alias yet"),
                            ),
                          ),
                          SizedBox(width: 5),
                          changeAlias
                          ? Container(
                            width: 20,
                            child: IconButton(
                                iconSize: 20.0,
                                icon: Icon(Icons.check, color: Colors.white),
                                onPressed: () {
                                  updateAlias();
                                }
                            ),
                          )
                          : Container(
                            width: 20,
                            child: IconButton(
                                iconSize: 20.0,
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () {
                                  onTapAliasField();
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
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
                                    borderRadius: BorderRadius.circular(40)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      changeColour
                      ? Column(
                        children:[
                          CircleColorPicker(
                            controller: circleColorPickerController,
                            textStyle: simpleTextStyle(),
                            onChanged: (colour) {
                              setState(() => onColorChange(colour));
                            },
                          ),
                          IconButton(
                              iconSize: 30.0,
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                saveColour();
                              }
                          ),
                        ]
                      )
                      : Container(),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Container(
                              // 20 padding on both sides, 5 sizedbox and 18 for button
                              width: MediaQuery.of(context).size.width-45,
                              child: TextFormField(
                                focusNode: focusNodeDescription,
                                maxLines: null,
                                onTap: () {
                                  onTapDescriptionField();
                                },
                                controller: chatDescriptionController,
                                style: simpleTextStyle(),
                                textAlign: TextAlign.center,
                                decoration:
                                textFieldInputDecoration("No broup description yet"),
                              ),
                            ),
                            SizedBox(width: 5),
                            changeDescription
                              ? Container(
                                width: 20,
                                child: IconButton(
                                    iconSize: 20.0,
                                    icon: Icon(Icons.check, color: Colors.white),
                                    onPressed: () {
                                      updateDescription();
                                    }
                                  ),
                                )
                              : Container(
                                width: 20,
                                child: IconButton(
                                  iconSize: 20.0,
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: () {
                                    onTapDescriptionField();
                                  }
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "" + amountInGroup.toString() + " Participants",
                              style: simpleTextStyle()
                          ),
                        ),
                        SizedBox(height: 10),
                        meAdmin
                          ? InkWell(
                            onTap: () {
                              addParticipant();
                            },
                            child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              child: Row(
                                  children: [
                                    Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.all(Radius.circular(40))
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            addParticipant();
                                          },
                                          icon: Icon(
                                              Icons.person_add,
                                              color: Colors.white
                                          ),
                                        )
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      "Add participants",
                                      style: TextStyle(color: Colors.grey, fontSize: 20),
                                    ),
                                  ]
                                ),
                              ),
                          )
                          : Container(),
                        Container(
                          alignment: Alignment.center,
                          child: brosInBroupList()
                        ),
                        SizedBox(height: 10),
                        TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
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
                                      chat.isMuted() ? Icons.volume_up : Icons.volume_mute,
                                      color: chat.isMuted() ? Colors.grey : Colors.red
                                  ),
                                  SizedBox(width: 20),
                                  chat.isMuted()
                                      ? Text(
                                    'Unmute Broup',
                                    style: simpleTextStyle(),
                                  ) : Text(
                                    'Mute Broup',
                                    style: simpleTextStyle(),
                                  ),
                                ]
                            )
                        ),
                        SizedBox(height: 10),
                        TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () {
                              showDialogExitBroup(context, chat.chatName);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.exit_to_app, color: Colors.red),
                                  SizedBox(width: 20),
                                  Text(
                                    'Leave Broup',
                                    style: simpleTextStyle(),
                                  ),
                                ]
                            )
                        ),
                        SizedBox(height: 10),
                        ]
                      ),
                    ),
                    chat.hasLeft() ? Container(
                      child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () {
                            showDialogDelete(context, chat.getBroNameOrAlias());
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
                              ]
                          )
                      ),
                    ) : Container(),
                    TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          showDialogReport(context, chat.getBroNameOrAlias());
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
                            ]
                        )
                    ),
                    SizedBox(height: 20),
                  ]
                ),
              ),
            ),
          ]),
        ));
  }

  void exitBroup() {
    socketServices.socket
        .emit("message_event_change_broup_remove_bro", {
      "token": settings.getToken(),
      "broup_id": chat.id,
      "bro_id": settings.getBroId()
    });
    Navigator.of(context).pop();
  }

  void showDialogExitBroup(BuildContext context, String broupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Leave Broup $broupName!"),
          content: new Text(
              "Are you sure you want to leave this broup?"),
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
          content: new Text(
              "Are you sure you want to delete this broup?"),
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
    deleteBroup.deleteBroup(
        settings.getToken(),
        chat.id
    ).then((val) {
      if (val is Broup) {
        Broup deletedBroup = val;
        broList.deleteChat(deletedBroup);
        storage.deleteChat(deletedBroup).then((value) {
          print("the broup is successfully removed!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
        });
      } else {
        if (val == "an unknown error has occurred") {
          ShowToastComponent.showDialog("An unknown error has occurred", context);
        } else {
          ShowToastComponent.showDialog("There was an error with the server, we apologize for the inconvenience.", context);
        }
      }
    });
    Navigator.of(context).pop();
  }

  void reportTheBroup() {
    reportBro.reportBroup(
        settings.getToken(),
        chat.id
    ).then((val) {
      if (val is Broup) {
        Broup broupToRemove = val;
        broList.deleteChat(broupToRemove);
        storage.deleteChat(broupToRemove).then((value) {
          print("the broup is successfully removed!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
        });
      } else {
        if (val == "an unknown error has occurred") {
          ShowToastComponent.showDialog("An unknown error has occurred", context);
        } else {
          ShowToastComponent.showDialog("There was an error with the server, we apologize for the inconvenience.", context);
        }
      }
    });
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
                      child: Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => selectedRadio = value);
                              }
                            }
                        ),
                        index == 0 ? Container(
                          child: Text("1 hour")
                        ) : Container(),
                        index == 1 ? Container(
                          child: Text("8 hours")
                        ) : Container(),
                        index == 2 ? Container(
                          child: Text("1 week")
                        ) : Container(),
                        index == 3 ? Container(
                            child: Text("Indefinitely")
                        ) : Container(),
                      ]
                      ),
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
    socketServices.socket
        .emit("message_event_change_broup_mute", {
      "token": settings.getToken(),
      "broup_id": chat.id,
      "bro_id": settings.getBroId(),
      "mute": -1
    });
    Navigator.of(context).pop();
  }

  void muteTheBroup(int selectedRadio) {
    socketServices.socket
        .emit("message_event_change_broup_mute", {
      "token": settings.getToken(),
      "broup_id": chat.id,
      "bro_id": settings.getBroId(),
      "mute": selectedRadio
    });
    Navigator.of(context).pop();
  }
}

class BroTile extends StatefulWidget {
  final Bro bro;
  final String broName;
  final int broupId;
  final bool userAdmin;
  final void Function(int) addNewBro;

  BroTile({
    required Key key,
    required this.bro,
    required this.broName,
    required this.broupId,
    required this.userAdmin,
    required this.addNewBro
  }) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {

  Settings settings =  Settings();

  var _tapPosition;

  selectBro(BuildContext context) {
    if (widget.bro.id != settings.getBroId()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              widget.userAdmin
                  ? getPopupItemsAdmin(context, widget.broName, widget.bro, widget.broupId, true, settings.getToken(), widget.addNewBro)
                  : getPopupItemsNormal(context, widget.broName, widget.bro, widget.broupId, true, settings.getToken(), widget.addNewBro)
            ]
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: GestureDetector(
          onLongPress: _showBroupPopupMenu,
          onTapDown: _storePosition,
          child: InkWell(
              onTap: () {
                selectBro(context);
              },
              child: Row(
                children: [
                  Container(
                  width: widget.bro.isAdmin()
                      ? MediaQuery.of(context).size.width-124
                      : MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                      widget.broName,
                      style: simpleTextStyle()),
                  ),
                  widget.bro.isAdmin()
                    ? Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green)
                      ),
                      child: Text(
                        "admin",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                        textAlign: TextAlign.center,
                      )
                    )
                    : Container(),
                ]
              ),
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }

  void _showBroupPopupMenu() {
    if (widget.bro.id != settings.getBroId()) {
      final RenderBox overlay = Overlay
          .of(context)!
          .context
          .findRenderObject() as RenderBox;

      showMenu(
          context: context,
          items: [
            BroupParticipantPopup(
                key: UniqueKey(),
                broName: widget.broName,
                bro:widget.bro,
                broupId: widget.broupId,
                userAdmin: widget.userAdmin,
                addNewBro: widget.addNewBro
            )
          ],
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40),
              Offset.zero & overlay.size
          )
      ).then((int? delta) {
        return;
      });
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

class BroupParticipantPopup extends PopupMenuEntry<int> {

  final String broName;
  final Bro bro;
  final int broupId;
  final bool userAdmin;
  final void Function(int) addNewBro;

  BroupParticipantPopup(
      {
        required Key key,
        required this.broName,
        required this.bro,
        required this.broupId,
        required this.userAdmin,
        required this.addNewBro
      }) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  BroupParticipantPopupState createState() => BroupParticipantPopupState();

  @override
  double get height => 1;
}

class BroupParticipantPopupState extends State<BroupParticipantPopup> {

  Settings settings = Settings();

  @override
  Widget build(BuildContext context) {
    return widget.userAdmin
        ? getPopupItemsAdmin(context, widget.broName, widget.bro, widget.broupId, false, settings.getToken(), widget.addNewBro)
        : getPopupItemsNormal(context, widget.broName, widget.bro, widget.broupId, false, settings.getToken(), widget.addNewBro);
  }
}

void buttonMessage(BuildContext context, Bro bro, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
  BroList broList = BroList();
  for (Chat br0 in broList.getBros()) {
    if (!br0.isBroup()) {
      if (br0.id == bro.id) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroMessaging(
                    key: UniqueKey(),
                    chat: br0 as BroBros
                )));
      }
    }
  }
}

void buttonAddBro(BuildContext context, Bro bro, bool alertDialog, String token, addNewBro) {
  print("pressed the add Bro Button");
  addNewBro(bro.id);
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
}

void buttonMakeAdmin(BuildContext context, Bro bro, int broupId, bool alertDialog, String token) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 2);
  }
  SocketServices socketServices = SocketServices();
  socketServices.socket
      .emit("message_event_change_broup_add_admin", {
    "token": token,
    "broup_id": broupId,
    "bro_id": bro.id
  });
}

void buttonDismissAdmin(BuildContext context, Bro bro, int broupId, bool alertDialog, String token) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  SocketServices socketServices = SocketServices();
  socketServices.socket
      .emit("message_event_change_broup_dismiss_admin", {
    "token": token,
    "broup_id": broupId,
    "bro_id": bro.id
  });
}

void buttonRemove(BuildContext context, Bro bro, int broupId, bool alertDialog, String token) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  SocketServices socketServices = SocketServices();
  socketServices.socket
      .emit("message_event_change_broup_remove_bro", {
    "token": token,
    "broup_id": broupId,
    "bro_id": bro.id
  });
}

Widget getPopupItemsAdmin(BuildContext context, String broName, Bro bro, int broupId, bool alertDialog, String token, addNewBro) {
  return Column(
    children: [
      bro is BroAdded
      ? Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonMessage(context, bro, alertDialog);
            },
            child: Text(
              'Message $broName',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      )
      : Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonAddBro(context, bro, alertDialog, token, addNewBro);
            },
            child: Text(
              'Add $broName',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      ),
      bro.isAdmin() ? Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed:  () {
              buttonDismissAdmin(context, bro, broupId, alertDialog, token);
            },
            child: Text(
                'Dismiss as admin',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 14),
              )
            ),
        )
        : Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
            onPressed: () {
                buttonMakeAdmin(context, bro, broupId, alertDialog, token);
              },
              child: Text(
              'Make Broup admin',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              buttonRemove(context, bro, broupId, alertDialog, token);
            },
            child: Text(
              'Remove $broName',
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      )
    ],
  );
}

Widget getPopupItemsNormal(BuildContext context, String broName, Bro bro, int broupId, bool alertDialog, String token, addNewBro) {
  return Column(
    children: [
      bro is BroAdded
      ? Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonMessage(context, bro, alertDialog);
            },
            child: Text(
              'Message $broName',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      )
      : Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonAddBro(context, bro, alertDialog, token, addNewBro);
            },
            child: Text(
              'Add $broName',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      ),
    ],
  );
}