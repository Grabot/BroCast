import 'dart:convert';
import 'dart:typed_data';

import 'package:brocast/utils/socket_services.dart';

import '../views/bro_home/bro_home_change_notifier.dart';
import 'bro.dart';
import 'broup.dart';

class Me extends Bro {
  late int id;
  late String broName;
  late String bromotion;
  late bool origin;
  Uint8List? avatar;
  late List<Broup> broups;
  bool avatarDefault = true;

  Me(this.id, this.broName, this.bromotion, this.origin, this.avatar, this.broups)
      : super(id, broName, bromotion, avatar);

  getId() {
    return id;
  }

  setBroName(String broName) {
    this.broName = broName;
  }

  String getBroName() {
    return this.broName;
  }

  setBromotion(String bromotion) {
    this.bromotion = bromotion;
  }

  String getBromotion() {
    return this.bromotion;
  }

  setAvatar(Uint8List avatar) {
    this.avatar = avatar;
  }

  setAvatarDefault(bool avatarDefault) {
    this.avatarDefault = avatarDefault;
  }

  Uint8List? getAvatar() {
    return this.avatar;
  }

  addBroup(Broup broup) {
    broups.add(broup);
    SocketServices().joinRoomBroup(broup.broupId);
  }

  Me.fromJson(Map<String, dynamic> json)
      : super(json["id"], json["bro_name"], json["bromotion"], null) {
    id = json["id"];
    broName = json["bro_name"];
    bromotion = json["bromotion"];
    origin = json["origin"];
    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
    if (json.containsKey("avatar_default") && json["avatar_default"] != null) {
      avatarDefault = json["avatar_default"];
    }
    broups = [];
    if (json.containsKey("broups")) {
      for (var bro in json["broups"]) {
        broups.add(Broup.fromJson(bro));
      }
    }
    BroHomeChangeNotifier().notify();
  }
}
