import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../objects/new/bro.dart';
import '../../objects/new/broup.dart';
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
        Broup newBroup = Broup.fromJson(json["broup"]);
        return true;
      } else {
        // Will this be possible, will we account for it?
        return false;
      }
    }
  }

}