import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
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
            chat["alias"],
            chat["chat_colour"],
            chat["unread_messages"],
            chat["last_time_activity"],
            chat["room_name"],
            chat["blocked"],
            chat["mute"],
            0);
        return broBros;
      }
    }
    return "an unknown error has occurred";
  }

  Future getBroup(int broId, int broupId) async {
    String urlGetBroup = baseUrl_v1_2 + 'get/broup';
    Uri uriGetBroup = Uri.parse(urlGetBroup);

    http.Response responsePost = await http.post(
      uriGetBroup,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_id': broId.toString(),
        'broup_id': broupId.toString(),
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var chat = registerResponse["chat"];
        Broup broup = new Broup(
            chat["id"],
            chat["broup_name"],
            chat["broup_description"],
            chat["alias"],
            chat["broup_colour"],
            chat["unread_messages"],
            chat["last_time_activity"],
            chat["room_name"],
            0,
            chat["mute"],
            1);
        List<dynamic> broIds = chat["bro_ids"];
        List<int> broIdList = broIds.map((s) => s as int).toList();
        broup.setParticipants(broIdList);
        List<dynamic> broAdminsIds = chat["bro_admin_ids"];
        List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
        broup.setAdmins(broAdminIdList);
        return broup;
      }
    }
    return "an unknown error has occurred";
  }
}
