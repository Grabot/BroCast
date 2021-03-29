import 'dart:convert';

import 'package:brocast/objects/bro.dart';
import 'package:http/http.dart' as http;

class GetBros {

  Future getBros(String token) async {
    String urlGetBros ='http://10.0.2.2:5000/api/v1.0/get/bros';
    Uri uriGetBros = Uri.parse(urlGetBros);

    http.Response responsePost = await http.post(uriGetBros,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'token': token
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var broList = registerResponse["bro_list"];
        List<Bro> listWithBros = [];
        for (var br0 in broList) {
          Bro bro = new Bro(br0["id"], br0["bro_name"], br0["bromotion"]);
          listWithBros.add(bro);
        }
        return listWithBros;
      }
    }
    return "an unknown error has occurred";
  }

}