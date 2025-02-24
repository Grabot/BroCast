
class RegisterRequest {
  late String email;
  late String broName;
  late String bromotion;
  late String password;
  late int platform;  // 0 for Android, 1 for iOS
  String? FCMToken;

  RegisterRequest(this.email, this.broName, this.bromotion, this.password, this.FCMToken, this.platform);

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    json['email'] = email;
    json['bro_name'] = broName;
    json['bromotion'] = bromotion;
    json['password'] = password;
    json["platform"] = platform;
    json["fcm_token"] = FCMToken;

    return json;
  }
}
