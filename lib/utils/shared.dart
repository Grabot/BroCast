import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String eula = "eula";

  static Future<bool> setEULA(bool endUserLicenceAgreement) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(eula, endUserLicenceAgreement);
  }

  static Future<bool?> getEULA() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(eula);
  }

}
