class Bro {

  int id;
  String broName;
  String bromotion;

  Bro(
    int id,
    String broName,
    String bromotion
  ) {
    this.id = id;
    this.broName = broName;
    this.bromotion = bromotion;
  }

  String getFullBroName() {
    return "$broName $bromotion";
  }
}