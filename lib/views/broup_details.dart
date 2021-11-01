import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/get_broup_bros.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
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
  final Chat chat;

  BroupDetails({Key key, this.chat}) : super(key: key);

  @override
  _BroupDetailsState createState() => _BroupDetailsState();
}

class _BroupDetailsState extends State<BroupDetails>
    with WidgetsBindingObserver {

  GetChat getChat = new GetChat();

  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;
  bool showNotification = true;

  int amountInGroup;

  CircleColorPickerController circleColorPickerController;

  Color currentColor;
  Color previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  Broup chat;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    amountInGroup = chat.getBroupBros().length;
    BackButtonInterceptor.add(myInterceptor);

    // We retrieve the broup again in case there were changes.
    getChat.getBroup(Settings.instance.getToken(), chat.id).then((value) {
      if (value != "an unknown error has occurred") {
        chat = value;
        getParticipants();
        chatDescriptionController.text = chat.chatDescription;
        chatAliasController.text = chat.alias;

        circleColorPickerController = CircleColorPickerController(
          initialColor: chat.chatColor,
        );
        currentColor = chat.chatColor;
        setState(() {
        });
      }
    });

    joinBroupRoom(Settings.instance.getBroId(), chat.id);
    initSockets();
    NotificationService.instance.setScreen(this);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  void changeToBroup() {
    if (mounted) {
      print("there was a change to a broup");
      setState(() {
        getChat.getBroup(Settings.instance.getToken(), chat.id).then((value) {
          print("gotten the chat");
          print(value);
          print(Settings.instance.getBroId());
          print(chat.id);
          if (value != "an unknown error has occurred") {
            setState(() {
              print("setting the chat");
              chat = value;
              getParticipants();
            });
          }
        });
      });
    }
  }

  getParticipants() {
    List<int> remainingParticipants = new List<int>.from(chat.getParticipants());
    List<int> remainingAdmins = new List<int>.from(chat.getAdmins());
    // List<Bro> foundParticipants = [];
    // We will reform the list. First me, than the admins than the rest
    List<Bro> broupMe = [];
    List<Bro> foundBroupAdmins = [];
    List<Bro> foundBroupNotAdmins = [];

    // I have to be in the array or participants, since I am in this broup.
    Bro me = Settings.instance.getMe();
    Bro meBroup = me.copyBro();
    if (remainingAdmins.contains(meBroup.id)) {
      meBroup.setAdmin(true);
      remainingAdmins.remove(meBroup.id);
      chat.setAmIAdmin(true);
    } else {
      chat.setAmIAdmin(false);
    }
    broupMe.add(meBroup);
    remainingParticipants.remove(Settings.instance.getBroId());

    for (Chat br0 in BroList.instance.getBros()) {
      if (br0 is BroBros) {
        if (remainingParticipants.contains(br0.id)) {
          BroAdded broAdded = new BroAdded(br0.id, br0.chatName);
          if (remainingAdmins.contains(br0.id)) {
            broAdded.setAdmin(true);
            remainingAdmins.remove(br0.id);
            foundBroupAdmins.add(broAdded);
          } else {
            foundBroupNotAdmins.add(broAdded);
          }
          remainingParticipants.remove(br0.id);
        }
      }
    }

    if (remainingParticipants.length != 0) {
      GetBroupBros getBroupBros = new GetBroupBros();
      getBroupBros.getBroupBros(
          Settings.instance.getToken(), remainingParticipants).then((value) {
        if (value != "an unknown error has occurred") {
          List<Bro> notAddedBros = value;
          for (Bro br0 in notAddedBros) {
            if (remainingAdmins.contains(br0.id)) {
              br0.setAdmin(true);
              remainingAdmins.remove(br0.id);
              foundBroupAdmins.add(br0);
            } else {
              foundBroupNotAdmins.add(br0);
            }
            remainingParticipants.remove(br0.id);
          }
          // We assume this won't happen
          if (remainingParticipants.length != 0) {
            print("big error! Fix it!");
          }
          chat.setBroupBros(broupMe + foundBroupAdmins + foundBroupNotAdmins);
          amountInGroup = chat.getBroupBros().length;
          setState(() {
          });
        }
      });
    } else {
      // We assume this won't happen
      if (remainingParticipants.length != 0) {
        print("big error! Fix it!");
      }
      chat.setBroupBros(broupMe + foundBroupAdmins + foundBroupNotAdmins);
      amountInGroup = chat.getBroupBros().length;
      setState(() {
      });
    }
  }

  joinBroupRoom(int broId, int broupId) {
    if (SocketServices.instance.socket.connected) {
      print("socket connected :)");
      SocketServices.instance.socket.emit(
        "join_broup",
        {"bro_id": broId, "broup_id": broupId},
      );
    } else {
      print("socket NOT connected >:(");
    }
  }

  void initSockets() {
    if (SocketServices.instance.socket.connected) {
      SocketServices.instance.socket
          .on('message_event_send_solo', (data) => messageReceivedSolo(data));
      SocketServices.instance.socket
          .on('message_event_change_broup_details_success', (data) {
        broupDetailUpdateSuccess(data);
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_details_failed', (data) {
        broupDetailUpdateFailed();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_alias_success', (data) {
        broupAliasUpdateSuccess();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_alias_failed', (data) {
        broupAliasUpdateSuccess();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_colour_success', (data) {
        broupColourUpdateSuccess(data);
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_colour_failed', (data) {
        broupColourUpdateFailed();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_add_admin_success', (data) {
        broupAddAdminSuccess(data);
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_add_admin_failed', (data) {
        broupAddAdminFailed();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_dismiss_admin_success', (data) {
        broupDismissAdminSuccess(data);
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_dismiss_admin_failed', (data) {
        broupDismissAdminFailed();
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_remove_bro_success', (data) {
        broupRemoveBroSuccess(data);
      });
      SocketServices.instance.socket
          .on('message_event_change_broup_remove_bro_failed', (data) {
        broupRemoveBroFailed();
      });
      SocketServices.instance.socket.on('message_event_broup_changed', (data) {
        changeToBroup();
      });
      SocketServices.instance.socket.on('message_event_add_bro_success', (data) {
        broWasAdded();
      });
      SocketServices.instance.socket.on('message_event_add_bro_failed', (data) {
        broAddingFailed();
      });
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
          MaterialPageRoute(builder: (context) => BroupMessaging(chat: chat)));
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    SocketServices.instance.socket
        .off('message_event_send_solo', (data) => print(data));
    SocketServices.instance.socket.off(
        'message_event_change_chat_details_success', (data) => print(data));
    SocketServices.instance.socket
        .off('message_event_change_chat_details_failed', (data) => print(data));
    SocketServices.instance.socket
        .off('message_event_change_chat_colour_success', (data) => print(data));
    SocketServices.instance.socket
        .off('message_event_change_chat_colour_failed', (data) => print(data));
    super.dispose();
  }

  void goToDifferentChat(Chat chatBro) {
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroupMessaging(chat: chatBro)));
    }
  }

  Widget appBarChatDetails() {
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
              chat.alias != null && chat.alias.isNotEmpty
                  ? Container(
                  child: Text(chat.alias,
                      style: TextStyle(
                          color: getTextColor(chat.chatColor), fontSize: 20)))
                  : Container(
                  child: Text(chat.chatName,
                      style: TextStyle(
                          color: getTextColor(chat.chatColor), fontSize: 20))),
            ]
        ),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelectChat(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Profile")),
                    PopupMenuItem<int>(value: 1, child: Text("Settings")),
                    PopupMenuItem<int>(value: 2, child: Text("Back to broup")),
                  ])
        ]);
  }

  void onSelectChat(BuildContext context, int item) {
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
                builder: (context) => BroupMessaging(chat: chat)));
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
      print("going to update the description");
      if (SocketServices.instance.socket.connected) {
        print("socket is connected");
        SocketServices.instance.socket
            .emit("message_event_change_broup_details", {
          "token": Settings.instance.getToken(),
          "broup_id": chat.id,
          "description": chatDescriptionController.text
        });
      }
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
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket
            .emit("message_event_change_broup_alias", {
          "token": Settings.instance.getToken(),
          "broup_id": chat.id,
          "alias": chatAliasController.text
        });
      }
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
    if (!chat.blocked) {
      previousColor = currentColor;
      setState(() {
        changeColour = true;
      });
    }
  }

  saveColour() {
    if (currentColor != chat.chatColor) {
      String newColour = currentColor.value.toRadixString(16).substring(2, 8);
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket
            .emit("message_event_change_broup_colour", {
          "token": Settings.instance.getToken(),
          "broup_id": chat.id,
          "colour": newColour
        });
      }
    }
    setState(() {
      changeColour = false;
    });
  }

  void broupDetailUpdateSuccess(var data) {
    if (mounted) {
      if (data.containsKey("result")) {
        bool result = data["result"];
        if (result) {
          chat.chatDescription = data["description"];
          chatDescriptionController.text = data["description"];
          previousDescription = "";
          setState(() {});
        }
      }
    }
  }

  void broupAliasUpdateSuccess() {
    print("alias update successfull");
    previousAlias = chatAliasController.text;
    chat.alias = chatAliasController.text;
    if (mounted) {
      setState(() {});
    }
  }

  void broupAliasUpdateFailed() {
    chatAliasController.text = previousAlias;
    if (mounted) {
      ShowToastComponent.showDialog(
          "Updating the bro alias has failed", context);
    }
  }

  void broupDetailUpdateFailed() {
    currentColor = previousColor;
    circleColorPickerController.color = previousColor;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void broupColourUpdateSuccess(var data) {
    if (mounted) {
      if (data.containsKey("result")) {
        bool result = data["result"];
        if (result) {
          chat.chatColor = Color(int.parse("0xFF${data["colour"]}"));
          currentColor = Color(int.parse("0xFF${data["colour"]}"));
          previousColor = Color(int.parse("0xFF${data["colour"]}"));
          setState(() {});
        }
      }
    }
  }

  void broupAddAdminSuccess(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        for (Bro bro in chat.getBroupBros()) {
          if (bro.id == data["new_admin"]) {
            bro.setAdmin(true);
            chat.addAdmin(data["new_admin"]);
            if (Settings.instance.getBroId() == data["new_admin"]) {
              chat.setAmIAdmin(true);
            }
            break;
          }
        }
        if (mounted) {
          setState(() {
          });
        }
      } else {
        broupAddAdminFailed();
      }
    } else {
      broupAddAdminFailed();
    }
  }

  void broupAddAdminFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "Adding the bro as admin has failed", context);
    }
  }

  void broupDismissAdminSuccess(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        for (Bro bro in chat.getBroupBros()) {
          if (bro.id == data["old_admin"]) {
            bro.setAdmin(false);
            chat.dismissAdmin(data["old_admin"]);
            if (Settings.instance.getBroId() == data["old_admin"]) {
              chat.setAmIAdmin(false);
            }
            break;
          }
        }
        if (mounted) {
          setState(() {
          });
        }
      } else {
        broupAddAdminFailed();
      }
    } else {
      broupAddAdminFailed();
    }
  }

  void broupDismissAdminFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "Dismissing the bro from his admin role has failed", context);
    }
  }

  void broupRemoveBroSuccess(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        for (Bro bro in chat.getBroupBros()) {
          if (bro.id == data["old_bro"]) {
            chat.dismissAdmin(data["old_bro"]);
            chat.removeBro(data["old_bro"]);
            break;
          }
        }
        if (mounted) {
          setState(() {
          });
        }
      } else {
        broupRemoveBroFailed();
      }
    } else {
      broupRemoveBroFailed();
    }
  }

  void broupRemoveBroFailed() {
    if (mounted) {
      ShowToastComponent.showDialog(
          "Removing the bro from the broup has failed", context);
    }
  }

  void broupColourUpdateFailed() {
    chatDescriptionController.text = previousDescription;
    if (mounted) {
      ShowToastComponent.showDialog(
          "Updating the bro colour has failed", context);
    }
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
    for (Chat br0 in BroList.instance.getBros()) {
      if (!br0.isBroup) {
        if (bro.id == br0.id) {
          // If he has added the bro and given it an alias, we take it over.
          broName = br0.getBroNameOrAlias();
        }
      }
    }
    return BroTile(bro: bro, broName: broName, broupId: chat.id, userAdmin: chat.amIAdmin());
  }

  addParticipant() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(
            builder: (context) => BroupAddParticipant(chat: chat)));
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
                              color: chat.chatColor,
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
                  chat.amIAdmin()
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
                  SizedBox(height: 40),
                ]),
              ),
            ),
          ]),
        ));
  }
}

