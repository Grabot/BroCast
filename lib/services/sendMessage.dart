import 'dart:convert';

import 'package:brocast/objects/bro.dart';
import 'package:http/http.dart' as http;

class SendMessage {

  Future sendMessage(String token, int brosBroId, String message) async {
    String urlSendMessage ='http://10.0.2.2:5000/api/v1.0/send/message';
    Uri uriSendMessage = Uri.parse(urlSendMessage);

    http.Response responsePost = await http.post(uriSendMessage,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String> {
        'token': token,
        'bros_bro_id': brosBroId.toString(),
        'message': message
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        String message = registerResponse["message"];
        return message;
      }
    }
    return "an unknown error has occurred";
  }

}