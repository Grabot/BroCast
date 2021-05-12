import 'dart:convert';

import 'package:brocast/constants/api_path.dart';
import 'package:http/http.dart' as http;

class ResetRegistration {

  Future removeRegistrationId(int broId) async {
    String urlRemoveRegistration = baseUrl + 'remove/registration';
    Uri uriRemoveRegistration = Uri.parse(urlRemoveRegistration);

    print("url is ");
    print(urlRemoveRegistration);
    print(broId);
    http.Response responsePost = await http.post(uriRemoveRegistration,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'bro_id': broId.toString(),
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        print(registerResponse["message"]);
        return registerResponse["message"];
      }
    }
    return "an unknown error has occurred";
  }

}