class BroTile extends StatefulWidget {
  final Bro bro;
  final String broName;
  final int broupId;
  final bool userAdmin;

  BroTile({
    Key key,
    this.bro,
    this.broName,
    this.broupId,
    this.userAdmin
  }) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {

  var _tapPosition;

  selectBro(BuildContext context) {
    if (widget.bro.id != Settings.instance.getBroId()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              widget.userAdmin
                  ? getPopupItemsAdmin(context, widget.broName, widget.bro, widget.broupId, true)
                  : getPopupItemsNormal(context, widget.broName, widget.bro, widget.broupId, true)
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
                  width: widget.bro.admin
                      ? MediaQuery.of(context).size.width-84
                      : MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                      widget.broName,
                      style: simpleTextStyle()),
                  ),
                  widget.bro.admin
                    ? Container(
                      width: 60,
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
    if (widget.bro.id != Settings.instance.getBroId()) {
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();

      showMenu(
          context: context,
          items: [
            BroupParticipantPopup(broName: widget.broName, bro:widget.bro, broupId: widget.broupId, userAdmin: widget.userAdmin)
          ],
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40),
              Offset.zero & overlay.size
          )
      ).then((int delta) {
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

  BroupParticipantPopup({Key key, this.broName, this.bro, this.broupId, this.userAdmin}) : super(key: key);

  @override
  bool represents(int n) => n == 1 || n == -1;

  @override
  BroupParticipantPopupState createState() => BroupParticipantPopupState();

  @override
  double get height => 1;
}

class BroupParticipantPopupState extends State<BroupParticipantPopup> {

  @override
  Widget build(BuildContext context) {
    return widget.userAdmin
        ? getPopupItemsAdmin(context, widget.broName, widget.bro, widget.broupId, false)
        : getPopupItemsNormal(context, widget.broName, widget.bro, widget.broupId, false);
  }
}

void buttonMessage(BuildContext context, Bro bro, bool alertDialog) {
  print("pressed the message button");
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
  for (Chat br0 in BroList.instance.getBros()) {
    if (!br0.isBroup) {
      if (br0.id == bro.id) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroMessaging(chat: br0)));
      }
    }
  }
}

