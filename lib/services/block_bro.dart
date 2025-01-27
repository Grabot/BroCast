import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:http/http.dart' as http;

class BlockBro {
  Future blockBro(String token, int brosBroId, bool blocked) async {
    String urlBlockBro = baseUrl_v1_0 + 'block/bro';
    Uri uriBlockBro = Uri.parse(urlBlockBro);

    http.Response responsePost = await http.post(
      uriBlockBro,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'bros_bro_id': brosBroId.toString(),
        'blocked': blocked.toString(),
      }),
    );

    Map<String, dynamic> blockBroResponse = jsonDecode(responsePost.body);
    if (blockBroResponse.containsKey("result")) {
      bool result = blockBroResponse["result"];
      if (result) {
        Map<String, dynamic> chatResponse = blockBroResponse["chat"];
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
