import 'dart:convert';

import 'package:brocast/objects/bro.dart';
import 'package:http/http.dart' as http;

class Search {

  Future searchBro(String broName, String bromotion) async {
    String urlSearch ='http://10.0.2.2:5000/api/v1.0/search';
    Uri uriRegister = Uri.parse(urlSearch);

    http.Response responsePost = await http.post(uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_name': broName,
        'bromotion': bromotion
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    print(registerResponse);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var broList = registerResponse["bro_list"];
        List<Bro> listWithBros = [];
        for (var br0 in broList) {
          Bro bro = new Bro(br0["id"], br0["bro_name"], br0["bromotion"]);
          print(bro.getFullBroName());
          listWithBros.add(bro);
        }
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }

}
