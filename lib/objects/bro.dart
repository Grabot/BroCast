import 'dart:ui';

abstract class Bro {
  int id;
  Color broColor;
  bool admin;
  bool added;

  Bro();

  String getFullName();
  bool isAdmin();
  bool isAdded();
  setAdmin(bool admin);

  copyBro();
}
