import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/services/auth/v1_5/auth_api_v1_5.dart';
import 'package:brocast/utils/location_sharing.dart';
import 'package:brocast/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../objects/data_type.dart';
import '../../../objects/message.dart';

class AuthServiceSocialV15 {

  static AuthServiceSocialV15? _instance;

  factory AuthServiceSocialV15() => _instance ??= AuthServiceSocialV15._internal();

  AuthServiceSocialV15._internal();

  Future<int?> sendMessage(
      int broupId,
      String message,
      String? textMessage,
      Uint8List? messageData,
      int? dataType,
      int? repliedToMessageId
    ) async {
    String endPoint = "message/send";

    final formMap = <String, dynamic> {
      "broup_id": broupId,
      "message": message,
    };

    if (textMessage != null) {
      formMap["text_message"] = textMessage;
    }

    if (messageData != null && dataType != null) {
      if (dataType == DataType.image.value) {
        formMap["message_data"] = MultipartFile.fromBytes(
            messageData,
            filename: "image.png"
        );
      } else if (dataType == DataType.video.value) {
        formMap["video_data"] = MultipartFile.fromBytes(
            messageData,
            filename: "video.mp4"
        );
      } else if (dataType == DataType.audio.value) {
        formMap["audio_data"] = MultipartFile.fromBytes(
            messageData,
            filename: "audio.mp3"
        );
      }
    }

    if (repliedToMessageId != null) {
      formMap["replied_to_message_id"] = repliedToMessageId;
    }

    return await AuthApiV1_5().dio.post(
      endPoint,
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: "multipart/form-data",
        },
      ),
      data: FormData.fromMap(formMap),
    ).timeout(Duration(seconds: 30)).then((response) {

      Map<String, dynamic> json = response.data;
      if (!json.containsKey("result")) {
        return null;
      } else {
        if (json["result"]) {
          if (json.containsKey("message_id")) {
            return json["message_id"];
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    }).catchError((e) {
      if (e is DioException) {
        showToastMessage("Dio error while sending sending message: ${e.message}");
      } else {
        showToastMessage("Error while sending message: $e");
      }
      return null;
    });
  }

  Future<int?> sendMessageLocation(
      int broupId,
      String message,
      String? textMessage,
      String messageLocation,
      int dataType
      ) async {
    String endPoint = "message/send/location";

    return await AuthApiV1_5().dio.post(
      endPoint,
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      ),
      data: jsonEncode(<String, dynamic> {
        "broup_id": broupId,
        "message": message,
        "location": messageLocation,
        "text_message": textMessage ?? "",
        "data_type": dataType
      }),
    ).timeout(Duration(seconds: 30)).then((response) {

      Map<String, dynamic> json = response.data;
      if (!json.containsKey("result")) {
        return null;
      } else {
        if (json["result"]) {
          if (json.containsKey("message_id")) {
            return json["message_id"];
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    }).catchError((e) {
      if (e is DioException) {
        showToastMessage("Dio error while sending sending message: ${e.message}");
      } else {
        showToastMessage("Error while sending message: $e");
      }
      return null;
    });
  }

  Future<int> updateLocalBroupReadId(int broupId) async {
    String endPoint = "get/broup/read_time";
    var response = await AuthApiV1_5().dio.post(endPoint,
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
      return 1;
    } else {
      if (json["result"]) {
        if (!json.containsKey("last_read_time")) {
          return 1;
        } else {
          return json["last_read_time"];
        }
      } else {
        return 1;
      }
    }
  }

  Future<bool> messageEmojiReaction(int broupId, int messageId, String emoji, bool isAdd) async {
    String endPoint = "message/emoji_reaction";

    var data;
    if (!isAdd) {
      data = jsonEncode(<String, dynamic>{
        "broup_id": broupId,
        "message_id": messageId,
        "emoji": emoji,
        "is_add": isAdd,
      });
    } else {
      data = jsonEncode(<String, dynamic>{
        "broup_id": broupId,
        "message_id": messageId,
        "emoji": emoji,
      });
    }
    var response = await AuthApiV1_5().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: data
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<bool> receivedEmojiReaction(int broupId) async {
    String endPoint = "emoji_reaction/received";

    var response = await AuthApiV1_5().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
        })
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      return json["result"];
    }
  }

  Future<Uint8List?> getMessageData(int broupId, int messageId) async {
    String endPoint = "message/get/data";

    var response = await AuthApiV1_5().dio.post(endPoint,
        options: Options(
        responseType: ResponseType.bytes,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "message_id": messageId,
        })
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 404) {
      return null;
    } else if (response.statusCode == 500) {
      // TODO: do a 'data is present' check?
      return null;
    } else {
      return null;
    }
  }

  Future<List<Message>> retrieveMessages(int broupId, int lastMessageId) async {
    String endPoint = "message/get";
    var response = await AuthApiV1_5().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic> {
          "broup_id": broupId,
          "last_message_id": lastMessageId
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return [];
    } else {
      if (json["result"]) {
        if (json.containsKey("messages")) {
          List<Message> messages = [];
          for (var message in json["messages"]) {
            messages.add(await Message.fromJson(message));
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

  Future<LatLng?> getBroLocation(int broupId, int broId) async {
    String endPoint = "bro/location";
    var response = await AuthApiV1_5().dio.post(endPoint,
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
      return null;
    } else {
      if (json["result"]) {
        if (json.containsKey("lat") && json.containsKey("lng")) {
          return LatLng(json["lat"], json["lng"]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  Future<bool> getBroupLocation(int broupId) async {
    String endPoint = "broup/location";
    var response = await AuthApiV1_5().dio.post(endPoint,
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
      if (json["result"]) {
        if (json.containsKey("bro_locations")) {
          LocationSharing locationSharing = LocationSharing();
          print("updating broup location");
          for (var broLocation in json["bro_locations"]) {
            if (broLocation.containsKey("lat") && broLocation.containsKey("lng") && broLocation.containsKey("bro_id")) {
              LatLng locationBro = LatLng(broLocation["lat"], broLocation["lng"]);
              locationSharing.broPositions[broLocation["bro_id"]] = locationBro;
              print("updated broup location $broLocation");
            }
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
  }
}
