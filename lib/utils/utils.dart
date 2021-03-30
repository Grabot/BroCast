import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
  title: Container(
  alignment: Alignment.center,
      child: Image.asset("assets/images/brocast_transparent.png", height: 60)
  )
  );
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
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.BOTTOM,
    );
  }
}

class HelperFunction {
  static String broTokenKey = "userToken";
  static String broNameKey = "broName";

  static Future<bool> setBroToken(String broToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broTokenKey, broToken);
  }

  static Future<bool> setBroName(String broName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broNameKey, broName);
  }

  static Future<String> getBroToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broTokenKey);
  }

  static Future<String> getBroName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broNameKey);
  }
}