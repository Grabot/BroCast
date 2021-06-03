import 'dart:convert';

import 'package:brocast/constants/api_path.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:http/http.dart' as http;

class GetChat {

  Future getchat(int broId, int broBrosId) async {
    String urlGetChat = baseUrl + 'get/chat';
    Uri uriGetChat = Uri.parse(urlGetChat);

    http.Response responsePost = await http.post(uriGetChat,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_id': broId.toString(),
        'bros_bro_id': broBrosId.toString(),
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      print("received something back!");
      bool result = registerResponse["result"];
      if (result) {
        print("it was goooood");
        var chat = registerResponse["chat"];
        print(chat);
        BroBros broBros = new BroBros(
            chat["bros_bro_id"],
            chat["chat_name"],
            chat["chat_colour"],
            chat["unread_messages"],
            chat["last_time_activity"]
        );
        return broBros;
      }
    }
    return "an unknown error has occurred";
  }

}