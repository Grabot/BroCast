import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/message.dart';
import 'package:http/http.dart' as http;

class GetMessages {
  Future getMessages(String token, int brosBroId) async {
    String urlGetMessages = baseUrl_v1_3 + 'get/messages';
    Uri uriGetMessages = Uri.parse(urlGetMessages);

    http.Response responsePost = await http.post(
      uriGetMessages,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'bros_bro_id': brosBroId.toString()
      }),
    );
    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var messageList = registerResponse["message_list"];
        var lastReadTime = registerResponse["last_read_time_bro"];
        var timeLastRead = DateTime.parse(lastReadTime + 'Z').toLocal();
        List<Message> listWithMessages = [];
        for (var message in messageList) {
          Message mes = new Message(
              message["id"],
              message["sender_id"],
              message["body"],
              message["text_message"],
              message["timestamp"],
              message["info"] ? 1 : 0,
              brosBroId,
              0
          );
          if (timeLastRead.isAfter(mes.getTimeStamp())) {
            mes.isRead = 1;
          }
          listWithMessages.add(mes);
        }
        return listWithMessages;
      }
    }
    return "an unknown error has occurred";
  }

  Future getMessagesBroup(String token, int broupId) async {
    String urlGetMessages = baseUrl_v1_3 + 'get/messages/broup';
    Uri uriGetMessages = Uri.parse(urlGetMessages);

    http.Response responsePost = await http.post(
      uriGetMessages,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'broup_id': broupId.toString()
      }),
    );

    Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
    if (registerResponse.containsKey("result")) {
      bool result = registerResponse["result"];
      if (result) {
        var messageList = registerResponse["message_list"];
        var lastReadTime = registerResponse["last_read_time_bro"];
        var timeLastRead = DateTime.parse(lastReadTime + 'Z').toLocal();
        List<Message> listWithMessages = [];
        for (var message in messageList) {
          Message mes = new Message(
              message["id"],
              message["sender_id"],
              message["body"],
              message["text_message"],
              message["timestamp"],
              message["info"] ? 1 : 0,
              broupId,
              1
          );
          if (timeLastRead.isAfter(mes.getTimeStamp())) {
            mes.isRead = 1;
          }
          print("a new messages I have retrieved");
          print(mes);
          print(mes.body);
          listWithMessages.add(mes);
        }
        return listWithMessages;
      }
    }
    return "an unknown error has occurred";
  }
}
