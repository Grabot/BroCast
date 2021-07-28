import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
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
        return true;
      }
    }
    return "an unknown error has occurred";
  }
}
