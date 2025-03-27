import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:brocast/services/auth/auth_api_login.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../objects/me.dart';
import '../../utils/secure_storage.dart';
import '../../utils/storage.dart';
import '../../utils/utils.dart';
import '../../utils/settings.dart';
import '../../views/bro_home/bro_home_change_notifier.dart';
import 'auth_api.dart';
import 'models/base_response.dart';
import 'models/login_bro_name_request.dart';
import 'models/login_email_request.dart';
import 'models/login_response.dart';
import 'models/register_request.dart';


class AuthServiceLogin {
  static AuthServiceLogin? _instance;

  factory AuthServiceLogin() => _instance ??= AuthServiceLogin._internal();

  AuthServiceLogin._internal();

  Future<LoginResponse> getLoginEmail(LoginEmailRequest loginEmailRequest) async {
    Settings().setLoggingIn(true);
    String endPoint = "login";
    var response = await AuthApiLogin().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: loginEmailRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getLoginBroName(LoginBroNameRequest loginBroNameRequest) async {
    Settings().setLoggingIn(true);
    String endPoint = "login";
    var response = await AuthApiLogin().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: loginBroNameRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getRegister(RegisterRequest registerRequest) async {
    Settings().setLoggingIn(true);
    String endPoint = "register";
    var response = await AuthApiLogin().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: registerRequest.toJson()
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  // The methods below should use the AuthApi class instead of AuthApiLogin.
  // This will send a token with the request to do the authentication.
  Future<BaseResponse> logout() async {
    String endPoint = "logout";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<LoginResponse> getRefresh(String accessToken, String refreshToken) async {
    Settings settings = Settings();
    settings.setLoggingIn(true);
    print("refresh action 2");
    String endPoint = "refresh";
    var response = await AuthApiLogin().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "access_token": accessToken,
          "refresh_token": refreshToken
        }
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    String? newAccessToken = loginResponse.getAccessToken();
    SecureStorage secureStorage = SecureStorage();
    if (newAccessToken != null) {
      // the access token will be set in memory and local storage.
      int expirationAccess = Jwt.parseJwt(newAccessToken)['exp'];
      settings.setAccessToken(newAccessToken);
      settings.setAccessTokenExpiration(expirationAccess);
      await secureStorage.setAccessToken(newAccessToken);
      await secureStorage.setAccessTokenExpiration(expirationAccess);
    }

    String? newRefreshToken = loginResponse.getRefreshToken();
    if (newRefreshToken != null) {
      // the refresh token will only be set in memory.
      int refreshExpiration = Jwt.parseJwt(newRefreshToken)['exp'];
      settings.setRefreshToken(newRefreshToken);
      settings.setRefreshTokenExpiration(refreshExpiration);
      await secureStorage.setRefreshToken(newRefreshToken);
      await secureStorage.setRefreshTokenExpiration(refreshExpiration);
    }
    return loginResponse;
  }

  Future<LoginResponse> getTokenLogin() async {
    String endPoint = "login/token";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {}
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    print("got response from token login ${loginResponse.getResult()}");
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<BaseResponse> getPasswordReset(String email) async {
    String endPoint = "password/reset";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "email": email
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> passwordResetCheck(String accessToken, String refreshToken) async {
    String endPoint = "password/check";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken,
          "refresh_token": refreshToken
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> updatePassword(String accessToken, String refreshToken, String newPassword) async {
    String endPoint = "password/update";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken,
          "refresh_token": refreshToken,
          "new_password": newPassword
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);

    return baseResponse;
  }

  Future<BaseResponse> removeAccount(String accessToken, String refreshToken, String origin) async {
    String endPoint = "remove/account/verify";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "access_token": accessToken,
          "refresh_token": refreshToken,
          "origin": origin
        })
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<LoginResponse> getLoginGoogle(String accessToken) async {
    Settings().setLoggingIn(true);
    String endPoint = "login/google/token";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "access_token": accessToken
        }));

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<bool> getAvatarMe() async {
    String endPoint = "get/avatar/me";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json["result"]) {
        if (!json.containsKey("avatar") && json["avatar"] != null) {
          return false;
        } else {
          bool isDefault = true;
          if (json.containsKey("is_default") && json["is_default"] != null) {
            isDefault = json["is_default"];
          }
          Uint8List avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
          Me? me = Settings().getMe();
          if (me != null) {
            me.setAvatar(avatar);
            me.setAvatarDefault(isDefault);
            SecureStorage secureStorage = SecureStorage();
            secureStorage.setAvatar(base64Encode(avatar));
            secureStorage.setAvatarDefault(isDefault ? "1" : "0");
            Storage().updateBro(me);
          }
          BroHomeChangeNotifier().notify();
          return true;
        }
      } else {
        return false;
      }
    }
  }
}