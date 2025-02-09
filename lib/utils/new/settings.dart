// A class to store anything that might be useful at any point in the app.
import 'package:brocast/objects/me.dart';

class Settings {
  static final Settings _instance = Settings._internal();

  bool loggingIn = true;
  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;
  int refreshTokenExpiration = 0;
  Me? me;
  bool emojiKeyboardDarkMode = false;

  List<String> doneRoutes = [];
  bool retrievedData = false;

  Settings._internal();

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
