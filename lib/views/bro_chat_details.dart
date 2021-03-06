import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';

class BroChatDetails extends StatefulWidget {
  final BroBros broBros;

  BroChatDetails({Key key, this.broBros}) : super(key: key);

  @override
  _BroChatDetailsState createState() => _BroChatDetailsState();
}

class _BroChatDetailsState extends State<BroChatDetails>
    with WidgetsBindingObserver {
  TextEditingController chatDescriptionController = new TextEditingController();

  bool changeDescription = false;
  bool changeColour = false;
  bool showNotification = true;

  CircleColorPickerController circleColorPickerController;

  Color currentColor;
  Color previousColor;

  FocusNode focusNodeDescription = new FocusNode();

  String previousDescription = "";

  BroBros chat;

  @override
  void initState() {
    super.initState();
    chat = widget.broBros;
    BackButtonInterceptor.add(myInterceptor);
    chatDescriptionController.text = chat.chatDescription;

    initSockets();
    NotificationService.instance.setScreen(this);

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.broColor,
    );
    currentColor = chat.broColor;
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
        .on('message_event_change_chat_details_success', (data) {
      chatDetailUpdateSuccess();
    });
    SocketServices.instance.socket
        .on('message_event_change_chat_details_failed', (data) {
      chatDetailUpdateFailed();
    });
    SocketServices.instance.socket
        .on('message_event_change_chat_colour_success', (data) {
      chatColourUpdateSuccess();
    });
    SocketServices.instance.socket.on('message_event_change_chat_colour_failed',
        (data) {
      chatColourUpdateFailed();
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
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => BroMessaging(broBros: chat)));
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
              builder: (context) => BroMessaging(broBros: chatBro)));
    }
  }

  Widget appBarChatDetails() {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: getTextColor(chat.broColor)),
            onPressed: () {
              backButtonFunctionality();
            }),
        backgroundColor:
            chat.broColor != null ? chat.broColor : Color(0xff145C9E),
        title: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Chat details ${chat.chatName}",
              style:
                  TextStyle(color: getTextColor(chat.broColor), fontSize: 20),
            )),
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
                builder: (context) => BroMessaging(broBros: chat)));
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
        changeDescription = false;
      });
    } else {
      setState(() {
        changeDescription = false;
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
    if (currentColor != chat.broColor) {
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

  void chatDetailUpdateSuccess() {
    previousDescription = chatDescriptionController.text;
    chat.chatDescription = chatDescriptionController.text;
    if (mounted) {
      setState(() {});
    }
  }

  void chatDetailUpdateFailed() {
    currentColor = previousColor;
    circleColorPickerController.color = previousColor;
    ShowToastComponent.showDialog("Updating the bro chat has failed", context);
  }

  void chatColourUpdateSuccess() {
    chat.broColor = currentColor;
    previousColor = currentColor;
    if (mounted) {
      setState(() {});
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
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        "${chat.chatName}",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      )),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      focusNode: focusNodeDescription,
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
                  SizedBox(height: 20),
                  changeDescription
                      ? TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () {
                            updateDescription();
                          },
                          child: Text('Save description'),
                        )
                      : TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            onTapDescriptionField();
                          },
                          child: Text('Update description'),
                        ),
                  Row(
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
                            color: widget.broBros.broColor,
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ],
                  ),
                  changeColour
                      ? CircleColorPicker(
                          controller: circleColorPickerController,
                          textStyle: simpleTextStyle(),
                          onChanged: (colour) {
                            setState(() => onColorChange(colour));
                          },
                        )
                      : Container(),
                  changeColour
                      ? TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                          ),
                          onPressed: () {
                            saveColour();
                          },
                          child: Text('Save color'),
                        )
                      : TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            updateColour();
                          },
                          child: Text('Change color'),
                        ),
                  SizedBox(height: 150),
                ]),
              ),
            ),
          ]),
        ));
  }
}
