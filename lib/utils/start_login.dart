import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/utils.dart';

import '../services/auth/v1_4/auth_service_login.dart';
import '../services/auth/models/login_response.dart';

Future<bool> loginCheck() async {
  Settings().setLoggingIn(true);
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
