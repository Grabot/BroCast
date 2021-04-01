import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String broTokenKey = "broToken";
  static String broIdKey = "broId";
  static String broNameKey = "broName";
  static String bromotionKey = "bromotion";
  static String broPasswordKey = "password";

  static Future<bool> setBroToken(String broToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broTokenKey, broToken);
  }

  static Future<bool> setBroId(int broId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setInt(broIdKey, broId);
  }

  static Future<bool> setBroName(String broName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broNameKey, broName);
  }

  static Future<bool> setBromotion(String bromotion) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(bromotionKey, bromotion);
  }

  static Future<bool> setBroPassword(String broPassword) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broPasswordKey, broPassword);
  }

  static Future<String> getBroToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broTokenKey);
  }

  static Future<int> getBroId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(broIdKey);
  }

  static Future<String> getBroName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broNameKey);
  }

  static Future<String> getBromotion() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(bromotionKey);
  }

  static Future<String> getBroPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broPasswordKey);
  }
}
