import 'package:brocast/utils/utils.dart';

import '../services/auth/auth_service_login.dart';
import '../services/auth/models/login_response.dart';

Future<bool> loginCheck() async {
  bool accessTokenSuccessful = await accessTokenLogin();
  return accessTokenSuccessful;
}

Future<bool> accessTokenLogin() async {
  try {
    LoginResponse loginResponse = await AuthServiceLogin().getTokenLogin();
    if (loginResponse.getResult()) {
      return true;
    } else if (!loginResponse.getResult()) {
      return false;
    }
  } catch(error) {
    showToastMessage(error.toString());
    return false;
  }
  return false;
}
