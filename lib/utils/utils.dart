import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/views/bro_profile.dart';
import 'package:brocast/views/bro_settings.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

Widget appBarMain(BuildContext context, bool showPopup, String title) {
  return AppBar(
    title: Container(
    alignment: Alignment.centerLeft,
        child: Text(title)
    ),
    actions: showPopup ? [
      PopupMenuButton<int>(
        onSelected: (item) => onSelect(context, item),
        itemBuilder: (context) => [
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

void onSelect(BuildContext context, int item) {
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
      HelperFunction.logOutBro().then((value) {
        ResetRegistration resetRegistration = new ResetRegistration();
        resetRegistration.removeRegistrationId(Settings.instance.getBroId());
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => SignIn()
        ));
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

Color getTextColor(Color color) {
  double luminance =
      (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

  // If the color is very bright we make the text colour black.
  // We set the limit high because we want it to be white mostly
  if (luminance > 0.90) {
    return Colors.black;
  } else {
    return Colors.white;
  }

}