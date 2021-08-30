import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:http/http.dart' as http;

class AddNewBroup {

  Future addNewBroup(String token, List<int> participants) async {
    String urlRegister = baseUrl_v1_2 + 'add_broup';
    Uri uriRegister = Uri.parse(urlRegister);

    http.Response responsePost = await http
        .post(
      uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'participants': jsonEncode(participants)
      }),
    )
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return null;
      },
    );

    print("response");
    print(responsePost);

    if (responsePost == null) {
      return "Could not connect to the server";
    } else {
      Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
      if (registerResponse.containsKey("result") &&
          registerResponse.containsKey("message")) {
        bool result = registerResponse["result"];
        String message = registerResponse["message"];
        if (result) {
          // String token = registerResponse["token"];
          return "";
        } else {
          return message;
        }
      }
    }
    return "an unknown error has occurred";
  }
}