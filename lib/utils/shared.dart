import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String broTokenKey = "broToken";
  static String broIdKey = "broId";
  static String broInformationKey = "broInformation";
  static String broNameKey = "broName";
  static String bromotionKey = "bromotion";
  static String broPasswordKey = "password";
  static String eula = "eula";

  static Future<bool> setBroToken(String broToken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(broTokenKey, broToken);
  }

  static Future<bool> setBroId(int broId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setInt(broIdKey, broId);
  }

  static Future<bool> setEULA(bool endUserLicenceAgreement) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(eula, endUserLicenceAgreement);
  }

  static Future<bool?> setBroInformation(
      String broName, String bromotion, String broPassword) async {
    // We only update this information if a password is given.
    if (broPassword != null && broPassword != "") {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      return await preferences
          .setStringList(broInformationKey, [broName, bromotion, broPassword]);
    } else {
      return null;
    }
  }

  static Future<String?> getBroToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(broTokenKey);
  }

  static Future<int?> getBroId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(broIdKey);
  }

  static Future<bool?> getEULA() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(eula);
  }

  static Future<List<String>?> getBroInformation() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(broInformationKey);
  }
}
