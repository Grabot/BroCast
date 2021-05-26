

class Settings {
  static Settings _instance = new Settings._internal();
  static get instance => _instance;

  bool emojiKeyboardDarkMode = false;

  Settings._internal();

  void setEmojiKeyboardDarkMode(bool darkMode) {
    this.emojiKeyboardDarkMode = darkMode;
  }

  bool getEmojiKeyboardDarkMode() {
    return this.emojiKeyboardDarkMode;
  }
}
