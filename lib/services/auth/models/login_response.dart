

class LoginResponse {
  late bool result;
  late String message;
  String? accessToken;
  String? refreshToken;
  // User? user;

  // LoginResponse(this.result, this.message, this.accessToken, this.refreshToken, this.user);
  LoginResponse(this.result, this.message, this.accessToken, this.refreshToken);

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

  // User? getUser() {
  //   return user;
  // }

  LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("result") &&
        json.containsKey("message")) {
      result = json["result"];
      message = json["message"];
      if (result) {
        accessToken = json["access_token"];
        refreshToken = json["refresh_token"];
        if (json.containsKey("user")) {
          Map<String, dynamic> userJson = json["user"];
          // user = User.fromJson(userJson);
        }
      }
    }
  }
}
