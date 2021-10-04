import 'dart:ui';

import 'chat.dart';

class Broup extends Chat {

  Broup(int id, String broupName, String broupDescription, String broupColor,
      int unreadMessages, String lastActivity, String roomName, bool blocked, bool isBroup) {
    this.id = id;
    this.chatName = broupName;
    this.chatDescription = broupDescription;
    if (broupColor != "") {
      this.chatColor = Color(int.parse("0xFF$broupColor"));
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
