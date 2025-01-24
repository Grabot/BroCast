import 'bro.dart';

class BroAdded extends Bro {
  late String chatName;

  BroAdded(int id, int broupId, String chatName) {
    this.id = id;
    this.broupId = broupId;
    this.chatName = chatName;
    admin = 0;
    added = 1;
  }

  setFullName(String chatName) {
    this.chatName = chatName;
  }

  @override
  String getFullName() {
    return "$chatName";
  }

  @override
  bool isAdmin() {
    return admin == 1;
  }

  @override
  setAdmin(bool admin) {
    this.admin = admin ? 1 : 0;
  }

  @override
  bool isAdded() {
    return added == 0;
  }

  BroAdded copyBro({int? id, int? broupId, String? chatName}) => BroAdded(
        id ?? this.id,
        broupId ?? this.broupId,
        chatName ?? this.chatName,
      );

  @override
  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['broId'] = id;
    map['broupId'] = broupId;
    map['admin'] = admin;
    map['added'] = added;
    map['chatName'] = chatName;
    map['broName'] = ""; // Only for BroNotAdded
    map['bromotion'] = ""; // Only for BroNotAdded
    return map;
  }

  BroAdded.fromDbMap(Map<String, dynamic> map) {
    id = map['broId'];
    broupId = map['broupId'];
    admin = map['admin'];
    added = map['added'];
    chatName = map['chatName'];
    // map['broName']; // Only for BroNotAdded
    // map['bromotion']; // Only for BroNotAdded
  }
}
