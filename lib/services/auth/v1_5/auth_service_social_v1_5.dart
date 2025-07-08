import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/services/auth/v1_5/auth_api_v1_5.dart';
import 'package:brocast/utils/utils.dart';
import 'package:dio/dio.dart';

class AuthServiceSocialV15 {

  static AuthServiceSocialV15? _instance;

  factory AuthServiceSocialV15() => _instance ??= AuthServiceSocialV15._internal();

  AuthServiceSocialV15._internal();

  Future<bool> sendMessage(int broupId, String message, String? textMessage, Uint8List? messageData, int? repliedToMessageId) async {
    String endPoint = "message/send";

    final formMap = <String, dynamic>{
      "broup_id": broupId,
      "message": message,
    };

    if (textMessage != null) {
      formMap["text_message"] = textMessage;
    }

    if (messageData != null) {
      formMap["message_data"] = MultipartFile.fromBytes(
          messageData,
          filename: "image.jpg"
      );
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
        return false;
      } else {
        return json.containsKey("result");
      }
    }).catchError((e) {
      if (e is DioException) {
        showToastMessage("Dio error while sending sending message: ${e.message}");
      } else {
        showToastMessage("Error while sending message: $e");
      }
      return false;
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
}
