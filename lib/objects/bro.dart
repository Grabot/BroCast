import 'dart:convert';
import 'dart:typed_data';

class Bro {
  late int id;
  late String broName;
  late String bromotion;
  Uint8List? avatar;
  bool updateBro = false;
  bool added = false;  // If the bro has a private chat with the user

  Bro(this.id, this.broName, this.bromotion, this.added, this.avatar, this.updateBro);

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
    updateBro = json.containsKey("update_bro") ? json["update_bro"] : false;
    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
    added = false;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['broId'] = id;
    map['broName'] = broName;
    map['bromotion'] = bromotion;
    map["added"] = added ? 1 : 0;
    map['updateBro'] = updateBro ? 1 : 0;
    map['avatar'] = avatar;
    return map;
  }

  Bro.fromDbMap(Map<String, dynamic> map) {
    id = map['broId'];
    broName = map['broName'];
    bromotion = map['bromotion'];
    added = map['added'] == 1;
    updateBro = map['updateBro'] == 1;
    avatar = map['avatar'];
  }
}
