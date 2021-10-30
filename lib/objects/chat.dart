import 'dart:ui';

abstract class Chat {

  int id;
  DateTime lastActivity;
  String roomName;
  String chatName;
  String chatDescription;
  String alias;
  Color chatColor;
  int unreadMessages;
  bool blocked;
  bool isBroup;

  Chat();

  String getBroNameOrAlias();
}