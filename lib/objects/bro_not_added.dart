
import 'bro.dart';

class BroNotAdded extends Bro {

  late String broName;
  late String bromotion;

  BroNotAdded(
      int id,
      int broupId,
      String broName,
      String bromotion
    ) {
    this.id = id;
    this.broupId = broupId;
    this.broName = broName;
    this.bromotion = bromotion;
    admin = 0;
    added = 0;
  }

  @override
  String getFullName() {
    return "$broName $bromotion";
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
    return added == 1;
  }

  @override
  BroNotAdded copyBro({
    int? id,
    int? broupId,
    String? broName,
    String? bromotion
  }) => BroNotAdded(
    id ?? this.id,
    broupId ?? this.broupId,
    broName ?? this.broName,
    bromotion ?? this.bromotion,
  );

  @override
  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['broId'] = id;
    map['broupId'] = broupId;
    map['admin'] = admin;
    map['added'] = added;
    map['chatName'] = ""; // Only for BroAdded
    map['broName'] = broName;
    map['bromotion'] = bromotion;
    return map;
  }

  BroNotAdded.fromDbMap(Map<String, dynamic> map) {
    id = map['broId'];
    broupId = map['broupId'];
    admin = map['admin'];
    added = map['added'];
    // map['chatName']; // Only for BroAdded
    broName = map['broName'];
    bromotion = map['bromotion'];
  }
}
