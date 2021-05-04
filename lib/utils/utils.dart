import 'package:brocast/utils/shared.dart';
import 'package:brocast/views/bro_profile.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

Widget appBarMain(BuildContext context, var socket) {
  return AppBar(
    title: Container(
    alignment: Alignment.centerLeft,
        child: Text("BroCast")
    ),
    actions: socket != null ? [
      PopupMenuButton<int>(
        onSelected: (item) => onSelect(context, item, socket),
        itemBuilder: (context) => [
          PopupMenuItem<int>(
            value: 0,
            child: Text("Profile")
          ),
          PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Log Out")
              ])
          )
        ]
      )
    ] : [],
  );
}

void onSelect(BuildContext context, int item, var socket) {
  switch(item) {
    case 0:
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => BroProfile(socket: socket)
      ));
      break;
    case 1:
      HelperFunction.logOutBro().then((value) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) =>
                SignIn()
            ), (route) => false
        );
      });
      break;
  }
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.white54,
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      )
  );
}

TextStyle simpleTextStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 16
  );
}

class ShowToastComponent {
  static showDialog(String msg, context) {
    Toast.show(
      msg,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.TOP,
    );
  }
}
