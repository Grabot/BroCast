import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:http/http.dart' as http;

class GetBroupBros {
  Future getBroupBros(String token, int broupId, List<int> participants) async {
    String urlGetBroupBros = baseUrl_v1_2 + 'get/broup_bros';
    Uri uriGetBroupBros = Uri.parse(urlGetBroupBros);

    http.Response responsePost = await http.post(
      uriGetBroupBros,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'participants': jsonEncode(participants)
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var broList = registerResponse["bro_list"];
        List<Bro> listWithBros = [];
        for (var br0 in broList) {
          Bro bro = new BroNotAdded(
              br0["id"], broupId, br0["bro_name"], br0["bromotion"]);
          listWithBros.add(bro);
        }
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }
}
