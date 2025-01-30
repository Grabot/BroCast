import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../utils/new/utils.dart';
import '../../utils/new/settings.dart';
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
    var response = await AuthApi().dio.post(endPoint,
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
    var response = await AuthApi().dio.post(endPoint,
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
    var response = await AuthApi().dio.post(endPoint,
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
    Settings().setLoggingIn(true);
    String endPoint = "refresh";
    var response = await AuthApi().dio.post(endPoint,
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
    if (loginResponse.getResult()) {
      successfulLogin(loginResponse);
    }
    return loginResponse;
  }

  Future<LoginResponse> getTokenLogin(String accessToken) async {
    Settings().setLoggingIn(true);
    String endPoint = "login/token";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String> {
          "access_token": accessToken
        }
      )
    );

    LoginResponse loginResponse = LoginResponse.fromJson(response.data);
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
}