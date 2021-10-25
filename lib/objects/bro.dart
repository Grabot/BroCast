import 'dart:ui';

abstract class Bro {
  int id;
  Color broColor;
  bool admin;

  Bro();

  String getFullName();
  bool isAdmin();
  setAdmin(bool admin);
}
