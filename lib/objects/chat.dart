import 'dart:ui';

abstract class Chat {

  int id;
  DateTime lastActivity;
  String roomName;
  String chatName;
  String chatDescription;
  String alias;
  String chatColor;
  int unreadMessages;
  int blocked;
  int mute;
  int broup;

  Chat();

  String getBroNameOrAlias();
  Color getColor();

  bool isBlocked();
  setBlocked(bool blocked);
  bool isMuted();
  setMuted(bool muted);
  bool isBroup();
  setBroup(bool broup);
}