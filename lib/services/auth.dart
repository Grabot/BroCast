import 'package:http/http.dart' as http;
import 'dart:convert';

class Auth {

  Future signUp(String username, String password) async {
    String urlAll ='http://10.0.2.2:5000/api/v1.0/all';
    Uri uriAll = Uri.parse(urlAll);
    http.Response response = await http.get(uriAll);

    String urlRegister ='http://10.0.2.2:5000/api/v1.0/register/test/test/test';
    Uri uriRegister = Uri.parse(urlRegister);
    http.Response responsePost = await http.post(uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': 'title',
      }),
    );
    print("response");
    print(responsePost);
    print(responsePost.body);
    print(responsePost.statusCode);
    if (responsePost.statusCode == 200) {
      print("the response was good!");
    } else {
      print("the response was bad");
    }
    return "Hello World";
  }
}