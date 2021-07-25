import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:http/http.dart' as http;

class GetChat {
  Future getChat(int broId, int broBrosId) async {
    String urlGetChat = baseUrl + 'get/chat';
    Uri uriGetChat = Uri.parse(urlGetChat);

    http.Response responsePost = await http.post(
      uriGetChat,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_id': broId.toString(),
        'bros_bro_id': broBrosId.toString(),
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var chat = registerResponse["chat"];
        BroBros broBros = new BroBros(
            chat["bros_bro_id"],
            chat["chat_name"],
            chat["chat_description"],
            chat["chat_colour"],
            chat["unread_messages"],
            chat["last_time_activity"],
            chat["blocked"]);
        return broBros;
      }
    }
    return "an unknown error has occurred";
  }
}
