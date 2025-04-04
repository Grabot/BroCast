import 'dart:math';
import 'dart:typed_data';

import 'package:brocast/services/auth/auth_service_login.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oktoast/oktoast.dart';

import '../objects/bro.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../objects/message.dart';
import '../services/auth/models/login_response.dart';
import '../views/bro_home/bro_home.dart';
import '../views/bro_profile/bro_profile.dart';
import '../views/bro_settings/bro_settings.dart';
import '../views/chat_view/chat_messaging.dart';
import '../views/chat_view/messaging_change_notifier.dart';
import 'secure_storage.dart';
import 'settings.dart';
import 'socket_services.dart';


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
  // TODO: add duration paramater?
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
      (0.299 * (color.r * 255) + 0.587 * (color.g * 255) + 0.114 * (color.b * 255)) / 255;

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

loginWithActiveSession(Me newMe, Me settingsMe) {
  // We want to update the active session with new data.
  // This can occur if the app is minimized and later reopened.
  if (newMe.broups.isNotEmpty) {
    for (Broup newMeBroup in newMe.broups) {
      bool found = false;
      if (settingsMe.broups.isNotEmpty) {
        for (Broup settingsMeBroup in settingsMe.broups) {
          if (settingsMeBroup.broupId == newMeBroup.broupId) {
            // If the broup was send with the login we want to update it.
            // In this case we don't add the db broup data yet
            // because it will be added in the BroHome notifier.
            found = true;
            if (newMeBroup.updateBroup) {
              settingsMeBroup.updateBroupDataServer(newMeBroup);
            } else if (newMeBroup.newMessages) {
              settingsMeBroup.newMessages = true;
              settingsMeBroup.unreadMessages = newMeBroup.unreadMessages;
              settingsMeBroup.dateTilesAdded = false;
              if (settingsMeBroup.messages.isNotEmpty) {
                settingsMeBroup.messages.removeWhere((element) => element.messageId == 0);
              }
            }
            break;
          }
        }
      }
      if (!found) {
        // This is a new broup, add it to existing session.
        settingsMe.broups.add(newMeBroup);
      }
    }
  }
}

