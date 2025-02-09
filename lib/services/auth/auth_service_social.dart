import 'dart:convert';
import 'dart:io';

import 'package:brocast/utils/new/utils.dart';
import 'package:dio/dio.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../utils/new/settings.dart';
import '../../utils/new/storage.dart';
import 'auth_api.dart';

class AuthServiceSocial {

  static AuthServiceSocial? _instance;

  factory AuthServiceSocial() => _instance ??= AuthServiceSocial._internal();

  AuthServiceSocial._internal();

  Future<List<Bro>> searchPossibleBro(String possibleBro, String bromotionSearch) async {
    String endPoint = "bro/search";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "bro_name": possibleBro,
          "bromotion": bromotionSearch
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return [];
    } else {
      if (json["result"]) {
        if (json.containsKey("bros")) {
          List<Bro> bros = [];
          for (var bro in json["bros"]) {
            bros.add(Bro.fromJson(bro));
          }
          return bros;
        } else {
          return [];
        }
      } else {
        return [];
      }
    }
  }

  Future<bool> addNewBro(int broId) async {
    String endPoint = "bro/add";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, int>{
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json.containsKey("broup")) {
        Me? me = Settings().getMe();
        if (me != null) {
          if (me.bros.indexWhere((element) => element.getBroupId() == json["broup"]["broup_id"]) == -1) {
            Broup newBroup = Broup.fromJson(json["broup"]);
            Storage().addBroup(newBroup);
            me.bros.add(newBroup);
          }
        }
      }
      return json["result"];
    }
  }

  Future<bool> sendMessage(int broupId, String message, String? textMessage, String? messageData) async {
    String endPoint = "message/send";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "message": message,
          "text_message": textMessage,
          "message_data": messageData
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json.containsKey("result");
    }
  }

  Future<bool> receivedMessage(int broupId, int messageId) async {
    print("sending received message");
    String endPoint = "message/received";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_id": broupId,
          "message_id": messageId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json.containsKey("result");
    }
  }

  Future<bool> readMessages(int broupId) async {
    String endPoint = "message/read";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_id": broupId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json.containsKey("result");
    }
  }

  Future<List<Broup>> retrieveBroups(List<int> broupIds) async {
    String endPoint = "broup/get";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_ids": broupIds
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return [];
    } else {
      if (json["result"]) {
        if (json.containsKey("broups")) {
          List<Broup> broups = [];
          for (var broup in json["broups"]) {
            broups.add(Broup.fromJson(broup));
          }
          return broups;
        } else {
          return [];
        }
      } else {
        return [];
      }
    }
  }
}
