import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";

import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';

class BroChatDetails extends StatefulWidget {

  final BroBros broBros;

  BroChatDetails({ Key key, this.broBros }): super(key: key);

  @override
  _BroChatDetailsState createState() => _BroChatDetailsState();
}

class _BroChatDetailsState extends State<BroChatDetails> {

  TextEditingController chatDescriptionController = new TextEditingController();

  bool changeDescription = false;

  FocusNode focusNodeDescription = new FocusNode();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(broBros: widget.broBros,)
    ));
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void goToDifferentChat(BroBros chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(broBros: chatBro)
    ));
  }

  Widget appBarChatDetails() {
    return AppBar(
        title: Container(
            alignment: Alignment.centerLeft,
            child: Text("Chat details ${widget.broBros.chatName}")
        ),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelectChat(context, item),
              itemBuilder: (context) =>
              [
                PopupMenuItem<int>(
                    value: 0,
                    child: Text("Profile")
                ),
                PopupMenuItem<int>(
                    value: 1,
                    child: Text("Settings")
                ),
                PopupMenuItem<int>(
                    value: 2,
                    child: Text("Back to chat")
                ),
              ])
        ]
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch(item) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroProfile()
        ));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroSettings()
        ));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroMessaging(broBros: widget.broBros)
        ));
        break;
    }
  }

  void onTapDescriptionField() {
    focusNodeDescription.requestFocus();
    setState(() {
      changeDescription = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarChatDetails(),
        body: Container(
          child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                        children:
                        [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              alignment: Alignment.center,
                              child: Image.asset("assets/images/brocast.png")
                          ),
                          Container(
                              alignment: Alignment.center,
                              child: Text(
                                "${widget.broBros.chatName}",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25
                                ),
                              )
                          ),
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
                              decoration: textFieldInputDecoration("No chat description yet"),
                            ),
                          ),
                          SizedBox(height: 20),
                          changeDescription ? TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () {
                              // onSavePassword();
                            },
                            child: Text('Save description'),
                          ) : TextButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () {
                              onTapDescriptionField();
                            },
                            child: Text('Update description'),
                          ),
                        ]
                    ),
                  ),
                ),
              ]
          ),
        )
    );
  }
}

