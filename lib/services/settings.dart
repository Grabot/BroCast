// A class to store anything that might be useful at any point in the app.
import 'package:brocast/objects/bro_added.dart';

class Settings {
  static final Settings _instance = Settings._internal();

  bool emojiKeyboardDarkMode = false;
  String token = "";
  int broId = -1;
  String broName = "";
  String bromotion = "";

  BroAdded? me;

  bool loggingIn = false;
  String accessToken = "";
  String refreshToken = "";
  int accessTokenExpiration = 0;
  int refreshTokenExpiration = 0;

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

  setToken(String token) {
    this.token = token;
  }

  String getToken() {
    return this.token;
  }

  setBroId(int broId) {
    this.broId = broId;
  }

  int getBroId() {
    return this.broId;
  }

  setBroName(String broName) {
    if (this.bromotion.isNotEmpty) {
      me = new BroAdded(this.broId, -1, broName + " " + this.bromotion);
    }
    this.broName = broName;
  }

  String getBroName() {
    return this.broName;
  }

  setBromotion(String bromotion) {
    if (this.broName.isNotEmpty) {
      me = new BroAdded(this.broId, -1, this.broName + " " + bromotion);
    }
    this.bromotion = bromotion;
  }

  String getBromotion() {
    return this.bromotion;
  }

  setMe(BroAdded me) {
    this.me = me;
  }

  BroAdded? getMe() {
    return this.me;
  }

  logout() {
    accessToken = "";
    refreshToken = "";
    accessTokenExpiration = 0;
    // user = null;
    // avatar = null;
    loggingIn = false;
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
