import 'dart:math';
import 'dart:typed_data';

import 'package:brocast/services/auth/v1_4/auth_service_login.dart';
import 'package:brocast/services/auth/v1_4/auth_service_social.dart';
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
import '../services/auth/v1_5/auth_service_social_v1_5.dart';
import '../views/bro_home/bro_home.dart';
import '../views/bro_profile/bro_profile.dart';
import '../views/bro_settings/bro_settings.dart';
import '../views/chat_view/chat_messaging.dart';
import '../views/chat_view/message_util.dart';
import '../views/chat_view/messaging_change_notifier.dart';
import '../views/sign_in/signin.dart';
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

loginWithActiveSession(Me newMe, Me settingsMe) async {
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
            } else if (newMeBroup.newAvatar) {
              settingsMeBroup.newAvatar = true;
              settingsMeBroup.newMessages = newMeBroup.newMessages;
              settingsMeBroup.unreadMessages = newMeBroup.unreadMessages;
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
        // First update the message Id,
        // since we only want to retrieve messages after the bro is added
        int messageReadId = await AuthServiceSocialV15().updateLocalBroupReadId(newMeBroup.broupId);
        newMeBroup.localLastMessageReadId = messageReadId;
        newMeBroup.lastMessageReadId = messageReadId;
        newMeBroup.lastMessageId = messageReadId;
        settingsMe.broups.add(newMeBroup);
      }
    }
  }
}

immediateBroupRetrieval(Broup broupToBeRetrieved, Me settingsMe) {
  Future.delayed(Duration(milliseconds: 100)).then((value) {
    AuthServiceSocial().retrieveBroup(broupToBeRetrieved.broupId).then((newBroupMe) {
      if (newBroupMe != null) {
        broupToBeRetrieved.addBlockMessage(newBroupMe);
        broupToBeRetrieved.updateBroupDataServer(newBroupMe);
        Storage().updateBroup(broupToBeRetrieved);
        if (broupToBeRetrieved.private) {
          // If it's a private broup we need to retrieve the bro.
          for (int broId in broupToBeRetrieved.broIds) {
            if (broId != settingsMe.getId()) {
              AuthServiceSocial().retrieveBroAvatar(broId).then((bro) {
                if (bro != null) {
                  broupToBeRetrieved.addBro(bro);
                  Storage().addBro(bro);
                  BroHomeChangeNotifier().notify();
                }
              });
            }
          }
        } else {
          // If it's not a private broup we need to retrieve the avatar
          AuthServiceSocial().getAvatarBroup(broupToBeRetrieved.broupId);
        }
      }
    });
  });
}

