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
  bool isMuted();
  bool isBroup();
}