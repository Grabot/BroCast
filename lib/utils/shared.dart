import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String eula = "eula";
  static String darkKeyboard = "darkKeyboard";

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
}
