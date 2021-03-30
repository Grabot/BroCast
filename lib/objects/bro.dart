import 'dart:math' as math;

import 'dart:ui';

class Bro {

  int id;
  String broName;
  String bromotion;
  Color broColor;

  Bro(
    int id,
    String broName,
    String bromotion
  ) {
    this.id = id;
    this.broName = broName;
    this.bromotion = bromotion;
    broColor = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  String getFullBroName() {
    return "$broName $bromotion";
  }
}