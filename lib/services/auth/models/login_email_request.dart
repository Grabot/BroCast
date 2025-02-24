
class LoginEmailRequest {
  late String email;
  late String password;
  late int platform;

  LoginEmailRequest(this.email, this.password, this.platform);

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json['email'] = email;
    json['password'] = password;
    json["platform"] = platform;
    return json;
  }
}