setBroupsAfterLogin(Me settingsMe, List<int>? broupIds) async {
  Storage storage = Storage();
  storage.fetchAllBroups().then((dbBroups) async {
    storage.fetchAllBros().then((brosDB) async {
      List<int> remainingBroupIds = [];

      Map<String, Broup> broupDbMap = {for (var broup in dbBroups) broup.getBroupId().toString(): broup};

      if (broupIds != null) {
        List<int> dbBroupIdsList = dbBroups.map((broup) => broup.getBroupId()).toList();
        remainingBroupIds = broupIds.where((id) => !dbBroupIdsList.contains(id)).toList();
      }

      List<int> broupsToUpdate = [];
      List<int> broupAvatarsToUpdate = [];
      List<int> brosToUpdate = [];
      List<int> broAvatarsToUpdate = [];
      if (settingsMe.broups.isNotEmpty) {
        for (Broup broupMe in settingsMe.broups) {
          Broup? dbBroup = broupDbMap[broupMe.getBroupId().toString()];

          if (dbBroup == null) {
            // This is a new broup
            addWelcomeMessage(broupMe);

            // For new broups we will check what data we might need to get from the server
            if (broupMe.private) {
              int otherBroId = broupMe.getBroIds().firstWhere(
                    (broId) => broId != settingsMe.getId(),
              );
              if (!broupMe.removed) {
                broAvatarsToUpdate.add(otherBroId);
              }
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
              if (brosToUpdateBroup.isNotEmpty) {
                broupMe.updateBroIds = brosToUpdateBroup;
                broupMe.updateBroAvatarIds = brosAvatarToUpdateBroup;
              }
              if (!broupMe.removed) {
                broupAvatarsToUpdate.add(broupMe.broupId);
              }
            }
            // It's possible that a broup is new but you are also blocked or removed.
            // In this situation we still want to retrieve the broup information, otherwise you will see a bugged out tile.
            // We will check this by checking the broupColour, which can only not be available if this happens.
            if (broupMe.broupColour == "" && broupMe.removed) {
              // New broup, but immediately removed.
              // In this specific case we will just do an immediate call for the broup details.
              // With a slight delay to allow the tokens to be set.
              immediateBroupRetrieval(broupMe, settingsMe);
            }
            // First update the message Id,
            // since we only want to retrieve messages after the bro is added
            int messageReadId = await AuthServiceSocialV15().updateLocalBroupReadId(broupMe.broupId);
            broupMe.localLastMessageReadId = messageReadId;
            broupMe.lastMessageReadId = messageReadId;
            broupMe.lastMessageId = messageReadId;
            // No need to `checkBroupReceived` here, because we are adding a new broup
            storage.addBroup(broupMe);
          } else {
            // If the broup was send with the login we want to update it.
            // In this case we don't add the db broup data yet
            // because it will be added in the BroHome notifier.
            broupMe.updateBroupLocalDB(dbBroup);
            if (broupMe.private) {
              // In a private broup we want to update it immediately.
              if (broupMe.newUpdateBroIds.isNotEmpty) {
                for (int broId in broupMe.newUpdateBroIds) {
                  if (settingsMe.getId() != broId) {
                    if (!broupMe.removed) {
                      brosToUpdate.add(broId);
                    }
                  }
                }
              }
              if (broupMe.newAvatar) {
                for (int broId in broupMe.broIds) {
                  if (settingsMe.getId() != broId) {
                    broAvatarsToUpdate.add(broId);
                  }
                }
              }
            } else {
              if (broupMe.newUpdateBroIds.isNotEmpty ||
                  broupMe.newUpdateBroAvatarIds.isNotEmpty) {
                broupMe.newUpdateBroIds = [];
                broupMe.newUpdateBroAvatarIds = [];
              }
              if (broupMe.updateBroup && !broupMe.removed) {
                broupsToUpdate.add(broupMe.broupId);
              }
              if (broupMe.newAvatar && !broupMe.removed) {
                broupAvatarsToUpdate.add(broupMe.broupId);
              }
            }
            // We remove the broup from the db map so we can check which broups are not in the settingsMe.
            broupDbMap.remove(broupMe.broupId.toString());
            storage.updateBroup(broupMe);
          }
        }
      }
      // Add all the unchanged broups from the db.
      if (broupDbMap.isNotEmpty) {
        for (Broup broupDb in broupDbMap.values) {
          // Quick and dirty check to see if anything went wrong before.
          // If a broup has no colour it needs to gather more data.
          if (broupDb.broupColour == "") {
            immediateBroupRetrieval(broupDb, settingsMe);
          }
          settingsMe.broups.add(broupDb);
        }
      }
      // Gather the remaining data. With a slight delay to allow the tokens to be stored in securestorage.
      if (brosToUpdate.isNotEmpty || broAvatarsToUpdate.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 100)).then((val) async {
          AuthServiceSocial().broDetails(brosToUpdate, broAvatarsToUpdate, null);
        });
      }
      if (broupsToUpdate.isNotEmpty || broupAvatarsToUpdate.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 100)).then((val) async {
          AuthServiceSocial().broupDetails(broupsToUpdate, broupAvatarsToUpdate);
        });
      }

      // This will be the case when someone logs in on a new phone for instance.
      if (remainingBroupIds.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 100)).then((val) async {
          AuthServiceSocial().broupDetails(remainingBroupIds, remainingBroupIds);
        });
      }

      // After this point we have updated the broups on the db and settingsMe.
      // So we can now claim the logging is done.
      // There might still be additional data that is going to be retrieved, but the important data is available
      Settings().setLoggingIn(false);
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
  bool? originLocal = await secureStorage.getOrigin();
  if (newMe != null && newMe.origin != null) {
    if (originLocal == null || originLocal != newMe.origin) {
      await secureStorage.setOrigin(newMe.origin!);
    }
  }
  String? broIdString = await secureStorage.getBroId();
  int broIdInt = -1;
  if (broIdString != null) {
    broIdInt = int.parse(broIdString);
  }
  if (broIdInt != -1) {
    // check the broIdInt with the broId from the login response
    if (newMe != null) {
      int newMeId = newMe.getId();
      if (broIdInt != newMeId) {
        await secureStorage.logout();
        Settings().logout();
        await Storage().clearDatabase();
        secureStorage.setBroId(newMe.getId().toString());
        return true;
      } else {
        return true;
      }
    }
  } else {
    // This has to be a new client with a new login.
    if (newMe != null) {
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
  settings.setLoggingIn(true);

  Me? newMe = loginResponse.getMe();

  bool broLogin = await checkSameBroLogin(secureStorage, newMe);
  if (!broLogin) {
    // something huge went wrong
    return;
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

  BroHomeChangeNotifier().notify();
}

successfulLoginToken(LoginResponse loginResponse) async {
  SecureStorage secureStorage = SecureStorage();
  Settings settings = Settings();
  settings.setLoggingIn(true);

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
  Future.delayed(Duration(seconds: 2), () {
    if (me.getAvatar() == null) {
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

closeChat() {
  // We check if the chat is open, if so we close it. Also on the server
  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();
  if (messagingChangeNotifier.isOpen) {
    messagingChangeNotifier.isOpen = false;
    if (messagingChangeNotifier.broupId != -1) {
      // If the bro is in a chat we need to close it.
      AuthServiceSocial().chatOpen(messagingChangeNotifier.broupId, false);
    }
    messagingChangeNotifier.setBroupId(-1);
  }
}

openChat(Broup chat) {
  // open chat.
  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();
  if (!messagingChangeNotifier.isOpen) {
    messagingChangeNotifier.isOpen = true;
    // If the bro is in a chat we need to close it.
    AuthServiceSocial().chatOpen(chat.broupId, true);
    messagingChangeNotifier.setBroupId(chat.broupId);
  }
  MessagingChangeNotifier().setBroupId(chat.broupId);
}

navigateToHome(BuildContext context, Settings settings) {
  closeChat();
  Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => BrocastHome(key: UniqueKey())));
}

navigateToChat(BuildContext context, Settings settings, Broup chat) {
  openChat(chat);
  Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatMessaging(
        key: UniqueKey(),
        chat: chat
      )
    ),
  );
}

navigateToProfile(BuildContext context, Settings settings) {
  closeChat();
  MessagingChangeNotifier().setBroupId(-1);
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => BroProfile(key: UniqueKey())));
}

