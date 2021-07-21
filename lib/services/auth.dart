import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class Auth {
  Future signUp(String broName, String bromotion, String password) async {
    await Firebase.initializeApp();
    String registrationId = await FirebaseMessaging.instance.getToken();

    String urlRegister = baseUrl_v1_1 + 'register';
    Uri uriRegister = Uri.parse(urlRegister);

    String deviceType = "IOS";
    if (Platform.isAndroid) {
      deviceType = "Android";
    }

    http.Response responsePost = await http
        .post(
      uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'registration_id': registrationId,
        'device_type': deviceType
      }),
    )
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return null;
      },
    );

    if (responsePost == null) {
      return "Could not connect to the server";
    } else {
      Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
      if (registerResponse.containsKey("result") &&
          registerResponse.containsKey("message")) {
        bool result = registerResponse["result"];
        String message = registerResponse["message"];
        if (result) {
          String token = registerResponse["token"];
          int broId = registerResponse["bro"]["id"];
          String broName = registerResponse["bro"]["bro_name"];
          String bromotion = registerResponse["bro"]["bromotion"];

          Settings.instance.setBroId(broId);
          Settings.instance.setBroName(broName);
          Settings.instance.setBromotion(bromotion);
          Settings.instance.setPassword(password);
          Settings.instance.setToken(token);
          setInformation(token, broId, broName, bromotion, password);
          return "";
        } else {
          return message;
        }
      }
    }
    return "an unknown error has occurred";
  }

  Future signIn(
      String broName, String bromotion, String password, String token) async {
    await Firebase.initializeApp();
    String registrationId = await FirebaseMessaging.instance.getToken();

    String urlLogin = baseUrl_v1_1 + 'login';
    Uri uriLogin = Uri.parse(urlLogin);

    String deviceType = "IOS";
    if (Platform.isAndroid) {
      deviceType = "Android";
    }

    http.Response responsePost = await http
        .post(
      uriLogin,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'token': token,
        'registration_id': registrationId,
        'device_type': deviceType
      }),
    )
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return null;
      },
    );

    if (responsePost == null) {
      return "Could not connect to the server";
    } else {
      Map<String, dynamic> registerResponse;
      try {
        registerResponse = jsonDecode(responsePost.body);
      } on Exception catch (_) {
        return "an unknown error has occurred";
      }
      if (registerResponse.containsKey("result") &&
          registerResponse.containsKey("message")) {
        bool result = registerResponse["result"];
        String message = registerResponse["message"];
        if (result) {
          String token = registerResponse["token"];
          int broId = registerResponse["bro"]["id"];
          String broName = registerResponse["bro"]["bro_name"];
          String bromotion = registerResponse["bro"]["bromotion"];

          Settings.instance.setBroId(broId);
          Settings.instance.setBroName(broName);
          Settings.instance.setBromotion(bromotion);
          Settings.instance.setPassword(password);
          Settings.instance.setToken(token);
          await setInformation(token, broId, broName, bromotion, password);
          return "";
        } else {
          return message;
        }
      }
    }
    return "an unknown error has occurred";
  }

  signOff() {
    setInformation("", 0, "", "", "");
  }

  setInformation(String token, int broId, String broName, String bromotion,
      String password) async {
    await HelperFunction.setBroToken(token);
    await HelperFunction.setBroId(broId);
    await HelperFunction.setBroInformation(broName, bromotion, password);
  }
}
