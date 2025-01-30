

import '../../../objects/new/me.dart';

class LoginResponse {
  late bool result;
  late String message;
  String? accessToken;
  String? refreshToken;
  Me? me;

  LoginResponse(this.result, this.message, this.accessToken, this.refreshToken, this.me);

  bool getResult() {
    return result;
  }

  String getMessage() {
    return message;
  }

  String? getAccessToken() {
    return accessToken;
  }

  String? getRefreshToken() {
    return refreshToken;
  }

  Me? getMe() {
    return me;
  }

  LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("result") &&
        json.containsKey("message")) {
      result = json["result"];
      message = json["message"];
      if (result) {
        accessToken = json["access_token"];
        refreshToken = json["refresh_token"];
        if (json.containsKey("bro")) {
          Map<String, dynamic> userJson = json["bro"];
          me = Me.fromJson(userJson);
        }
      }
    }
  }
}
