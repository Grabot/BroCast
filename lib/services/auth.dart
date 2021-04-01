import 'dart:convert';

import 'package:brocast/constants/api_path.dart';
import 'package:brocast/utils/shared.dart';
import 'package:http/http.dart' as http;

class Auth {

  Future signUp(String broName, String bromotion, String password) async {
    String urlRegister = baseUrl + 'register';
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
    if (registerResponse.containsKey("result") && registerResponse.containsKey("message")) {
      bool result = registerResponse["result"];
      String message = registerResponse["message"];
      if (result) {
        String token = registerResponse["token"];
        int broId = registerResponse["bro"]["id"];
        String broName = registerResponse["bro"]["bro_name"];
        String bromotion = registerResponse["bro"]["bromotion"];
        setInformation(token, broId, broName, bromotion, password);
        return "";
      } else {
        return message;
      }
    }
    return "an unknown error has occurred";
  }

  Future signIn(String broName, String bromotion, String password, String token) async {
    String urlLogin = baseUrl + 'login';
    Uri uriLogin = Uri.parse(urlLogin);

    http.Response responsePost = await http.post(uriLogin,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'token': token
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result") && registerResponse.containsKey("message")) {
      bool result = registerResponse["result"];
      String message = registerResponse["message"];
      if (result) {
        String token = registerResponse["token"];
        int broId = registerResponse["bro"]["id"];
        String broName = registerResponse["bro"]["bro_name"];
        String bromotion = registerResponse["bro"]["bromotion"];
        setInformation(token, broId, broName, bromotion, password);
        return "";
      } else {
        return message;
      }
    }
    return "an unknown error has occurred";
  }

  signOff() {
    setInformation("", 0, "", "", "");
  }

  setInformation(String token, int broId, String broName, String bromotion, String password) {
    HelperFunction.setBroToken(token);
    HelperFunction.setBroId(broId);
    HelperFunction.setBroName(broName);
    HelperFunction.setBromotion(bromotion);
    HelperFunction.setBroPassword(password);
    print(token);
    print(broId);
    print(broName);
    print(bromotion);
    print(password);
  }
}