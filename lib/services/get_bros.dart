import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/broup.dart';
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
        List<Chat> listWithBros = [];
        for (var br0 in broList) {
          if (br0.containsKey("chat_name")) {
            BroBros broBros = new BroBros(
                br0["bros_bro_id"],
                br0["chat_name"],
                br0["chat_description"],
                br0["alias"],
                br0["chat_colour"],
                br0["unread_messages"],
                br0["last_time_activity"],
                br0["room_name"],
                br0["blocked"] ? 1 : 0,
                br0["mute"] ? 1 : 0,
                0);
            listWithBros.add(broBros);
          } else if (br0.containsKey("broup_name")) {
            Broup broup = new Broup(
                br0["id"],
                br0["broup_name"],
                br0["broup_description"],
                br0["alias"],
                br0["broup_colour"],
                br0["unread_messages"],
                br0["last_time_activity"],
                br0["room_name"],
                0,
                br0["mute"] ? 1 : 0,
                1);
            List<dynamic> broIds = br0["bro_ids"];
            List<int> broIdList = broIds.map((s) => s as int).toList();
            broup.setParticipants(broIdList);
            List<dynamic> broAdminsIds = br0["bro_admin_ids"];
            List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
            broup.setAdmins(broAdminIdList);
            listWithBros.add(broup);
          } else {
            print("big problem");
          }
        }
        listWithBros.sort((b, a) => a.getLastActivity().compareTo(b.getLastActivity()));
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }
}
