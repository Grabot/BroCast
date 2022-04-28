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
}
