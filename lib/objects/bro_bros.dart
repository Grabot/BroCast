import 'dart:ui';

class BroBros {
  int id;
  String chatName;
  String chatDescription;
  Color broColor;
  int unreadMessages;
  DateTime lastActivity;
  bool blocked;

  BroBros(int id, String chatName, String chatDescription, String chatColour,
      int unreadMessages, String lastActivity, bool blocked) {
    this.id = id;
    this.chatName = chatName;
    this.chatDescription = chatDescription;
    if (chatColour != "") {
      this.broColor = Color(int.parse("0xFF$chatColour"));
    }
    if (blocked) {
      this.broColor = Color(int.parse("0xFF000000"));
    }
    this.unreadMessages = unreadMessages;
    this.blocked = blocked;
    if (lastActivity != null) {
      this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    } else {
      this.lastActivity = DateTime.now();
    }
  }
}