setBroupsAfterLogin(Me settingsMe, List<int>? broupIds) {
  Storage storage = Storage();
  storage.fetchAllBroups().then((dbBroups) {
    storage.fetchAllBros().then((brosDB) {
      List<int> remainingBroupIds = [];

      Map<String, Broup> broupDbMap = {for (var broup in dbBroups) broup.getBroupId().toString(): broup};

      if (broupIds != null) {
        List<int> dbBroupIdsList = dbBroups.map((broup) => broup.getBroupId()).toList();
        remainingBroupIds = broupIds.where((id) => !dbBroupIdsList.contains(id)).toList();
        print("remainingBroupIds: $remainingBroupIds");
      }

      List<int> broupsToUpdate = [];
      List<int> broupAvatarsToUpdate = [];
      List<int> brosToUpdate = [];
      List<int> broAvatarsToUpdate = [];
      print("db Broups: ${broupDbMap}");
      if (settingsMe.broups.isNotEmpty) {
        for (Broup broupMe in settingsMe.broups) {
          Broup? dbBroup = broupDbMap[broupMe.getBroupId().toString()];
          if (dbBroup == null) {
            // This is a new broup
            print("This is a new broup");
            addWelcomeMessage(broupMe);

            // For new broups we will check what data we might need to get from the server
            if (broupMe.private) {
              int otherBroId = broupMe.getBroIds().firstWhere(
                    (broId) => broId != settingsMe.getId(),
              );
              print("new broup updating bros $otherBroId");
              broAvatarsToUpdate.add(otherBroId);
            } else {
              // A large broup, update with the bros that are not in the local db.
              // But no need to retrieve them yet, not until the bro opens the broup
              List<int> brosToUpdateBroup = [...broupMe.getBroIds()];
              List<int> brosAvatarToUpdateBroup = [...broupMe.getBroIds()];
              for (Broup broupMe2 in settingsMe.broups) {
                if (broupMe2.private) {
                  for (int broBroupMeId in broupMe2.broIds) {
                    if (broBroupMeId != settingsMe.getId()) {
                      // If the broId is a private chat of this bro than we know that that bro is up to date
                      if (brosToUpdateBroup.contains(broBroupMeId)) {
                        brosToUpdateBroup.remove(broBroupMeId);
                      }
                      if (brosAvatarToUpdateBroup.contains(broBroupMeId)) {
                        brosAvatarToUpdateBroup.remove(broBroupMeId);
                      }
                    }
                  }
                }
              }
              print("new broup updating bros $brosToUpdateBroup");
              if (brosToUpdateBroup.isNotEmpty) {
                broupMe.updateBroIds = brosToUpdateBroup;
                broupMe.updateBroAvatarIds = brosAvatarToUpdateBroup;
                print("added broup updating bros $brosToUpdateBroup");
              }
              broupAvatarsToUpdate.add(broupMe.broupId);
            }
            // No need to `checkBroupReceived` here, because we are adding a new broup
            storage.addBroup(broupMe);
          } else {
            if (broupMe.broupId == dbBroup.broupId) {
              // If the broup was send with the login we want to update it.
              // In this case we don't add the db broup data yet
              // because it will be added in the BroHome notifier.
              broupMe.updateBroupLocalDB(dbBroup);
              if (broupMe.private) {
                // In a private broup we want to update it immediately.
                if (broupMe.newUpdateBroIds.isNotEmpty) {
                  for (int broId in broupMe.newUpdateBroIds) {
                    if (settingsMe.getId() != broId) {
                      print("adding bro to update! $broId");
                      brosToUpdate.add(broId);
                    }
                  }
                }
                print("private chat new avatar?");
                if (broupMe.newAvatar) {
                  print("yes!");
                  for (int broId in broupMe.broIds) {
                    if (settingsMe.getId() != broId) {
                      broAvatarsToUpdate.add(broId);
                    }
                  }
                }
                if (broupMe.updateBroup) {
                   // TODO: In private broups this is only the broup colour? Isn't this already send if available?
                  // broupsToUpdate.add(broupMe.broupId);
                }
              } else {
                if (broupMe.newUpdateBroIds.isNotEmpty ||
                    broupMe.newUpdateBroAvatarIds.isNotEmpty) {
                  broupMe.newUpdateBroIds = [];
                  broupMe.newUpdateBroAvatarIds = [];
                }
                if (broupMe.updateBroup) {
                  broupsToUpdate.add(broupMe.broupId);
                }
                if (broupMe.newAvatar) {
                  broupAvatarsToUpdate.add(broupMe.broupId);
                }
              }
              // We remove the broup from the db map so we can check which broups are not in the settingsMe.
              broupDbMap.remove(broupMe.broupId.toString());
            }
            storage.updateBroup(broupMe);
          }
        }
      }
      // Add all the unchanged broups from the db.
      if (broupDbMap.isNotEmpty) {
        for (Broup broupDb in broupDbMap.values) {
          settingsMe.broups.add(broupDb);
        }
      }
      print("broIdsToUpdate: $brosToUpdate");
      if (brosToUpdate.isNotEmpty || broAvatarsToUpdate.isNotEmpty) {
        AuthServiceSocial().broDetails(brosToUpdate, broAvatarsToUpdate, null);
      }
      if (broupsToUpdate.isNotEmpty || broupAvatarsToUpdate.isNotEmpty) {
        AuthServiceSocial().broupDetails(broupsToUpdate, broupAvatarsToUpdate);
      }

      // This will be the case when someone logs in on a new phone for instance.
      if (remainingBroupIds.isNotEmpty) {
        AuthServiceSocial().broupDetails(remainingBroupIds, remainingBroupIds);
      }
    });
  });
}

updateMeAfterLogin(Me settingsMe, SecureStorage secureStorage) {
  Storage().fetchBro(settingsMe.id).then((dbBro) {
    if (dbBro != null) {
      // We take most of the data from the db, since we won't send this with the login.
      settingsMe.id = dbBro.id;
      settingsMe.broName = dbBro.broName;
      settingsMe.bromotion = dbBro.bromotion;

      // Set the avatar, unless it's not there. Then retrieve it.
      if (dbBro.avatar != null) {
        settingsMe.avatar = dbBro.avatar;
      } else {
        retrieveAvatar(settingsMe);
      }

      // We don't store the `avatarDefault` in the local db. We keep track of this using app storage.
      secureStorage.getAvatarDefault().then((avatarDefault) {
        bool avatarDefaultBool = true;
        if (avatarDefault != null) {
          int avatarDefaultInt = int.parse(avatarDefault);
          avatarDefaultBool = avatarDefaultInt == 1;
        }
        settingsMe.setAvatarDefault(avatarDefaultBool);
      });
    } else {
      // Not stored yet, likely because the user is new.
      // Store what is know in the database
      Storage().addBro(settingsMe);
      // If the avatar is not known we should retrieve it.
      if (settingsMe.getAvatar() == null) {
        retrieveAvatar(settingsMe);
      }
    }
  });
  SocketServices().joinRoomSolo(settingsMe.getId());

  // We will set a check for midnight here.
  // At midnight we will alter any existing date time tiles.
  // Today will be yesterday and yesterday will the the date formatting.
  // If the app is not open any date tiles are removed and re-added on opening
  DateTime now = DateTime.now();
  DateTime midnight = DateTime(now.year, now.month, now.day+1);
  Duration timeUntilMidnight = midnight.difference(now);
  Future.delayed(timeUntilMidnight, () {
    alterDateTimeTiles(settingsMe);
  });
}

