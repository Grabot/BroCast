import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:http/http.dart' as http;

class GetBros {
  Future getBros(String token) async {
    String urlGetBros = baseUrl + 'get/bros';
    Uri uriGetBros = Uri.parse(urlGetBros);

    http.Response responsePost = await http.post(
      uriGetBros,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'token': token}),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var broList = registerResponse["bro_list"];
        List<BroBros> listWithBros = [];
        for (var br0 in broList) {
          print(br0);
          print("this is the bro");
          BroBros broBros = new BroBros(
              br0["bros_bro_id"],
              br0["chat_name"],
              br0["chat_description"],
              br0["chat_colour"],
              br0["unread_messages"],
              br0["last_time_activity"]);
          listWithBros.add(broBros);
        }
        listWithBros.sort((b, a) => a.lastActivity.compareTo(b.lastActivity));
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }
}
