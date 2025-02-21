import 'dart:convert';
import 'dart:io';

import 'package:brocast/utils/utils.dart';
import 'package:dio/dio.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../objects/message.dart';
import '../../utils/settings.dart';
import '../../utils/storage.dart';
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

    Storage storage = Storage();
    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json.containsKey("broup") && json.containsKey("bro")) {
        Me? me = Settings().getMe();
        if (me != null) {
          Bro newBro = Bro.fromJson(json["bro"]);
          newBro.added = true;
          storage.addBro(newBro);
          if (me.broups.indexWhere((element) => element.getBroupId() == json["broup"]["broup_id"]) == -1) {
            Broup newBroup = Broup.fromJson(json["broup"]);
            storage.addBroup(newBroup);
            newBroup.addBro(newBro);
            me.addBroup(newBroup);
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

  Future<List<Message>> retrieveMessages(int broupId, int lastMessageId) async {
    String endPoint = "message/get";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_id": broupId,
          "last_message_id": lastMessageId
        }
      )
    );

    Storage storage = Storage();
    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return [];
    } else {
      if (json["result"]) {
        if (json.containsKey("messages")) {
          List<Message> messages = [];
          for (var message in json["messages"]) {
            Message newMessage = Message.fromJson(message);
            storage.addMessage(newMessage);
            messages.add(newMessage);
          }
          return messages;
        } else {
          return [];
        }
      } else {
        return [];
      }
    }
  }

  Future<Broup?> retrieveBroup(int broupId) async {
    String endPoint = "broup/get/single";
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
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("broup")) {
          return Broup.fromJson(json["broup"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<Bro?> retrieveBro(int broId) async {
    String endPoint = "bro/get/single";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("bro")) {
          return Bro.fromJson(json["bro"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<List<Bro>> retrieveBros(List<int> broIds) async {
    String endPoint = "bro/get";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "bro_ids": broIds
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
            Bro newBro = Bro.fromJson(bro);
            bros.add(newBro);
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

  Future<bool> addNewBroup(List<int> broIds, String broupName) async {
    String endPoint = "broup/add";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "bro_ids": broIds,
          "broup_name": broupName
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
          if (me.broups.indexWhere((element) => element.getBroupId() == json["broup"]["broup_id"]) == -1) {
            Broup newBroup = Broup.fromJson(json["broup"]);
            Storage().addBroup(newBroup);
            me.addBroup(newBroup);
          }
        }
      }
      return json["result"];
    }
  }

  Future<bool> addBroToBroup(int broupId, int broId) async {
    String endPoint = "broup/add_bro";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> makeBroAdmin(int broupId, int broId) async {
    String endPoint = "broup/make_admin";
    print("making bro admin $broId");
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> dismissBroAdmin(int broupId, int broId) async {
    String endPoint = "broup/dismiss_admin";
    print("Dismissing bro admin $broId");
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> removeBroToBroup(int broupId, int broId) async {
    String endPoint = "broup/remove_bro";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_id": broId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> leaveBroup(int broupId) async {
    String endPoint = "broup/leave";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> broupBrosRetrieved(int broupId) async {
    String endPoint = "broup/bros_retrieved";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }
}
