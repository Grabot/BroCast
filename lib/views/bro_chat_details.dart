import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/block_bro.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/remove_bro.dart';
import 'package:brocast/services/report_bro.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

import 'bro_home.dart';
import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';


class BroChatDetails extends StatefulWidget {
  final BroBros chat;

  BroChatDetails(
      {
        required Key key,
        required this.chat
      }) : super(key: key);

  @override
  _BroChatDetailsState createState() => _BroChatDetailsState();
}

class _BroChatDetailsState extends State<BroChatDetails> {
  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;

  late CircleColorPickerController circleColorPickerController;

  BlockBro blockBro = new BlockBro();
  ReportBro reportBro = new ReportBro();
  RemoveBro removeBro = new RemoveBro();
  Settings settings = Settings();
  GetChat getChat = new GetChat();
  BroList broList = BroList();
  SocketServices socketServices = SocketServices();

  late Color currentColor;
  Color? previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  late BroBros chat;
  late Storage storage;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    BackButtonInterceptor.add(myInterceptor);
    chatDescriptionController.text = chat.chatDescription;
    chatAliasController.text = chat.alias;
    storage = Storage();
    storage.selectChat(chat.id.toString(), chat.broup.toString()).then((value) {
      chat = value as BroBros;
    });

    // We retrieved the chat locally, but we will also get it from the server
    // If anything has changed, we can update it locally
    getChat.getChat(settings.getBroId(), chat.id).then((value) {
      if (value is BroBros) {
        chat = value;
        chat.unreadMessages = 0;
        broList.updateChat(chat);
        storage.updateChat(chat).then((value) {
        });
        setState(() {});
      }
    });

