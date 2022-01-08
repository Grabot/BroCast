import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/utils/storage.dart';
import 'package:http/http.dart' as http;

class ResetRegistration {
  Storage storage = Storage();

  Future removeRegistrationId(int broId) async {
    String urlRemoveRegistration = baseUrl + 'remove/registration';
    Uri uriRemoveRegistration = Uri.parse(urlRemoveRegistration);

    http.Response responsePost = await http.post(
      uriRemoveRegistration,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_id': broId.toString(),
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        // If it succeeded we will also empty out the db with all the chats and messages this user had received.
        return registerResponse["message"];
      }
    }
    return "an unknown error has occurred";
  }
}
