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

  Future<String> changeBroname(String broname) async {
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
      return "Something went wrong";
    } else {
      if (json["result"]) {
        // TODO: actually change broname
        return "Broname changed";
      } else {
        if (json.containsKey("message")) {
          return json["message"];
        }
        return "Something went wrong, broname not changed";
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
}
