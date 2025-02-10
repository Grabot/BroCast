import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/chat_view/bro_messaging/bro_messaging.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../../../objects/broup.dart';
import '../../../services/auth/auth_service_settings.dart';
import '../../../utils/new/storage.dart';
import '../../bro_home/bro_home.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';

class ChatDetails extends StatefulWidget {
  final Broup chat;

  ChatDetails({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;

  late CircleColorPickerController circleColorPickerController;

  // BlockBro blockBro = new BlockBro();
  // ReportBro reportBro = new ReportBro();
  // RemoveBro removeBro = new RemoveBro();
  Settings settings = Settings();
  // GetChat getChat = new GetChat();
  // BroList broList = BroList();
  SocketServices socketServices = SocketServices();

  late Color currentColor;
  Color? previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  late Broup chat;
  late Storage storage;

  double iconSize = 30;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    BackButtonInterceptor.add(myInterceptor);
    chatDescriptionController.text = chat.getBroupDescription();
    chatAliasController.text = chat.alias;
    storage = Storage();

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.getColor(),
    );

    currentColor = chat.getColor();
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
      if (settings.doneRoutes.contains(routes.BroMessagingRoute)) {
        // We want to pop until we reach the BroHomeRoute
        // We remove one, because it's this page.
        settings.doneRoutes.removeLast();
        for (int i = 0; i < 200; i++) {
          String route = settings.doneRoutes.removeLast();
          Navigator.pop(context);
          if (route == routes.BroMessagingRoute) {
            break;
          }
          if (settings.doneRoutes.length == 0) {
            break;
          }
        }
      } else {
        // TODO: How to test this?
        settings.doneRoutes = [];
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BroMessaging(
              key: UniqueKey(),
              chat: chat,
            )));
      }
    }
  }

  socketListener() {
    setState(() {});
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
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
                icon: Icon(Icons.more_vert, color: getTextColor(chat.getColor())),
                onSelected: (item) => onSelectChat(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Back to chat")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelectChat(BuildContext context, int item) {
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
                    BroMessaging(key: UniqueKey(), chat: chat)));
        break;
      case 3:
        Navigator.pushReplacement(
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

  void updateDescription() {
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

  void updateAlias() {
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
    if (!chat.isBlocked()) {
      previousColor = currentColor;
      setState(() {
        changeColour = true;
      });
    }
  }

  String toHex(Color test) {
    final hexR = (test.r * 255).round().toRadixString(16).padLeft(2, '0');
    final hexG = (test.g * 255).round().toRadixString(16).padLeft(2, '0');
    final hexB = (test.b * 255).round().toRadixString(16).padLeft(2, '0');

    return '$hexR$hexG$hexB';
  }

  saveColour() {
    if (currentColor != chat.getColor()) {
      String newBroupColour = toHex(currentColor);
      print("New colour: $newBroupColour");
      AuthServiceSettings().changeColourBroup(chat.getBroupId(), newBroupColour).then((val) {
        if (val) {
          // The details are updated via sockets.
        } else {
          showToastMessage("something went wrong with changing the colour");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
  }

  reportTheBro() {
    // reportBro.reportBro("settings.getToken()", chat.id).then((val) {
    //   if (val is BroBros) {
    //     BroBros broToRemove = val;
    //     storage.deleteChat(broToRemove).then((value) {
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
    // Navigator.of(context).pop();
  }

  removeTheBro() {
    // removeBro.removeBro("settings.getToken()", chat.id).then((val) {
    //   // De bro moet verwijderd worden!
    //   if (val is BroBros) {
    //     BroBros broToRemove = val;
    //     broList.deleteChat(broToRemove);
    //     storage.deleteChat(broToRemove).then((value) {
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
    // Navigator.of(context).pop();
  }

  blockTheBro(bool blocked) {
    // blockBro.blockBro("settings.getToken()", chat.id, blocked).then((val) {
    //   if (val is BroBros) {
    //     setState(() {
    //       this.chat = val;
    //       storage.updateChat(this.chat).then((value) {
    //         setState(() {});
    //       });
    //     });
    //   } else {
    //     if (val == "an unknown error has occurred") {
    //       showToastMessage("An unknown error has occurred");
    //     } else {
    //       showToastMessage("There was an error with the server, we apologize for the inconvenience.");
    //     }
    //   }
    // });
    // Navigator.of(context).pop();
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  Widget broupNameWidget() {
    return Column(
      children: [
        chat.alias.isNotEmpty
            ? Column(children: [
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
        ])
            : Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${chat.broupName}",
              style:
              TextStyle(color: Colors.white, fontSize: 25),
            )),
        SizedBox(height: 20),
      ],
    );
  }

  Widget blockedWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Text(
          "You've blocked this Bro!",
          style:
          TextStyle(color: Colors.grey, fontSize: 16),
        ));
  }

  Widget aliasInputField() {
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

  Widget colorInputField() {
    return Column(
      children: [
        InkWell(
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
        changeColour
            ? Column(children: [
          CircleColorPicker(
            controller: circleColorPickerController,
            textStyle: simpleTextStyle(),
            onChanged: (colour) {
              setState(() => onColorChange(colour));
            },
          ),
          IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.check,
                  color: Colors.green),
              onPressed: () {
                saveColour();
              }),
        ])
            : Container(),
      ],
    );
  }

  Widget descriptionInputField() {
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

  Widget muteInputField() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
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
                  chat.isMuted()
                      ? Icons.volume_up
                      : Icons.volume_mute,
                  color: chat.isMuted()
                      ? Colors.grey
                      : Colors.red),
              SizedBox(width: 20),
              chat.isMuted()
                  ? Text(
                'Unmute Chat',
                style: simpleTextStyle(),
              )
                  : Text(
                'Mute Chat',
                style: simpleTextStyle(),
              ),
            ]
        )
    );
  }

  Widget blockInputField() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          showDialogBlock(
              context, chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Block',
                style: simpleTextStyle(),
              ),
            ]
        )
    );
  }

  Widget chatDetails() {
    return Container(
        child: Column(children: [
          aliasInputField(),
          SizedBox(height: 20),
          colorInputField(),
          SizedBox(height: 20),
          descriptionInputField(),
          SizedBox(height: 30),
          muteInputField(),
          blockInputField(),
        ]
        )
    );
  }

  Widget unblockInputField() {
    return Container(
      child: Column(children: [
        SizedBox(height: 20),
        TextButton(
            style: ButtonStyle(
              foregroundColor:
              WidgetStateProperty.all<Color>(
                  Colors.red),
            ),
            onPressed: () {
              showDialogUnBlockChat(context);
            },
            child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Colors.grey),
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
    );
  }

  Widget deleteBroInputField() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () {
          showDialogRemove(context, chat.getBroupNameOrAlias());
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
    );
  }

  Widget reportBroInputField() {
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
                'Report Bro',
                style: simpleTextStyle(),
              ),
            ]
        )
    );
  }

  Widget clearMessageInputField() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () {
          showDialogClearMessages(context, chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.layers_clear, color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Clear Messages',
                style: simpleTextStyle(),
              ),
            ]
        )
    );
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
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                            "assets/images/brocast_transparent.png")),
                    broupNameWidget(),
                    chat.isBlocked()
                        ? blockedWidget()
                        : chatDetails(),
                    chat.isBlocked()
                        ? unblockInputField() : Container(),
                    deleteBroInputField(),
                    reportBroInputField(),
                    clearMessageInputField(),
                    SizedBox(height: 100)
                  ],
                ),
              ),
            ),
          ]),
        )
    );
  }

  showDialogBlock(BuildContext context, String chatName) {
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

  showDialogRemove(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Remove Bro $chatName!"),
          content: new Text(
              "Are you sure you want to delete this chat? This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore."),
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

  showDialogReport(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Report bro $chatName!"),
          content: new Text(
              "Are you sure you want to report this bro? The most recent messages from this bro to you will be forwarded to Zwaar developers to assess possible deletion of the bro's account. This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore. This former bro will not be notified of the report."),
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

  clearMessagesBroup() {
    Storage().deleteChat(chat.broupId).then((value) {
      setState(() {
        chat.messages = [];
      });
      showToastMessage("All messages are deleted");
      Navigator.of(context).pop();
    });
  }

  showDialogClearMessages(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Clear messages broup $chatName!"),
          content: new Text(
              "Are you sure you want to clear the messages of this bro?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Clear Messages"),
              onPressed: () {
                clearMessagesBroup();
              },
            ),
          ],
        );
      },
    );
  }

  showDialogUnMuteChat(BuildContext context) {
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

  showDialogUnBlockChat(BuildContext context) {
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

  showDialogMuteChat(BuildContext context) {
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
                  muteTheChat(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  unmuteTheChat() {
    // socketServices.socket.emit("message_event_change_chat_mute", {
    //   "token": "settings.getToken()",
    //   "bros_bro_id": chat.id,
    //   // "bro_id": settings.getBroId(),
    //   "bro_id": 0,
    //   "mute": -1
    // });
    // Navigator.of(context).pop();
  }

  void muteTheChat(int selectedRadio) {
    // socketServices.socket.emit("message_event_change_chat_mute", {
    //   "token": "settings.getToken()",
    //   "bros_bro_id": chat.id,
    //   // "bro_id": settings.getBroId(),
    //   "bro_id": 0,
    //   "mute": selectedRadio
    // });
    // Navigator.of(context).pop();
  }
}
