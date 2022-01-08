abstract class Bro {
  late int id;
  late int broupId;
  late int admin;
  late int added;

  Bro();

  String getFullName();
  bool isAdmin();
  bool isAdded();
  setAdmin(bool admin);

  copyBro();

  Map<String, dynamic> toDbMap();
  Bro.fromDbMap(Map<String, dynamic> map);
}
