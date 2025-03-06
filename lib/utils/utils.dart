import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:brocast/services/auth/auth_service_login.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oktoast/oktoast.dart';

import '../objects/broup.dart';
import '../objects/me.dart';
import '../services/auth/auth_service_social.dart';
import '../services/auth/models/login_response.dart';
import '../views/bro_home/bro_home.dart';
import '../views/bro_profile/bro_profile.dart';
import '../views/bro_settings/bro_settings.dart';
import '../views/chat_view/chat_messaging.dart';
import '../views/chat_view/messaging_change_notifier.dart';
import 'settings.dart';
import 'socket_services.dart';
import 'secure_storage.dart';
import 'package:brocast/constants/route_paths.dart' as routes;


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
  return TextStyle(color: Colors.white, fontSize: 18);
}

showToastMessage(String message) {
  showToast(
    message,
    duration: const Duration(milliseconds: 2000),
    position: ToastPosition.top,
    backgroundColor: Colors.white,
    radius: 1.0,
    textStyle: const TextStyle(fontSize: 30.0, color: Colors.black),
  );
}

Color getTextColor(Color? color) {
  if (color == null) {
    return Colors.white;
  }

  double luminance =
      (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;

  // If the color is very bright we make the text colour black.
  // We set the limit high because we want it to be white mostly
  if (luminance > 0.70) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

bool emailValid(String possibleEmail) {
  return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(possibleEmail);
}

successfulLogin(LoginResponse loginResponse) async {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();

  Me? me = loginResponse.getMe();
  if (me != null) {
    settings.setMe(me);
    // don't store email because we don't know it.
    SocketServices().joinRoomSolo(me.getId());
  }

  String? accessToken = loginResponse.getAccessToken();
  if (accessToken != null) {
    // the access token will be set in memory and local storage.
    settings.setAccessToken(accessToken);
    settings.setAccessTokenExpiration(Jwt.parseJwt(accessToken)['exp']);
    await secureStorage.setAccessToken(accessToken);
  }

  String? refreshToken = loginResponse.getRefreshToken();
  if (refreshToken != null) {
    // the refresh token will only be set in memory.
    settings.setRefreshToken(refreshToken);
    settings.setRefreshTokenExpiration(Jwt.parseJwt(refreshToken)['exp']);
    await secureStorage.setRefreshToken(refreshToken);
  }

  settings.setLoggingIn(false);
  BroHomeChangeNotifier().notify();

  // Fetch the Bro object which matches the Me object.
  // This should hold extra information about the user.
  // Like the avatar, which we don't send with login response.
  Storage().fetchBro(me!.getId()).then((bro) {
    // We also check the local storage for the avatar.
    secureStorage.getAvatarDefault().then((avatarDefault) {
      bool avatarDefaultBool = true;
      if (avatarDefault != null) {
        int avatarDefaultInt = int.parse(avatarDefault);
        avatarDefaultBool = avatarDefaultInt == 1;
      }
      me.setAvatarDefault(avatarDefaultBool);
      if (bro != null) {
        if (bro.getAvatar() != null) {
          me.setAvatar(bro.getAvatar()!);
          Storage().updateBro(me);
          BroHomeChangeNotifier().notify();
        } else {
          retrieveAvatar(me);
        }
      } else {
        // Not stored yet, likely because the user is new.
        // Store what is know in the database
        Storage().addBro(me);
        // If the avatar is not known we should retrieve it.
        if (me.getAvatar() == null) {
          retrieveAvatar(me);
        }
      }
    });
  });
}

retrieveAvatar(Me me) {
  // If the user has just registered it will receive a notice when the
  // avatar is created and it will retrieve it via that path.
  // So we will give it a little time to be created before we retrieve it.
  print("going to retrieve avatar");
  Future.delayed(Duration(seconds: 2), () {
    if (me.getAvatar() == null) {
      print("going to retrieve avatar for real");
      AuthServiceLogin().getAvatarMe().then((avatarValue) {
        if (avatarValue) {
          BroHomeChangeNotifier().notify();
        }
      });
    }
  });
}

Widget zwaarDevelopersLogo(double width, bool normalMode) {
  return Container(
      width: width,
      alignment: Alignment.center,
      child: Image.asset("assets/images/Zwaar_Logo.png")
  );
}

Widget getAvatar(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  if (avatar != null) {
    return Image.memory(
      avatar,
      width: avatarBoxWidth * 0.785,  // some scale that I determined by trial and error
      height: avatarBoxHeight * 0.785,  // some scale that I determined by trial and error
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      "assets/images/default_avatar.png",
      width: avatarBoxWidth,
      height: avatarBoxHeight,
      gaplessPlayback: true,
      fit: BoxFit.cover,
    );
  }
}

Widget avatarBox(double avatarBoxWidth, double avatarBoxHeight, Uint8List? avatar) {
  return Stack(
    children: [
      SizedBox(
        width: avatarBoxWidth,
        height: avatarBoxHeight,
        child: Center(
            child: ClipPath(
                clipper: HexagonClipper(),
                child: getAvatar(avatarBoxWidth, avatarBoxHeight, avatar)
            )
        ),
      ),
    ],
  );
}
class HexagonClipper extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    final path = Path();
    List point1 = getPointyHexCorner(size, 0);
    List point2 = getPointyHexCorner(size, 1);
    List point3 = getPointyHexCorner(size, 2);
    List point4 = getPointyHexCorner(size, 3);
    List point5 = getPointyHexCorner(size, 4);
    List point6 = getPointyHexCorner(size, 5);

    point2[1] = size.height;
    point3[1] = size.height;
    point5[1] = 0.0;
    point6[1] = 0.0;

    path.moveTo(point1[0], point1[1]);
    path.lineTo(point2[0], point2[1]);
    path.lineTo(point3[0], point3[1]);
    path.lineTo(point4[0], point4[1]);
    path.lineTo(point5[0], point5[1]);
    path.lineTo(point6[0], point6[1]);
    path.close();
    return path;
  }

  List getPointyHexCorner(Size size, double i) {
    double angleDeg = 60 * i;

    double angleRad = pi/180 * angleDeg;
    double pointX = (size.width/2 * cos(angleRad)) + size.width/2;
    double pointY = (size.height/2 * sin(angleRad)) + size.height/2;
    return [pointX, pointY];
  }

  @override
  bool shouldReclip(HexagonClipper oldClipper) => false;
}

navigateToHome(BuildContext context, Settings settings) {
  MessagingChangeNotifier().setBroupId(-1);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
}

navigateToChat(BuildContext context, Settings settings, Broup chat) {
  MessagingChangeNotifier().setBroupId(chat.broupId);

  Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatMessaging(
        key: UniqueKey(),
        chat: chat
      )
    ),
  );
}

navigateToProfile(BuildContext context, Settings settings) {
  MessagingChangeNotifier().setBroupId(-1);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => BroProfile(key: UniqueKey())));
}

navigateToSettings(BuildContext context, Settings settings) {
  MessagingChangeNotifier().setBroupId(-1);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => BroSettings(key: UniqueKey())));
}

ButtonStyle buttonStyle(bool active, MaterialColor buttonColor) {
  return ButtonStyle(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return buttonColor.shade600;
          }
          if (states.contains(WidgetState.pressed)) {
            return buttonColor.shade300;
          }
          return null;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            return active? buttonColor.shade800 : buttonColor;
          }),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          )
      )
  );
}
