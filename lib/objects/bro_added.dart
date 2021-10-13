import 'dart:math' as math;

import 'dart:ui';

import 'bro.dart';

class BroAdded extends Bro {

  String chatName;

  BroAdded(int id, String chatName) {
    this.id = id;
    this.chatName = chatName;
    broColor =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  String getFullName() {
    return "$chatName";
  }
}
