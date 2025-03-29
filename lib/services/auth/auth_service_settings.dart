import 'dart:convert';
import 'dart:io';

import 'package:brocast/utils/utils.dart';
import 'package:dio/dio.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../utils/secure_storage.dart';
import '../../utils/settings.dart';
import '../../utils/storage.dart';
import 'auth_api.dart';
import 'models/base_response.dart';

class AuthServiceSettings {

  static AuthServiceSettings? _instance;

  factory AuthServiceSettings() => _instance ??= AuthServiceSettings._internal();

  AuthServiceSettings._internal();

  Future<bool> changeColourBroup(int broupId, String newBroupColour) async {
    String endPoint = "broup/change_colour";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "new_broup_colour": newBroupColour
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

  Future<bool> changeAliasBroup(int broupId, String newBroupAlias) async {
    String endPoint = "broup/change_alias";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "new_broup_alias": newBroupAlias
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

  Future<bool> changeDescriptionBroup(int broupId, String newBroupDescription) async {
    String endPoint = "broup/change_description";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId,
          "new_broup_description": newBroupDescription
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

  Future<String> changeBromotion(String bromotion) async {
    String endPoint = "change/bromotion";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "bromotion": bromotion,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "Something went wrong";
    } else {
      if (json["result"]) {
        return "Bromotion changed";
      } else {
        if (json.containsKey("message")) {
          return json["message"];
        }
        return "Bromotion not changed";
      }
    }
  }

  Future<bool> changeBroname(String broname) async {
    String endPoint = "change/broname";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broname": broname,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return false;
    } else {
      if (json["result"]) {
        SecureStorage().setBroName(broname);
        Settings settings = Settings();
        settings.getMe()!.setBroName(broname);
        Storage().updateBro(settings.getMe()!);
        return true;
      } else {
        if (json.containsKey("message")) {
          showToastMessage(json["message"]);
        }
        return false;
      }
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    String endPoint = "change/password";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "old_password": oldPassword,
          "new_password": newPassword,
        }
      )
    );

    Map<String, dynamic> json = response.data;
    if (!json.containsKey("result")) {
      return "Something went wrong";
    } else {
      if (json["result"]) {
        return "Password changed";
      } else {
        if (json.containsKey("message")) {
          return json["message"];
        }
        return "Password not changed";
      }
    }
  }

  Future<BaseResponse> changeAvatar(String newAvatarRegular) async {
    String endPoint = "change/avatar";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
          "avatar": newAvatarRegular,
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> changeAvatarBroup(String newAvatarRegular, int broupId) async {
    String endPoint = "change/avatar/broup";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "avatar": newAvatarRegular,
          "broup_id": broupId
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> resetAvatarMe() async {
    String endPoint = "reset/avatar/me";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, String>{
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }

  Future<BaseResponse> resetAvatarBroup(int broupId) async {
    String endPoint = "reset/avatar/broup";
    var response = await AuthApi().dio.post(endPoint,
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: jsonEncode(<String, dynamic>{
          "broup_id": broupId
        }
      )
    );

    BaseResponse baseResponse = BaseResponse.fromJson(response.data);
    return baseResponse;
  }
}
