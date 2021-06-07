// A class to store anything that might be useful at any point in the app.
class Settings {
  static Settings _instance = new Settings._internal();

  static get instance => _instance;

  bool emojiKeyboardDarkMode = false;
  String token = "";
  String password = "";
  int broId = -1;
  String broName = "";
  String bromotion = "";

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
    this.broName = broName;
  }

  String getBroName() {
    return this.broName;
  }

  setBromotion(String bromotion) {
    this.bromotion = bromotion;
  }

  String getBromotion() {
    return this.bromotion;
  }
}
