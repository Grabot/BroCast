import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:http/http.dart' as http;

class ReportBro {
  Future reportBro(String token, int brosBroId) async {
    String urlReportBro = baseUrl_v1_1 + 'report/bro';
    Uri uriReportBro = Uri.parse(urlReportBro);

    http.Response responsePost = await http.post(
      uriReportBro,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'bros_bro_id': brosBroId.toString()
      }),
    );

    Map<String, dynamic> reportBroResponse = jsonDecode(responsePost.body);
    if (reportBroResponse.containsKey("result")) {
      bool result = reportBroResponse["result"];
      if (result) {
        Map<String, dynamic> chatResponse = reportBroResponse["chat"];
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

  Future reportBroup(String token, int broupId) async {
    String urlReportBroup = baseUrl_v1_2 + 'report/broup';
    Uri uriReportBroup = Uri.parse(urlReportBroup);

    http.Response responsePost = await http.post(
      uriReportBroup,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'broup_id': broupId.toString()
      }),
    );

    Map<String, dynamic> reportBroupResponse = jsonDecode(responsePost.body);
    if (reportBroupResponse.containsKey("result")) {
      bool result = reportBroupResponse["result"];
      if (result) {
        Map<String, dynamic> chatResponse = reportBroupResponse["chat"];
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