navigateToSettings(BuildContext context, Settings settings) {
  closeChat();
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
    1,
    0,
    "Welcome to the Chat! 🥰",
    "",
    currentDayMessage.toUtc().toString(),
    null,
    true,
    broup.getBroupId(),
  );
  broup.updateLastActivity(currentDayMessage.toUtc().toString());
  Storage().addMessage(unBlockMessage);
  broup.messages.insert(
      0,
      unBlockMessage);
}

getBroupData(Storage storage, Me me) {
  storage.fetchAllBroups().then((broups) {
    storage.fetchAllBros().then((bros) {
      Map<String, Broup> broupMap = {for (var broup in broups) broup.getBroupId().toString(): broup};
      Map<String, Bro> broMap = {for (var bro in bros) bro.getId().toString(): bro};
      for (Broup broup in me.broups) {
        Broup? dbBroup = broupMap[broup.getBroupId().toString()];
        if (dbBroup == null) {
          // TODO: New broup found here? Is this possible?
        } else {
          if (broup.avatar != dbBroup.avatar) {
            broup.avatar = dbBroup.avatar;
            broup.avatarDefault = dbBroup.avatarDefault;
          }
          // clear before adding them again.
          // In case someone left, then the bro will be removed from the broup.
          broup.broupBros.clear();
          for (int broId in broup.broIds) {
            Bro? dbBro = broMap[broId.toString()];
            if (dbBro != null) {
              broup.addBro(dbBro);
            }
          }
        }
      }
      SocketServices().notify();
    });
  });
}

actuallyLogout(Settings settings, SocketServices socketServices, BuildContext context) {
  Me? me = settings.getMe();
  if (me != null) {
    socketServices.leaveRoomSolo(me.getId());
  }
  settings.setLoggingIn(false);
  settings.retrievedBroupData = false;
  SecureStorage().logout();
}