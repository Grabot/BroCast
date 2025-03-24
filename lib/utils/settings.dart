// A class to store anything that might be useful at any point in the app.
import 'package:brocast/objects/me.dart';
import 'package:brocast/utils/shared.dart';
import 'package:intl/intl.dart';

import '../objects/broup.dart';
import '../objects/message.dart';

class Settings {
  static final Settings _instance = Settings._internal();

  bool loggingIn = true;
  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;
  int refreshTokenExpiration = 0;
  Me? me;
  bool emojiKeyboardDarkMode = false;

  bool retrievedBroData = false;
  bool retrievedBroupData = false;

  Settings._internal() {
    HelperFunction.getDarkKeyboard().then((value) {
      if (value != null) {
        this.emojiKeyboardDarkMode = value;
      }
    });
    // We will set a check for midnight here.
    // At midnight we will alter any existing date time tiles.
    // Today will be yesterday and yesterday will the the date formatting.
    // If the app is not open any date tiles are removed and re-added on opening
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day+1);
    Duration timeUntilMidnight = midnight.difference(now);
    Future.delayed(timeUntilMidnight, () {
      alterDateTimeTiles();
    });
  }

  alterDateTimeTiles() {
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
      alterDateTimeTiles();
    });
  }

  factory Settings() {
    return _instance;
  }

  void setEmojiKeyboardDarkMode(bool darkMode) {
    this.emojiKeyboardDarkMode = darkMode;
  }

  bool getEmojiKeyboardDarkMode() {
    return this.emojiKeyboardDarkMode;
  }

  logout() {
    accessToken = "";
    refreshToken = "";
    accessTokenExpiration = 0;
    me = null;
    loggingIn = true;
  }

  setMe(Me me) {
    this.me = me;
  }

  Me? getMe() {
    return me;
  }

  setAccessToken(String accessToken) {
    this.accessToken = accessToken;
  }

  String getAccessToken() {
    return accessToken;
  }

  setRefreshToken(String refreshToken) {
    this.refreshToken = refreshToken;
  }

  String getRefreshToken() {
    return refreshToken;
  }

  setLoggingIn(bool loggingIn) {
    this.loggingIn = loggingIn;
  }

  bool getLoggingIn() {
    return loggingIn;
  }

  setAccessTokenExpiration(int accessTokenExpiration) {
    this.accessTokenExpiration = accessTokenExpiration;
  }

  int getAccessTokenExpiration() {
    return accessTokenExpiration;
  }

  setRefreshTokenExpiration(int refreshTokenExpiration) {
    this.refreshTokenExpiration = refreshTokenExpiration;
  }

  int getRefreshTokenExpiration() {
    return refreshTokenExpiration;
  }
}
