class User {

  late int id;
  late String broName;
  late String bromotion;
  late String password;
  late String token;
  String? registrationId;
  late int recheckBros;
  late int keyboardDarkMode;

  User(
      int id,
      String broName,
      String bromotion,
      String password,
      String token,
      String? registrationId,
      int recheckBros,
      int keyboardDarkMode
    ) {
    this.id = id;
    this.broName = broName;
    this.bromotion = bromotion;
    this.password = password;
    this.token = token;
    this.registrationId = registrationId;
    this.recheckBros = recheckBros;
    this.keyboardDarkMode = keyboardDarkMode;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['broName'] = broName;
    map['bromotion'] = bromotion;
    map['password'] = password;
    map['token'] = token;
    map['registrationId'] = registrationId;
    map['recheckBros'] = recheckBros;
    map['keyboardDarkMode'] = keyboardDarkMode;
    return map;
  }

  User.fromDbMap(Map<String, dynamic> map) {
    id = map['id'];
    broName = map['broName'];
    bromotion = map['bromotion'];
    password = map['password'];
    token = map['token'];
    registrationId = map['registrationId'];
    recheckBros = map['recheckBros'];
    keyboardDarkMode = map['keyboardDarkMode'];
  }

  bool getKeyboardDarkMode() {
    return this.keyboardDarkMode == 1;
  }

  bool shouldRecheck() {
    return recheckBros == 1;
  }

}
