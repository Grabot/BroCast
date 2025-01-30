
class LoginEmailRequest {
  late String email;
  late String password;

  LoginEmailRequest(this.email, this.password);

  setEmail(String email) {
    this.email = email;
  }

  String getEmail() {
    return email;
  }

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return password;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    json['email'] = email;
    json['password'] = password;
    return json;
  }
}
