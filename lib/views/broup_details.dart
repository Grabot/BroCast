import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

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
    chatDescriptionController.text = chat.chatDescription;
    chatAliasController.text = chat.alias;

    initSockets();
    NotificationService.instance.setScreen(this);

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.chatColor,
    );
    currentColor = chat.chatColor;
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

  void initSockets() {
    SocketServices.instance.socket
        .on('message_event_send_solo', (data) => messageReceivedSolo(data));
    SocketServices.instance.socket
        .on('message_event_change_broup_details_success', (data) {
      broupDetailUpdateSuccess();
    });
    SocketServices.instance.socket
        .on('message_event_change_broup_alias_success', (data) {
      broupAliasUpdateSuccess();
    });
    SocketServices.instance.socket
        .on('message_event_change_broup_details_failed', (data) {
      broupDetailUpdateFailed();
    });
    SocketServices.instance.socket
        .on('message_event_change_broup_colour_success', (data) {
      broupColourUpdateSuccess();
    });
    SocketServices.instance.socket.on('message_event_change_broup_colour_failed',
        (data) {
          broupColourUpdateFailed();
    });
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      for (BroBros br0 in BroList.instance.getBros()) {
        if (br0.id == data["sender_id"]) {
          if (showNotification) {
            NotificationService.instance
                .showNotification(br0.id, br0.chatName, "", data["body"]);
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

  void goToDifferentChat(BroBros chatBro) {
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

  void broupDetailUpdateSuccess() {
    previousDescription = chatDescriptionController.text;
    chat.chatDescription = chatDescriptionController.text;
    if (mounted) {
      setState(() {});
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

  void broupDetailUpdateFailed() {
    currentColor = previousColor;
    circleColorPickerController.color = previousColor;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void broupColourUpdateSuccess() {
    chat.chatColor = currentColor;
    previousColor = currentColor;
    if (mounted) {
      setState(() {});
    }
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
    for (Chat br0 in BroList.instance.getBros()) {
      if (!br0.isBroup) {
        if (bro.id == br0.id) {
          // If he has added the bro and given it an alias, we take it over.
          broName = br0.getBroNameOrAlias();
        }
      }
    }
    return BroTile(bro: bro, broName: broName);
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
                        "" + chat.getParticipants().length.toString() + " Participants",
                        style: simpleTextStyle()
                    ),
                  ),
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

  BroTile({Key key, this.bro, this.broName}) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {
  selectBro(BuildContext context) {
    if (widget.bro.id == Settings.instance.getBroId()) {
      print("selected myself");
    } else {
      if (widget.bro is BroAdded) {
        print("selected a bro, who's a bro of this bro");
      } else {
        print("selected a possibly future bro of this bro");
      }
    }
    if (widget.bro.admin) {
      print("THIS IS THE ADMIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
            onTap: () {
              selectBro(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                  widget.broName,
                  style: simpleTextStyle()),
            )
        ),
        color: Colors.transparent,
      ),
    );
  }
}
