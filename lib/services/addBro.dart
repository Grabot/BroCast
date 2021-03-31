import 'dart:convert';

import 'package:brocast/constants/api_path.dart';
import 'package:http/http.dart' as http;

class AddBro {

  Future addBro(String token, int broId) async {
    String urlAdd = baseUrl + 'add';
    Uri uriAdd = Uri.parse(urlAdd);

    http.Response responsePost = await http.post(uriAdd,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'token': token,
        'bros_bro_id': broId.toString()
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        return registerResponse["message"];
      }
    }
    return "an unknown error has occurred";
  }

}
