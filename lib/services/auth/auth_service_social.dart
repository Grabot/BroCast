import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/services/auth/models/base_response.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
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

  Future<BaseResponse> addNewBro(int broId) async {
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

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    if (baseResponse.getResult()) {
      Storage storage = Storage();
      Map<String, dynamic> json = response.data;
      if (json.containsKey("broup") && json.containsKey("bro")) {
        Me? me = Settings().getMe();
        if (me != null) {
          // The bro should have the avatar with the request
          Bro newBro = Bro.fromJson(json["bro"]);
          storage.addBro(newBro);
          if (newBro.avatar == null) {
            getAvatarBro(newBro.id);
          }
          Broup newBroup = Broup.fromJson(json["broup"]);
          storage.addBroup(newBroup);
          newBroup.addBro(newBro);
          me.addBroup(newBroup);
        }
      }
    }
    return baseResponse;
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
    print("sending read messages");
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

  Future<Bro?> retrieveBroAvatar(int broId) async {
    print("retrieving bro avatar");
    String endPoint = "bro/get/single";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "bro_id": broId,
          "with_avatar": true
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

  Future<Bro?> retrieveBro(int broId) async {
    print("retrieving bro");
    String endPoint = "bro/get/single";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "bro_id": broId,
          "with_avatar": false
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
          Broup newBroup = Broup.fromJson(json["broup"]);
          Storage().addBroup(newBroup);
          me.addBroup(newBroup);
          // New broup. Give the server some time to generate the avatar.
          Future.delayed(Duration(seconds: 2)).then((value) {
            getAvatarBroup(newBroup.broupId).then((value) {
              if (value) {
                // Data is retrieved, and updated on the broup db object.
                // TODO: update new_avatar false?
              }
            });
          });
          BroHomeChangeNotifier().notify();
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

  Future<bool> broupRetrieved(int broupId) async {
    String endPoint = "broup/retrieved";
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

  Future<bool> broRetrieved(int broId) async {
    String endPoint = "bro/retrieved";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "bro_id": broId,
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

  Future<bool> updateFCMToken(String newFCMToken) async {
    String endPoint = "change/fcm_token";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "fcm_token": newFCMToken,
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

  Future<bool> getAvatarBro(int broId) async {
    String endPoint = "get/avatar/bro";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "bro_id": broId,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json["result"]) {
        if (!json.containsKey("avatar") && json["avatar"] != null) {
          return false;
        } else {
          Uint8List avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
          Bro? bro = await Storage().fetchBro(broId);
          if (bro != null) {
            bro.setAvatar(avatar);
            Storage().updateBro(bro);
            updateBroups(bro);
            return true;
          } else {
            // For some reason we don't have the bro stored yet. Retrieve it first.
            Bro? bro = await AuthServiceSocial().retrieveBro(broId);
            if (bro != null) {
              bro.setAvatar(avatar);
              updateBroups(bro);
              return true;
            } else {
              return false;
            }
          }
        }
      } else {
        return false;
      }
    }
  }

  updateBroups(Bro bro) {
    Storage().addBro(bro);
    Me? me = Settings().getMe();
    if (me != null) {
      for (Broup broup in me.broups) {
        if (broup.broIds.contains(bro.id)) {
          broup.addBro(bro);
          if (broup.private) {
            // TODO: `new_avatar` back to false?
          }
        }
      }
      BroHomeChangeNotifier().notify();
    }
  }

  Future<bool> getAvatarBroup(int broupId) async {
    String endPoint = "get/avatar/broup";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_id": broupId,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json["result"]) {
        if (!json.containsKey("avatar") && json["avatar"] != null) {
          return false;
        } else {
          bool isDefault = true;
          if (json.containsKey("is_default") && json["is_default"] != null) {
            isDefault = json["is_default"];
          }
          Uint8List avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
          Broup? broup = await Storage().fetchBroup(broupId);
          if (broup != null) {
            print("get avatar broup found");
            print("avatar default $isDefault");
            broup.setAvatar(avatar);
            broup.setAvatarDefault(isDefault);
            Storage().updateBroup(broup);
            // Find the object corresponding with this broup and update the avatar
            Me? me = Settings().getMe();
            if (me != null) {
              for (Broup meBroup in me.broups) {
                if (meBroup.getBroupId() == broupId) {
                  meBroup.setAvatar(avatar);
                  meBroup.setAvatarDefault(isDefault);
                  break;
                }
              }
            }
            BroHomeChangeNotifier().notify();
            return true;
          } else {
            // For some reason we don't have the bro stored yet. Retrieve it first.
            Broup? broup = await AuthServiceSocial().retrieveBroup(broupId);
            if (broup != null) {
              broup.setAvatar(avatar);
              broup.setAvatarDefault(isDefault);
              Storage().addBroup(broup);
              // Find the object corresponding with this broup and update the avatar
              Me? me = Settings().getMe();
              if (me != null) {
                for (Broup meBroup in me.broups) {
                  if (meBroup.getBroupId() == broupId) {
                    meBroup.setAvatar(avatar);
                    meBroup.setAvatarDefault(isDefault);
                    break;
                  }
                }
              }
              BroHomeChangeNotifier().notify();
              return true;
            } else {
              return false;
            }
          }
        }
      } else {
        return false;
      }
    }
  }


  Future<bool> unblockBro(int broupId, int broId) async {
    String endPoint = "bro/unblock";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_id": broId,
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

  Future<bool> deleteBroup(int broupId) async {
    String endPoint = "broup/delete";
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

  Future<bool> muteBroup(int broupId, int muteTime) async {
    String endPoint = "broup/mute";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "mute_time": muteTime,
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

  Future<bool> reportBroup(int broupId, List<String> reportMessages, String broupName) async {
    String endPoint = "broup/report";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "report_messages": reportMessages,
          "broup_name": broupName
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
