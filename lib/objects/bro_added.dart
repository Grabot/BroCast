import 'dart:math' as math;

import 'dart:ui';

import 'bro.dart';

class BroAdded extends Bro {

  late String chatName;

  BroAdded(int id, String chatName) {
    this.id = id;
    this.chatName = chatName;
    broColor =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    admin = false;
    added = true;
  }

  @override
  String getFullName() {
    return "$chatName";
  }

  @override
  bool isAdmin() {
    return admin;
  }

  @override
  setAdmin(bool admin) {
    this.admin = admin;
  }

  @override
  bool isAdded() {
    return this.added;
  }

  BroAdded copyBro({
    int? id,
    String? chatName
  }) => BroAdded(
    id ?? this.id,
    chatName ?? this.chatName,
  );
}
