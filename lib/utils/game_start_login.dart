import 'package:jwt_decode/jwt_decode.dart';
import '../services/auth/auth_service_login.dart';
import '../services/auth/models/login_response.dart';
import 'utils.dart';
import 'secure_storage.dart';

Future<bool> loginCheck() async {
  SecureStorage secureStorage = SecureStorage();
  String? accessToken = await secureStorage.getAccessToken();
  int current = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  if (accessToken != null && accessToken != "") {
    int expiration = Jwt.parseJwt(accessToken)['exp'];
    if ((expiration - current) > 0) {
      // token valid! Attempt to login with it.
      bool accessTokenSuccessful = await accessTokenLogin(accessToken);
      if (accessTokenSuccessful) {
        return true;
      }
    }

    // If there is an access token but it is not valid we might be able to refresh the tokens.
    String? refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken != null && refreshToken != "") {
      int expirationRefresh = Jwt.parseJwt(refreshToken)['exp'];
      if ((expirationRefresh - current) > 0) {
        // refresh token valid! Attempt to refresh tokens and login with it.
        bool refreshTokenSuccessful = await refreshTokenLogin(accessToken, refreshToken);
        if (refreshTokenSuccessful) {
          return true;
        }
      }
    }
  }
  return false;
}

Future<bool> accessTokenLogin(String accessToken) async {
  try {
    LoginResponse loginResponse = await AuthServiceLogin().getTokenLogin(accessToken);
    if (loginResponse.getResult()) {
      return true;
    } else if (!loginResponse.getResult()) {
      // access token NOT valid!
      return false;
    }
  } catch(error) {
    showToastMessage(error.toString());
  }
  return false;
}

Future<bool> refreshTokenLogin(String accessToken, String refreshToken) async {
  try {
    LoginResponse loginResponse = await AuthServiceLogin().getRefresh(accessToken, refreshToken);
    if (loginResponse.getResult()) {
      return true;
    } else if (!loginResponse.getResult()) {
      // refresh token NOT valid!
      return false;
    }
  } catch(error) {
    showToastMessage(error.toString());
  }
  return false;
}
