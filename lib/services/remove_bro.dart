import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:http/http.dart' as http;

class RemoveBro {
  Future removeBro(String token, int brosBroId) async {
    String urlRemoveBro = baseUrl_v1_1 + 'remove/bro';
    Uri uriRemoveBro = Uri.parse(urlRemoveBro);

    http.Response responsePost = await http.post(
      uriRemoveBro,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'bros_bro_id': brosBroId.toString()
      }),
    );

    Map<String, dynamic> removeBroResponse = jsonDecode(responsePost.body);
    if (removeBroResponse.containsKey("result")) {
      bool result = removeBroResponse["result"];
      if (result) {
        return true;
      }
    }
    return "an unknown error has occurred";
  }
}