Future<bool> checkSameBroLogin(SecureStorage secureStorage, Me? newMe) async {
  String? broIdString = await secureStorage.getBroId();
  int broIdInt = -1;
  if (broIdString != null) {
    broIdInt = int.parse(broIdString);
  }
  if (broIdInt != -1) {
    print("broIdInt: $broIdInt");
    // check the broIdInt with the broId from the login response
    if (newMe != null) {
      int newMeId = newMe.getId();
      if (broIdInt != newMeId) {
        print("broIdInt != newMeId $newMeId");
        await secureStorage.logout();
        Settings().logout();
        await Storage().clearDatabase();
        secureStorage.setBroId(newMe.getId().toString());
      } else {
        print("same client login!");
        return true;
      }
    }
  } else {
    // This has to be a new client with a new login.
    if (newMe != null) {
      print("new client login");
      secureStorage.setBroId(newMe.getId().toString());
      return true;
    }
  }
  return false;
}

// Similar to the token login except with some extra checks
successfulLoginLogin(LoginResponse loginResponse) async {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();

  Me? newMe = loginResponse.getMe();

  bool broLogin = await checkSameBroLogin(secureStorage, newMe);
  if (!broLogin) {
    print("something huge went wrong?");
  }

  // Via this login there is probably no active session, but we will check it.
  Me? settingsMe = settings.getMe();
  if (settingsMe != null && newMe != null) {
    loginWithActiveSession(newMe, settingsMe);
  }

  // We have updated the `me` on the settings object, but with a new login we
  // probably won't have an settingsMe so we will set the newMe as the settingsMe.
  if (settingsMe == null) {
    if (newMe != null) {
      settingsMe = newMe;
      settings.setMe(settingsMe);
    }
  }
  // The `newMe` should always be available in a successful login so
  // here the `settingsMe` should always be available.
  if (settingsMe != null) {
    // Also retrieve the broups that are in the local db.
    // We want to update the `settingsMe` with the local db data.
    setBroupsAfterLogin(settingsMe, loginResponse.broupIds);

    // We will retrieve the data of the bro that logged in
    // If there is nothing we add it, if there is some data we update it.
    updateMeAfterLogin(settingsMe, secureStorage);
  }

  String? accessToken = loginResponse.getAccessToken();
  if (accessToken != null) {
    // the access token will be set in memory and local storage.
    int accessExpiration = Jwt.parseJwt(accessToken)['exp'];
    settings.setAccessToken(accessToken);
    settings.setAccessTokenExpiration(accessExpiration);
    await secureStorage.setAccessToken(accessToken);
    await secureStorage.setAccessTokenExpiration(accessExpiration);
  }

  String? refreshToken = loginResponse.getRefreshToken();
  if (refreshToken != null) {
    // the refresh token will only be set in memory.
    int refreshExpiration = Jwt.parseJwt(refreshToken)['exp'];
    settings.setRefreshToken(refreshToken);
    settings.setRefreshTokenExpiration(refreshExpiration);
    await secureStorage.setRefreshToken(refreshToken);
    await secureStorage.setRefreshTokenExpiration(refreshExpiration);
  }

  settings.setLoggingIn(false);
  BroHomeChangeNotifier().notify();
}

