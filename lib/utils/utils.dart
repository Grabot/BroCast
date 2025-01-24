import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      ));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}

class ShowToastComponent {
  static showDialog(String msg, context) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        textColor: Colors.black,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.grey,
        fontSize: 12.0
    );
  }
}

Color getTextColor(Color color) {
  if (color == null) {
    return Colors.white;
  }

  double luminance =
      (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  // If the color is very bright we make the text colour black.
  // We set the limit high because we want it to be white mostly
  if (luminance > 0.70) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}
