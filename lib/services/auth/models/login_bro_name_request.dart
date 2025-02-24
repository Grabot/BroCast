
class LoginBroNameRequest {
  late String broName;
  late String bromotion;
  late String password;
  late int platform;

  LoginBroNameRequest(this.broName, this.bromotion, this.password, this.platform);

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json['bro_name'] = broName;
    json['bromotion'] = bromotion;
    json['password'] = password;
    json["platform"] = platform;
    return json;
  }
}