successfulLoginToken(LoginResponse loginResponse) async {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();

  // It's possible that there is already a 'me' on the settings. Like when the app was just minimized or something
  // In this case we want to keep most of the settingsMe broup objects and update them with the newMe broup objects.
  Me? settingsMe = settings.getMe();
  Me? newMe = loginResponse.getMe();
  if (settingsMe != null && newMe != null) {
    loginWithActiveSession(newMe, settingsMe);
  }
  // We have updated the `me` on the settings object, but with a new login we
  // probably won't have an settingsMe so we will set the newMe as the settingsMe.
  if (settingsMe == null) {
    if (newMe != null) {
      settingsMe = newMe;
      settings.setMe(settingsMe);
    }
  }
  // The `newMe` should always be available in a successful login so
  // here the `settingsMe` should always be available.
  if (settingsMe != null) {
    // Also retrieve the broups that are in the local db.
    // We want to update the `settingsMe` with the local db data.
    setBroupsAfterLogin(settingsMe, null);

    // We will retrieve the data of the bro that logged in
    // If there is nothing we add it, if there is some data we update it.
    updateMeAfterLogin(settingsMe, secureStorage);
  }

  String? accessToken = loginResponse.getAccessToken();
  if (accessToken != null) {
    // the access token will be set in memory and local storage.
    int accessExpiration = Jwt.parseJwt(accessToken)['exp'];
    settings.setAccessToken(accessToken);
    settings.setAccessTokenExpiration(accessExpiration);
    await secureStorage.setAccessToken(accessToken);
    await secureStorage.setAccessTokenExpiration(accessExpiration);
  }

  String? refreshToken = loginResponse.getRefreshToken();
  if (refreshToken != null) {
    // the refresh token will only be set in memory.
    int refreshExpiration = Jwt.parseJwt(refreshToken)['exp'];
    settings.setRefreshToken(refreshToken);
    settings.setRefreshTokenExpiration(refreshExpiration);
    await secureStorage.setRefreshToken(refreshToken);
    await secureStorage.setRefreshTokenExpiration(refreshExpiration);
  }

  settings.setLoggingIn(false);
  BroHomeChangeNotifier().notify();
}

alterDateTimeTiles(Me? me) {
  if (me != null) {
    for (Broup meBroup in me!.broups) {
      for (Message broupMessage in meBroup.messages) {
        if (broupMessage.isInformation()) {
          if (broupMessage.body == "Today") {
            broupMessage.body = "Yesterday";
          } else if (broupMessage.body == "Yesterday") {
            DateTime dayMessage = DateTime(broupMessage.getTimeStamp().year,
                broupMessage.getTimeStamp().month, broupMessage.getTimeStamp().day);
            String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);
            broupMessage.body = chatTimeTile;
          }
        }
      }
    }
  }
  // Restart the check in case the app is open for more than a day
  DateTime now = DateTime.now();
  DateTime midnight = DateTime(now.year, now.month, now.day+1);
  Duration timeUntilMidnight = midnight.difference(now);
  Future.delayed(timeUntilMidnight, () {
    alterDateTimeTiles(me);
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
  print("we are now going to home");
  MessagingChangeNotifier().setBroupId(-1);
  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => BrocastHome(key: UniqueKey())));
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

addWelcomeMessage(Broup broup) {
  DateTime now = DateTime.now();
  DateTime currentDayMessage = DateTime(now.year, now.month, now.day);
  Message unBlockMessage = Message(
    broup.lastMessageId + 1,
    0,
    "Welcome to the Chat! 🥰",
    "",
    currentDayMessage.toUtc().toString(),
    null,
    true,
    broup.getBroupId(),
  );
  broup.lastMessageId += 1;
  Storage().addMessage(unBlockMessage);
  broup.messages.insert(
      0,
      unBlockMessage);
}

getBroupData(Storage storage, Me me) {
  int startTime = DateTime.now().millisecondsSinceEpoch;
  storage.fetchAllBroups().then((broups) {
    storage.fetchAllBros().then((bros) {
      Map<String, Broup> broupMap = {for (var broup in broups) broup.getBroupId().toString(): broup};
      Map<String, Bro> broMap = {for (var bro in bros) bro.getId().toString(): bro};
      print("broups: ${broupMap}");
      print("bros: ${broMap}");
      for (Broup broup in me.broups) {
        Broup? dbBroup = broupMap[broup.getBroupId().toString()];
        if (dbBroup == null) {
          // TODO: New broup found here? Is this possible?
        } else {
          if (broup.avatar != dbBroup.avatar) {
            broup.avatar = dbBroup.avatar;
            broup.avatarDefault = dbBroup.avatarDefault;
          }
          for (int broId in broup.broIds) {
            Bro? dbBro = broMap[broId.toString()];
            if (dbBro != null) {
              broup.addBro(dbBro);
            }
          }
        }
      }
      int endTime = DateTime.now().millisecondsSinceEpoch;
      int totalTime = endTime - startTime;
      print("total time for getting data: $totalTime");
      BroHomeChangeNotifier().notify();
    });
  });
}
