
import '../../../utils/utils.dart';

class LoginRequest {
  late String emailOrUserName;
  late String password;

  LoginRequest(this.emailOrUserName, this.password);

  setEmail(String emailOrUserName) {
    this.emailOrUserName = emailOrUserName;
  }

  String getEmailOrUserName() {
    return emailOrUserName;
  }

  setPassword(String password) {
    this.password = password;
  }

  String getPassword() {
    return password;
  }

  @override
  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    if (emailValid(emailOrUserName)) {
      json['email'] = emailOrUserName;
    } else {
      json['user_name'] = emailOrUserName;
    }

    json['password'] = password;
    return json;
  }
}
