import 'dart:convert';
import 'dart:typed_data';

import '../views/bro_home/bro_home_change_notifier.dart';
import 'broup.dart';

class Me {
  late int id;
  late String broName;
  late String bromotion;
  late bool origin;
  Uint8List? avatar;
  late List<Broup> bros;

  Me(this.id, this.broName, this.bromotion, this.origin, this.avatar, this.bros);

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

  Uint8List? getAvatar() {
    return this.avatar;
  }

  Me.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    broName = json["bro_name"];
    bromotion = json["bromotion"];
    origin = json["origin"];
    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
    bros = [];
    if (json.containsKey("broups")) {
      for (var bro in json["broups"]) {
        bros.add(Broup.fromJson(bro));
      }
    }
    BroHomeChangeNotifier().notify();
  }
}
