import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String eula = "eula";
  static String darkKeyboard = "darkKeyboard";
  static String flashKey = "flash";

  static Future<bool> setEULA(bool endUserLicenceAgreement) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(eula, endUserLicenceAgreement);
  }

  static Future<bool?> getEULA() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(eula);
  }

  static Future<bool> setDarkKeyboard(bool darkKeyboardSetting) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(darkKeyboard, darkKeyboardSetting);
  }

  static Future<bool?> getDarkKeyboard() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(darkKeyboard);
  }

  static Future<bool> setFlashConfiguration(int flashConfiguration) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setInt(flashKey, flashConfiguration);
  }

  static Future<int?> getFlashConfiguration() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(flashKey);
  }
}
