import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:http/http.dart' as http;

class DeleteBroup {
  Future deleteBroup(String token, int broupId) async {
    String urlDeleteBroup = baseUrl_v1_3 + 'delete/broup';
    Uri uriDeleteBroup = Uri.parse(urlDeleteBroup);

    http.Response responsePost = await http.post(
      uriDeleteBroup,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'token': token, 'broup_id': broupId.toString()}),
    );

    Map<String, dynamic> deleteBroupResponse = jsonDecode(responsePost.body);
    if (deleteBroupResponse.containsKey("result")) {
      bool result = deleteBroupResponse["result"];
      if (result) {
        Map<String, dynamic> chatResponse = deleteBroupResponse["chat"];
        Broup broup = new Broup(
            chatResponse["id"],
            chatResponse["broup_name"],
            chatResponse["broup_description"],
            chatResponse["alias"],
            chatResponse["broup_colour"],
            chatResponse["unread_messages"],
            chatResponse["last_time_activity"],
            chatResponse["room_name"],
            0,
            chatResponse["mute"] ? 1 : 0,
            1,
            chatResponse["left"] ? 1 : 0);
        return broup;
      }
    }
    return "an unknown error has occurred";
  }
}
