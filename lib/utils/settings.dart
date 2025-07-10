import 'package:brocast/objects/me.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'dart:typed_data';

class Settings {
  static final Settings _instance = Settings._internal();

  bool loggingIn = false;
  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;
  int refreshTokenExpiration = 0;
  Me? me;
  bool emojiKeyboardDarkMode = false;

  bool retrievedBroupData = false;

  Uint8List notFoundImage = Uint8List(0);

  Settings._internal() {
    HelperFunction.getDarkKeyboard().then((value) {
      if (value != null) {
        this.emojiKeyboardDarkMode = value;
      }
    });
  }

  factory Settings() {
    return _instance;
  }

  void setNotFoundImage() async {
    notFoundImage = await loadImageAsUint8List("assets/images/not_found.png");
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
    loggingIn = false;
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
