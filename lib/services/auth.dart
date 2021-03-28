import 'dart:convert';

import 'package:http/http.dart' as http;

class Auth {

  Future signUp(String broName, String bromotion, String password) async {
    String urlRegister ='http://10.0.2.2:5000/api/v1.0/register';
    Uri uriRegister = Uri.parse(urlRegister);

    http.Response responsePost = await http.post(uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    print(registerResponse);
    if (registerResponse.containsKey("result") && registerResponse.containsKey("message")) {
      bool result = registerResponse["result"];
      String message = registerResponse["message"];
      if (result) {
        return "";
      } else {
        return message;
      }
    }
    return "an unknown error has occurred";
  }

  Future signOff() {

  }

  Future signIn(String broName, String bromotion, String password) async {
    // TODO: @SKools automatic login with token
    String urlLogin ='http://10.0.2.2:5000/api/v1.0/login';
    Uri uriLogin = Uri.parse(urlLogin);

    http.Response responsePost = await http.post(uriLogin,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'token': ''
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    print(registerResponse);
    if (registerResponse.containsKey("result") && registerResponse.containsKey("message")) {
      bool result = registerResponse["result"];
      String message = registerResponse["message"];
      if (result) {
        return "";
      } else {
        return message;
      }
    }
    return "an unknown error has occurred";
  }
}