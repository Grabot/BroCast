import 'dart:convert';

import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_not_added.dart';
import 'package:http/http.dart' as http;

class Search {
  Future searchBro(String token, String broName, String bromotion) async {
    String urlSearch = baseUrl_v1_0 + 'search';
    Uri uriRegister = Uri.parse(urlSearch);

    if (bromotion == null || bromotion == " ") {
      bromotion = "";
    }

    http.Response responsePost = await http.post(
      uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'bro_name': broName,
        'bromotion': bromotion
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var broList = registerResponse["bro_list"];
        List<Bro> listWithBros = [];
        for (var br0 in broList) {
          // This bro will not be stored in the db, so we give it a -1 broupid
          Bro bro =
              new BroNotAdded(br0["id"], -1, br0["bro_name"], br0["bromotion"]);
          listWithBros.add(bro);
        }
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }
}
