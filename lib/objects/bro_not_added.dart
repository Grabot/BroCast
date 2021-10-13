import 'dart:math' as math;

import 'dart:ui';

import 'bro.dart';

class BroNotAdded extends Bro {

  String broName;
  String bromotion;

  BroNotAdded(int id, String broName, String bromotion) {
    this.id = id;
    this.broName = broName;
    this.bromotion = bromotion;
    broColor =
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  String getFullName() {
    return "$broName $bromotion";
  }
}