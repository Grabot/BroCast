import 'dart:ui';

abstract class Bro {
  late int id;
  late Color broColor;
  late bool admin;
  late bool added;

  Bro();

  String getFullName();
  bool isAdmin();
  bool isAdded();
  setAdmin(bool admin);

  copyBro();
}
