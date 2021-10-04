import 'dart:ui';
import 'chat.dart';

class BroBros extends Chat {
  BroBros(int id, String chatName, String chatDescription, String chatColour,
      int unreadMessages, String lastActivity, String roomName, bool blocked, bool isBroup) {
    this.id = id;
    this.chatName = chatName;
    this.chatDescription = chatDescription;
    if (chatColour != "") {
      this.chatColor = Color(int.parse("0xFF$chatColour"));
    }
    if (blocked) {
      this.chatColor = Color(int.parse("0xFF000000"));
    }
    this.unreadMessages = unreadMessages;
    this.blocked = blocked;
    if (lastActivity != null) {
      this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    } else {
      this.lastActivity = DateTime.now();
    }
    this.roomName = roomName;
    this.isBroup = isBroup;
  }
}
