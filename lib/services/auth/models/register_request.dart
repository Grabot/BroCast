
class RegisterRequest {
  late String email;
  late String broName;
  late String bromotion;
  late String password;

  RegisterRequest(this.email, this.broName, this.bromotion, this.password);

  setEmail(String email) {
    this.email = email;
  }

  String getEmail() {
    return email;
  }

  setBroName(String broName) {
    this.broName = broName;
  }

  String getBroName() {
    return broName;
  }

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return password;
  }

  setBroMotion(String bromotion) {
    this.bromotion = bromotion;
  }

  String getBroMotion() {
    return bromotion;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    json['email'] = email;
    json['bro_name'] = broName;
    json['bromotion'] = bromotion;
    json['password'] = password;

    return json;
  }
}
