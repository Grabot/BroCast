class User {

  late int id;
  late String broName;
  late String bromotion;
  late String password;
  late String token;
  String? registrationId;
  late int recheckBros;
  late int keyboardDarkMode;
  late String lastTimeActive;

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
    this.lastTimeActive = DateTime.now().toUtc().toString();
  }

  void updateActivityTime() {
    this.lastTimeActive = DateTime.now().toUtc().toString();
  }

  bool getKeyboardDarkMode() {
    return this.keyboardDarkMode == 1;
  }

  bool shouldRecheck() {
    // If the last activity time is longer than an hour ago we will recheck
    if (DateTime.parse(lastTimeActive).toLocal().isBefore(DateTime.now().subtract(Duration(hours: 1)))) {
      updateActivityTime();
      recheckBros = 1;
    }
    return recheckBros == 1;
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
    map['lastTimeActive'] = lastTimeActive;
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
    lastTimeActive = map['lastTimeActive'];
  }

}
