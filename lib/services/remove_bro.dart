import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:http/http.dart' as http;

class RemoveBro {
  Future removeBro(String token, int brosBroId) async {
    String urlRemoveBro = baseUrl_v1_0 + 'remove/bro';
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
        Map<String, dynamic> chatResponse = removeBroResponse["chat"];
        BroBros broBros = new BroBros(
            chatResponse["bros_bro_id"],
            chatResponse["chat_name"],
            chatResponse["chat_description"],
            chatResponse["alias"],
            chatResponse["chat_colour"],
            chatResponse["unread_messages"],
            chatResponse["last_time_activity"],
            chatResponse["room_name"],
            chatResponse["blocked"] ? 1 : 0,
            chatResponse["mute"] ? 1 : 0,
            0);
        return broBros;
      }
    }
    return "an unknown error has occurred";
  }
}
