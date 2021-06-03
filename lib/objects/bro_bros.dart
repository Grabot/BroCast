import 'dart:ui';

class BroBros {

  int id;
  String chatName;
  String chatDescription;
  Color broColor;
  int unreadMessages;
  DateTime lastActivity;

  BroBros(
      int id,
      String chatName,
      String chatDescription,
      String chatColour,
      int unreadMessages,
      String lastActivity
      ) {
    this.id = id;
    this.chatName = chatName;
    this.chatDescription = chatDescription;
    if (chatColour != "") {
      this.broColor = Color(int.parse("0xFF$chatColour"));
    }
    this.unreadMessages = unreadMessages;
    if (lastActivity != null) {
      this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    } else {
      this.lastActivity = DateTime.now();
    }
  }
}