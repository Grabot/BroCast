import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/services/auth/models/base_response.dart';
import 'package:brocast/utils/life_cycle_service.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
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
              // updated in db and broup list.
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

  Future<bool> broupBrosRetrieved(int broupId, List<int> broIds) async {
    String endPoint = "broup/bros_retrieved";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "bro_ids": broIds
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

  broDetailsDone(List<int> brosToUpdate, List<int> broAvatarsToUpdate, int? broupId) {
    Settings settings = Settings();
    settings.retrievedBroData = false;
    settings.retrievedBroupData = false;
    BroHomeChangeNotifier().notify();
    // All the bro id's in the lists are updated, if they are in some broup updateBroId lists we can remove them there.

    if (broupId != null) {
      for (Broup broupMe in settings.getMe()!.broups) {
        if (broupMe.getBroupId() == broupId) {
          Set<int> combinedSet = Set<int>.from(brosToUpdate)
            ..addAll(broAvatarsToUpdate);
          List<int> combinedList = combinedSet.toList();
          Storage().fetchBros(combinedList).then((brosDb) {
            for (Bro broDb in brosDb) {
              if (broupMe.getBroIds().contains(broDb.getId())) {
                print("adding a bro in the broupbros");
                broupMe.addBro(broDb);
              } else {
                print("a bro was no longer found in the broId list");
                // check if broDb is in the bro remaining list
                if (!broupMe.messageBroRemaining.any((element) =>
                element.getId() == broDb.getId())) {
                  print("bro ${broDb.getBroName()} ${broDb.getBromotion()}");
                  print("adding it to remaining bros!");
                  broupMe.messageBroRemaining.add(broDb);
                }
              }
            }
            MessagingChangeNotifier().notify();
          });
        }
      }
    }

    for (Broup broupMe in settings.getMe()!.broups) {
      for (int broUpdateId in brosToUpdate) {
        if (broupMe.updateBroIds.contains(broUpdateId)) {
          broupMe.updateBroIds.remove(broUpdateId);
        }
      }
      for (int broAvatarUpdateId in broAvatarsToUpdate) {
        if (broupMe.updateBroAvatarIds.contains(broAvatarUpdateId)) {
          broupMe.updateBroAvatarIds.remove(broAvatarUpdateId);
        }
      }
    }
  }

  Future<void> broDetails(List<int> brosToUpdate, List<int> broAvatarsToUpdate, int? broupId) async {
    String endPoint = "bro/details";

    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "bro_update_ids": brosToUpdate,
          "bro_avatar_update_ids": broAvatarsToUpdate,
        }
      )
    );

    print("broToUpdate $brosToUpdate");
    print("broAvatarsToUpdate $broAvatarsToUpdate");

    // We take the list and remove entries until everything is gone. That's how we know we're done.
    // We still want the original lists for later checks, so we copy them here.
    List<int> brosToUpdateCheck = [...brosToUpdate];
    List<int> broAvatarsToUpdateCheck = [...broAvatarsToUpdate];
    Set<int> combinedSet = Set<int>.from(brosToUpdateCheck)
      ..addAll(broAvatarsToUpdateCheck);
    List<int> combinedList = combinedSet.toList();

    Storage storage = Storage();
    Map<String, dynamic> json = response.data;
    storage.fetchBros(combinedList).then((dbBros) {
      Map<String, Bro> brosDbMap = {for (var bro in dbBros) bro.getId().toString(): bro};
      if (!json.containsKey("result")) {
        // TODO: What to do if it goes wrong?
        // return false;
      } else {
        // We'll gather the bro data and store it in the db here.
        if (!json.containsKey("bros")) {
          // TODO: What to do if it goes wrong?
          // return false;
        } else {
          for (var bro in json["bros"]) {
            Bro newBro = Bro.fromJson(bro);
            print("new bro ${newBro.broName}  ${newBro.bromotion}");
            if (broAvatarsToUpdateCheck.contains(newBro.id)) {
              // Bro with avatar. Here we'll have all the bro data so just override in the db.
              storage.addBro(newBro);

              broAvatarsToUpdateCheck.remove(newBro.id);
              if (brosToUpdateCheck.contains(newBro.id)) {
                brosToUpdateCheck.remove(newBro.id);
              }

              if (brosToUpdateCheck.isEmpty && broAvatarsToUpdateCheck.isEmpty) {
                broDetailsDone(brosToUpdate, broAvatarsToUpdate, broupId);
              }
            } else if (brosToUpdateCheck.contains(newBro.id)) {
              Bro? storedBro = brosDbMap[newBro.id.toString()];
              if (storedBro != null) {
                // Bro with avatar.
                newBro.avatar = storedBro.avatar;
                storage.updateBro(newBro);
              } else {
                storage.addBro(newBro);
              }
              brosToUpdateCheck.remove(newBro.id);
              if (brosToUpdateCheck.isEmpty && broAvatarsToUpdateCheck.isEmpty) {
                broDetailsDone(brosToUpdate, broAvatarsToUpdate, broupId);
              }
            } else {
              // Bro not in the lists, should not be possible
            }
          }
        }
      }
    });
  }

  broupDetailsDone(List<int> combinedList) {
    Me? me = Settings().getMe();
    if (me != null) {
      // Create a set of broup IDs from me.broups for efficient lookup
      Set<int> meBroupIds = {for (Broup broupMe in me.broups) broupMe.getBroupId()};

      // Find the IDs from combinedList that are not in me.broups
      List<int> missingIds = combinedList.where((id) => !meBroupIds.contains(id)).toList();
      print("missingIds $missingIds");
      if (missingIds.isNotEmpty) {
        // There were broups missing! They should be in the db now
        Storage().fetchBroups(missingIds).then((broupDbs) {
          for (Broup broupDb in broupDbs) {
            // Add the missing broup to me.broups
            me.addBroup(broupDb);
          }
          // After adding the broups we check if the avatars need to be retrieved.
          List<int> broAvatarsToUpdate = [];
          for (Broup broupDb in broupDbs) {
            if (broupDb.private) {
              for (int broId in broupDb.getBroIds()) {
                if (broId != me.id) {
                  broAvatarsToUpdate.add(broId);
                }
              }
            } else {
              // Since it's probably a clean login here we will set all the bros to be updated in broups.
              // After this we will subtract the available private chats and me since they are retrieved now.
              broupDb.updateBroIds = [...broupDb.broIds];
              broupDb.updateBroAvatarIds = [...broupDb.broIds];
              print("setting broIds to be updated ${broupDb.updateBroIds}");
              for (Broup broupDb2 in broupDbs) {
                if (broupDb2.private) {
                  for (int broId in broupDb2.getBroIds()) {
                    if (broId != me.id) {
                      if (broupDb.updateBroIds.contains(broId)) {
                        print("removing broId $broId from updateBroIds ${broupDb.updateBroIds}");
                        broupDb.updateBroIds.remove(broId);
                        broupDb.updateBroAvatarIds.remove(broId);
                      }
                    }
                  }
                }
              }
              if (broupDb.updateBroIds.contains(me.getId())) {
                print("removing me ${me.getId()} from updateBroIds ${broupDb.updateBroIds}");
                broupDb.updateBroIds.remove(me.getId());
                broupDb.updateBroAvatarIds.remove(me.getId());
              }
            }
            Storage().updateBroup(broupDb);
          }
          Settings().retrievedBroupData = false;
          BroHomeChangeNotifier().notify();
          broDetails(broAvatarsToUpdate, broAvatarsToUpdate, null);
        });
      }
    }
    Settings().retrievedBroupData = false;
    BroHomeChangeNotifier().notify();
  }

  Future<void> broupDetails(List<int> broupsToUpdate, List<int> broupAvatarsToUpdate) async {
    String endPoint = "broup/details";

    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_update_ids": broupsToUpdate,
          "broup_avatar_update_ids": broupAvatarsToUpdate,
        }
      )
    );

    // We take the list and remove entries until everything is gone. That's how we know we're done.
    // We still want the original lists for later checks, so we copy them here.
    List<int> broupsToUpdateCheck = [...broupsToUpdate];
    List<int> broupAvatarsToUpdateCheck = [...broupAvatarsToUpdate];

    Set<int> combinedSet = Set<int>.from(broupsToUpdateCheck)
      ..addAll(broupAvatarsToUpdateCheck);
    List<int> combinedList = combinedSet.toList();
    Storage storage = Storage();
    print("combinedList $combinedList");
    storage.fetchBroups(combinedList).then((dbBroups) async {
      Map<String, Broup> broupDbMap = {for (var broup in dbBroups) broup.getBroupId().toString(): broup};
      Map<String, dynamic> json = response.data;
      if (!json.containsKey("result")) {
        // TODO: What if it goes wrong?
        // return false;
      } else {
        // We'll gather the bro data and store it in the db here.
        if (!json.containsKey("broups")) {
          // TODO: What if it goes wrong?
          // return false;
        } else {
          print("just printing everything");
          print(json["broups"]);
          for (var broup in json["broups"]) {
            int broupId = broup["broup_id"];
            if (broupAvatarsToUpdateCheck.contains(broupId) && broupsToUpdateCheck.contains(broupId)) {
              Broup newBroup = Broup.fromJson(broup);
              Broup? existingBroup = broupDbMap[broupId.toString()];
              if (existingBroup != null) {
                // Broup with avatar.
                existingBroup.updateBroupDataServer(newBroup);
                // Make sure that the avatar is transferred, since it was send with the request.
                existingBroup.avatar = newBroup.avatar;
                existingBroup.avatarDefault = newBroup.avatarDefault;
                await storage.updateBroup(existingBroup);
              } else {
                await storage.addBroup(newBroup);
              }
              broupAvatarsToUpdateCheck.remove(broupId);
              broupsToUpdateCheck.remove(broupId);
              if (broupsToUpdateCheck.isEmpty && broupAvatarsToUpdateCheck.isEmpty) {
                broupDetailsDone(combinedList);
                return;
              }
            } else if (broupAvatarsToUpdateCheck.contains(broupId)) {
              print("broupAvatarsToUpdateCheck");
              Map<String, dynamic> chat_details = broup["chat"];
              if (chat_details.containsKey("avatar") && chat_details["avatar"] != null) {
                Uint8List avatar = base64Decode(chat_details["avatar"].replaceAll("\n", ""));
                // This variable can only ever be here if the avatar was send as well.
                bool avatarDefault = chat_details.containsKey("avatar_default") ? chat_details["avatar_default"] : true;
                Broup? existingBroup = broupDbMap[broupId.toString()];
                if (existingBroup != null) {
                  existingBroup
                    ..avatar = avatar
                    ..avatarDefault = avatarDefault;
                  print("updating existing broup  ${existingBroup.broupId} ${existingBroup.avatar}");
                  await storage.updateBroup(existingBroup);
                }
                broupDbMap.remove(broupId.toString());
                broupAvatarsToUpdateCheck.remove(broupId);
                if (broupsToUpdateCheck.isEmpty && broupAvatarsToUpdateCheck.isEmpty) {
                  broupDetailsDone(combinedList);
                  return;
                }
              } else {
                print("Huge problem?!");
              }
            } else if (broupsToUpdateCheck.contains(broupId)) {
              broupsToUpdateCheck.remove(broupId);
              Broup newBroup = Broup.fromJson(broup);
              Broup? existingBroup = broupDbMap[broupId.toString()];
              if (existingBroup != null) {
                // Broup with avatar.
                existingBroup.updateBroupDataServer(newBroup);
                await storage.updateBroup(existingBroup);
              } else {
                await storage.addBroup(newBroup);
              }
              if (broupsToUpdateCheck.isEmpty && broupAvatarsToUpdateCheck.isEmpty) {
                broupDetailsDone(combinedList);
                return;
              }
            } else {
              // Bro not in the lists, should not be possible
            }
          }
        }
      }
    });
  }

  Future<bool> broupsBroIdsReceived(List<int> broupIds) async {
    String endPoint = "broups/received/broids";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_ids": broupIds,
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

  setBroupsReceived(List<int> broupsReceived) {
    if (broupsReceived.length == 1) {
      broupBroIdsReceived(broupsReceived[0]).then((value) {
        if (value) {
          print("broupBroIdsReceived success");
        }
      });
    } else {
      broupsBroIdsReceived(broupsReceived).then((value) {
        if (value) {
          print("broupsBroIdsReceived success");
        }
      });
    }
  }

  Future<bool> broupBroIdsReceived(int broupId) async {
    String endPoint = "broup/received/broids";
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
    if (LifeCycleService().getAppStatus() != 1) {
      // App is not in foreground, we don't want to indicate broup retrieval
      return false;
    }
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
            broup.newAvatar = false;
            Storage().updateBroup(broup);
            // Find the object corresponding with this broup and update the avatar
            Me? me = Settings().getMe();
            if (me != null) {
              for (Broup meBroup in me.broups) {
                if (meBroup.getBroupId() == broupId) {
                  meBroup.setAvatar(avatar);
                  meBroup.setAvatarDefault(isDefault);
                  meBroup.newAvatar = false;
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
              broup.newAvatar = false;
              Storage().addBroup(broup);
              // Find the object corresponding with this broup and update the avatar
              Me? me = Settings().getMe();
              if (me != null) {
                for (Broup meBroup in me.broups) {
                  if (meBroup.getBroupId() == broupId) {
                    meBroup.setAvatar(avatar);
                    meBroup.setAvatarDefault(isDefault);
                    meBroup.newAvatar = false;
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

  Future<bool> chatOpen(int broupId, bool openChat) async {
    String endPoint = "broup/open";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "open_chat": openChat
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
