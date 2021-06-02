import 'dart:ui';

class BroBros {

  int id;
  String chatName;
  Color broColor;
  int unreadMessages;

  BroBros(
      int id,
      String chatName,
      String chatColour,
      int unreadMessages
      ) {
    this.id = id;
    this.chatName = chatName;
    this.broColor = Color(int.parse("0xFF$chatColour"));
    this.unreadMessages = unreadMessages;
  }
}