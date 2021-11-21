import 'dart:ui';

abstract class Chat {

  late int id;
  late String lastActivity;
  late String roomName;
  late String chatName;
  late String chatDescription;
  late String alias;
  late String chatColor;
  late int unreadMessages;
  late int blocked;
  late int mute;
  late int broup;

  Chat();

  String getBroNameOrAlias();
  Color getColor();

  bool isBlocked();
  setBlocked(bool blocked);
  bool isMuted();
  setMuted(bool muted);
  bool isBroup();
  setBroup(bool broup);
  DateTime getLastActivity();

  Map<String, dynamic> toDbMap();
  Chat.fromDbMap(Map<String, dynamic> map);
}