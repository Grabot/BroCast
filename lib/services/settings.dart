// A class to store anything that might be useful at any point in the app.
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_added.dart';

class Settings {
  static Settings _instance = new Settings._internal();

  static get instance => _instance;

  bool emojiKeyboardDarkMode = false;
  String token = "";
  String password = "";
  int broId = -1;
  String broName = "";
  String bromotion = "";

  Bro me;

  Settings._internal();

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

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return this.password;
  }

  setBroId(int broId) {
    this.broId = broId;
  }

  int getBroId() {
    return this.broId;
  }

  setBroName(String broName) {
    if (this.bromotion.isNotEmpty) {
      me = new BroAdded(this.broId, broName + " " + this.bromotion);
    }
    this.broName = broName;
  }

  String getBroName() {
    return this.broName;
  }

  setBromotion(String bromotion) {
    if (this.broName.isNotEmpty) {
      me = new BroAdded(this.broId, this.broName + " " + bromotion);
    }
    this.bromotion = bromotion;
  }

  String getBromotion() {
    return this.bromotion;
  }

  setMe(Bro me) {
    this.me = me;
  }

  Bro getMe() {
    return this.me;
  }
}
