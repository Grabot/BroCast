

import '../../../objects/me.dart';

class LoginResponse {
  late bool result;
  late String message;
  String? accessToken;
  String? refreshToken;
  String? FCMToken;
  List<int> broupIds = [];
  Me? me;

  LoginResponse(this.result, this.message, this.accessToken, this.refreshToken, this.FCMToken, this.me);

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

  String? getFCMToken() {
    return FCMToken;
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
        if (json.containsKey("fcm_token")) {
          FCMToken = json["fcm_token"];
        }
        if (json.containsKey("bro")) {
          Map<String, dynamic> userJson = json["bro"];
          me = Me.fromJson(userJson);
        }
        if (json.containsKey("broup_ids") && json["broup_ids"] != null) {
          broupIds = json["broup_ids"].cast<int>();
        }
      }
    }
  }
}
