import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/block_bro.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/remove_bro.dart';
import 'package:brocast/services/report_bro.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

import 'bro_home.dart';
import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';

class BroChatDetails extends StatefulWidget {
  final Chat chat;

  BroChatDetails({Key key, this.chat}) : super(key: key);

  @override
  _BroChatDetailsState createState() => _BroChatDetailsState();
}

class _BroChatDetailsState extends State<BroChatDetails>
    with WidgetsBindingObserver {
  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;
  bool showNotification = true;

  CircleColorPickerController circleColorPickerController;

  BlockBro blockBro;
  ReportBro reportBro;
  RemoveBro removeBro;

  Color currentColor;
  Color previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  Chat chat;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
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

    blockBro = new BlockBro();
    reportBro = new ReportBro();
    removeBro = new RemoveBro();
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
        .on('message_event_change_chat_details_success', (data) {
      chatDetailUpdateSuccess(data);
    });
    SocketServices.instance.socket
        .on('message_event_change_chat_alias_success', (data) {
      chatAliasUpdateSuccess();
    });
    SocketServices.instance.socket
        .on('message_event_change_chat_details_failed', (data) {
      chatDetailUpdateFailed();
    });
    SocketServices.instance.socket
        .on('message_event_change_chat_colour_success', (data) {
      chatColourUpdateSuccess(data);
    });
    SocketServices.instance.socket.on('message_event_change_chat_colour_failed',
        (data) {
      chatColourUpdateFailed();
    });
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
          MaterialPageRoute(builder: (context) => BroMessaging(chat: chat)));
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
              builder: (context) => BroMessaging(chat: chatBro)));
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
                    PopupMenuItem<int>(value: 2, child: Text("Back to chat")),
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
                builder: (context) => BroMessaging(chat: chat)));
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
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket
            .emit("message_event_change_chat_details", {
          "token": Settings.instance.getToken(),
          "bros_bro_id": chat.id,
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
            .emit("message_event_change_chat_alias", {
          "token": Settings.instance.getToken(),
          "bros_bro_id": chat.id,
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
            .emit("message_event_change_chat_colour", {
          "token": Settings.instance.getToken(),
          "bros_bro_id": chat.id,
          "colour": newColour
        });
      }
    }
    setState(() {
      changeColour = false;
    });
  }

  void reportTheBro() {
    reportBro.reportBro(
        Settings.instance.getToken(),
        chat.id
    ).then((val) {
      if (val) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroCastHome()));
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

  void removeTheBro() {
    removeBro.removeBro(
        Settings.instance.getToken(),
        chat.id
    ).then((val) {
      if (val) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroCastHome()));
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

  void blockTheBro(bool blocked) {
    blockBro.blockBro(
      Settings.instance.getToken(),
      chat.id,
        blocked
    ).then((val) {
      if (val is BroBros) {
        setState(() {
          this.chat = val;
        });
      } else {
        if (val == "an unknown error has occurred") {
          ShowToastComponent.showDialog("An unknown error has occurred", context);
        } else {
          ShowToastComponent.showDialog("There was an error with the server, we apologize for the inconvenience.", context);
        }
      }
    });
    if (blocked) {
      Navigator.of(context).pop();
    }
  }

  void chatDetailUpdateSuccess(var data) {
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

  void chatAliasUpdateSuccess() {
    previousAlias = chatAliasController.text;
    chat.alias = chatAliasController.text;
    if (mounted) {
      setState(() {});
    }
  }

  void chatDetailUpdateFailed() {
    currentColor = previousColor;
    circleColorPickerController.color = previousColor;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void chatColourUpdateSuccess(var data) {
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

  void chatColourUpdateFailed() {
    chatDescriptionController.text = previousDescription;
    ShowToastComponent.showDialog(
        "Updating the bro colour has failed", context);
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarChatDetails(),
        body: Container(
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
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
                            decoration: textFieldInputDecoration("No chat alias yet"),
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
                            textFieldInputDecoration("No chat description yet"),
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
                  SizedBox(height: 10),
                  TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                      ),
                      onPressed: () {
                        chat.blocked ?
                        blockTheBro(false) : showDialogBlock(context, chat.getBroNameOrAlias());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              Icons.block,
                              color: chat.blocked ? Colors.grey : Colors.red
                          ),
                          SizedBox(width: 20),
                          chat.blocked ? Text(
                            'Unblock',
                            style: simpleTextStyle(),
                          ) : Text(
                            'Block',
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
                        showDialogRemove(context, chat.getBroNameOrAlias());
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_forever, color: Colors.red),
                            SizedBox(width: 20),
                            Text(
                              'Remove Bro',
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
                        showDialogReport(context, chat.getBroNameOrAlias());
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_down, color: Colors.red),
                            SizedBox(width: 20),
                            Text(
                              'Report Bro',
                              style: simpleTextStyle(),
                            ),
                          ]
                      )
                  ),
                  SizedBox(height: 20),
                ]),
              ),
            ),
          ]),
        ));
  }

  void showDialogBlock(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Block bro $chatName!"),
          content: new Text(
              "Are you sure you want to block this bro? The former bro will no longer be able to send you messages."),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Block"),
              onPressed: () {
                blockTheBro(true);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogRemove(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Remove chat $chatName!"),
          content: new Text(
              "Are you sure you want to remove this chat? This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore. \n(This action cannot be undone!)"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Remove"),
              onPressed: () {
                removeTheBro();
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
          title: new Text("Report bro $chatName!"),
          content: new Text(
              "Are you sure you want to report this bro? The most recent messages from this bro to you will be forwarded to Zwaar developers to assess possible deletion of the bro's account. This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore. This former bro will not be notified of the report. \n(This action cannot be undone!)"),
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
                reportTheBro();
              },
            ),
          ],
        );
      },
    );
  }
}
