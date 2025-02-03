import 'dart:convert';
import 'dart:typed_data';

class Bro {
  late int id;
  late String broName;
  late String bromotion;
  Uint8List? avatar;

  Bro(this.id, this.broName, this.bromotion, this.avatar);

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

  String getFullName() {
    return this.broName + " " + this.bromotion;
  }

  setAvatar(Uint8List avatar) {
    this.avatar = avatar;
  }

  Uint8List? getAvatar() {
    return this.avatar;
  }

  Bro.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    broName = json["bro_name"];
    bromotion = json["bromotion"];
    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
  }
}