    initBroChatDetailsSockets();

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.getColor(),
    );

    currentColor = chat.getColor();
  }

  void initBroChatDetailsSockets() {
    socketServices.socket
        .on('message_event_change_chat_details_failed', (data) {
      chatDetailUpdateFailed();
    });
    socketServices.socket.on('message_event_change_chat_colour_failed',
        (data) {
      chatColourUpdateFailed();
    });
    socketServices.socket.on('message_event_change_chat_mute_success', (data) {
      chatWasMuted(data);
    });
    socketServices.socket.on('message_event_change_chat_mute_failed', (data) {
      chatMutingFailed();
    });
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
          MaterialPageRoute(builder: (context) => BroMessaging(
            key: UniqueKey(),
            chat: chat
          )));
    }
  }

  socketListener() {
    // There was some update to the bro list.
    // Check the list and see if the change was to this chat object.
    for(Chat ch4t in broList.getBros()) {
      if (!ch4t.isBroup()) {
        if (ch4t.id == chat.id) {
          // This is the chat object of the current chat.
          if (ch4t.chatName != chat.chatName
              || ch4t.chatColor != chat.chatColor
              || ch4t.chatDescription != chat.chatDescription
              || ch4t.alias != chat.alias
              || ch4t.mute != chat.mute
              || ch4t.blocked != chat.blocked) {
            // If either the name colour has changed. We want to update the screen
            // We know if it gets here that it is a BroBros object and that
            // it is the same BroBros object as the current open chat
            setState(() {
              chat = ch4t as BroBros;
              if (!focusNodeDescription.hasFocus) {
                chatDescriptionController.text = ch4t.chatDescription;
              } else {
                previousDescription = ch4t.chatDescription;
              }
              currentColor = ch4t.getColor();
              circleColorPickerController.color = ch4t.getColor();
              chatAliasController.text = ch4t.alias;
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.socket.off('message_event_change_chat_details_failed');
    socketServices.socket.off('message_event_change_chat_colour_failed');
    socketServices.socket.off('message_event_change_chat_mute_success');
    socketServices.socket.off('message_event_change_chat_mute_failed');
    socketServices.removeListener(socketListener);
    chatDescriptionController.dispose();
    chatAliasController.dispose();
    circleColorPickerController.dispose();
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
                      PopupMenuItem<int>(value: 2, child: Text("Back to chat")),
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
                builder: (context) => BroMessaging(
                  key: UniqueKey(),
                  chat: chat
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
          .emit("message_event_change_chat_details", {
        "token": settings.getToken(),
        "bros_bro_id": chat.id,
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
          .emit("message_event_change_chat_alias", {
        "token": settings.getToken(),
        "bros_bro_id": chat.id,
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
    if (!chat.isBlocked()) {
      previousColor = currentColor;
      setState(() {
        changeColour = true;
      });
    }
  }

  saveColour() {
    if (currentColor != chat.getColor()) {
      String newColour = currentColor.value.toRadixString(16).substring(2, 8);
      socketServices.socket
          .emit("message_event_change_chat_colour", {
        "token": settings.getToken(),
        "bros_bro_id": chat.id,
        "colour": newColour
      });
    }
    setState(() {
      changeColour = false;
    });
  }

  void reportTheBro() {
    reportBro.reportBro(
        settings.getToken(),
        chat.id
    ).then((val) {
      if (val is BroBros) {
        BroBros broToRemove = val;
        storage.deleteChat(broToRemove).then((value) {
          print("the chat is successfully removed!");
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

  void removeTheBro() {
    removeBro.removeBro(
        settings.getToken(),
        chat.id
    ).then((val) {
      // De bro moet verwijderd worden!
      if (val is BroBros) {
        BroBros broToRemove = val;
        broList.deleteChat(broToRemove);
        storage.deleteChat(broToRemove).then((value) {
          print("the chat is successfully removed!");
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

  void blockTheBro(bool blocked) {
    blockBro.blockBro(
      settings.getToken(),
      chat.id,
        blocked
    ).then((val) {
      if (val is BroBros) {
        setState(() {
          this.chat = val;
          storage.updateChat(this.chat).then((value) {
            setState(() {});
          });
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

  void chatDetailUpdateFailed() {
    currentColor = previousColor!;
    circleColorPickerController.color = previousColor!;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void chatColourUpdateFailed() {
    chatDescriptionController.text = previousDescription;
    ShowToastComponent.showDialog(
        "Updating the bro colour has failed", context);
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  chatWasMuted(var data) {
    if (data.containsKey("result")) {
      bool result = data["result"];
      if (result) {
        chat.setMuted(data["mute"]);
        storage.updateChat(chat).then((value) {
          setState(() {});
        });
      }
    }
  }

  chatMutingFailed() {
    ShowToastComponent.showDialog(
        "Chat muting failed at this time.", context);
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
                  chat.alias.isNotEmpty
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
                chat.isBlocked() ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    child: Text(
                      "You've blocked this Bro!",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ))
                  : Container(
                  child: Column(children: [
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
                    SizedBox(height: 30),
                    TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          chat.isMuted()
                              ? showDialogUnMuteChat(context)
                              : showDialogMuteChat(context);
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
                                'Unmute Chat',
                                style: simpleTextStyle(),
                              ) : Text(
                                'Mute Chat',
                                style: simpleTextStyle(),
                              ),
                            ]
                        )
                    ),
                    TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          showDialogBlock(context, chat.getBroNameOrAlias());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.block,
                                color: Colors.red
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Block',
                              style: simpleTextStyle(),
                            ),
                          ]
                        )
                      ),
                    ]
                    )
                    ),
                    chat.isBlocked()
                        ? Container(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              TextButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                    MaterialStateProperty.all<Color>(Colors.red),
                                  ),
                                  onPressed: () {
                                    showDialogUnBlockChat(context);
                                  },
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.block,
                                            color: Colors.grey
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          'Unblock',
                                          style: simpleTextStyle(),
                                        )
                                      ]
                                  )
                              ),
                              ]
                            ),
                        )
                        : Container(),
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
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 20),
                            Text(
                              'Delete Bro',
                              style: simpleTextStyle(),
                            ),
                          ]
                      )
                  ),
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
                  SizedBox(height:100)
                  ],
                ),
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
          title: new Text("Remove Bro $chatName!"),
          content: new Text(
              "Are you sure you want to delete this chat? This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore. \n(This action cannot be undone!)"),
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

  void showDialogUnMuteChat(BuildContext context) {
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
                  unmuteTheChat();
                },
              ),
            ],
          );
        });
  }

  void showDialogUnBlockChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Unblock Bro?"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Unblock"),
                onPressed: () {
                  blockTheBro(false);
                },
              ),
            ],
          );
        });
  }

  void showDialogMuteChat(BuildContext context) {
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
                  muteTheChat(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  void unmuteTheChat() {
    socketServices.socket
        .emit("message_event_change_chat_mute", {
      "token": settings.getToken(),
      "bros_bro_id": chat.id,
      "bro_id": settings.getBroId(),
      "mute": -1
    });
    Navigator.of(context).pop();
  }

  void muteTheChat(int selectedRadio) {
    socketServices.socket
        .emit("message_event_change_chat_mute", {
      "token": settings.getToken(),
      "bros_bro_id": chat.id,
      "bro_id": settings.getBroId(),
      "mute": selectedRadio
    });
    Navigator.of(context).pop();
  }
}