void buttonAddBro(BuildContext context, Bro bro, bool alertDialog) {
  print("pressed the add bro button");
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
  if (SocketServices.instance.socket.connected) {
    SocketServices.instance.socket.emit("message_event_add_bro",
        {"token": Settings.instance.getToken(), "bros_bro_id": bro.id});
  }
}

void buttonMakeAdmin(BuildContext context, Bro bro, int broupId, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 2);
  }
  if (SocketServices.instance.socket.connected) {
    SocketServices.instance.socket
        .emit("message_event_change_broup_add_admin", {
      "token": Settings.instance.getToken(),
      "broup_id": broupId,
      "bro_id": bro.id
    });
  }
}

void buttonDismissAdmin(BuildContext context, Bro bro, int broupId, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  if (SocketServices.instance.socket.connected) {
    SocketServices.instance.socket
        .emit("message_event_change_broup_dismiss_admin", {
      "token": Settings.instance.getToken(),
      "broup_id": broupId,
      "bro_id": bro.id
    });
  }
}

void buttonRemove(BuildContext context, Bro bro, int broupId, bool alertDialog) {
  print("removing bro ${bro.id} from broup $broupId");
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  SocketServices.instance.socket
      .emit("message_event_change_broup_remove_bro", {
    "token": Settings.instance.getToken(),
    "broup_id": broupId,
    "bro_id": bro.id
  });
}

Widget getPopupItemsAdmin(BuildContext context, String broName, Bro bro, int broupId, bool alertDialog) {
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
              buttonAddBro(context, bro, alertDialog);
            },
            child: Text(
              'Add $broName',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      ),
      bro.admin ? Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed:  () {
              buttonDismissAdmin(context, bro, broupId, alertDialog);
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
                buttonMakeAdmin(context, bro, broupId, alertDialog);
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
              buttonRemove(context, bro, broupId, alertDialog);
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

Widget getPopupItemsNormal(BuildContext context, String broName, Bro bro, int broupId, bool alertDialog) {
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
              buttonAddBro(context, bro, alertDialog);
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