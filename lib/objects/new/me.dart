import 'dart:convert';
import 'dart:typed_data';

class Me {
  late int id;
  late String broName;
  late String bromotion;
  late bool origin;
  Uint8List? avatar;

  Me(this.id, this.broName, this.bromotion, this.origin, this.avatar);

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
    if (json.containsKey("avatar")) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
  }
}
