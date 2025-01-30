
class LoginBroNameRequest {
  late String broName;
  late String bromotion;
  late String password;

  LoginBroNameRequest(this.broName, this.bromotion, this.password);

  setBroName(String broName) {
    this.broName = broName;
  }

  String getBroName() {
    return broName;
  }

  setBromotion(String bromotion) {
    this.bromotion = bromotion;
  }

  String getBromotion() {
    return bromotion;
  }

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return password;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json['bro_name'] = broName;
    json['bromotion'] = bromotion;
    json['password'] = password;
    return json;
  }
}
