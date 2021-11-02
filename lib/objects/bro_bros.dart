import 'dart:ui';
import 'chat.dart';

class BroBros extends Chat {
  BroBros(int id, String chatName, String chatDescription, String alias, String chatColour,
      int unreadMessages, String lastActivity, String roomName, bool blocked, bool mute, bool isBroup) {
    this.id = id;
    this.chatName = chatName;
    this.chatDescription = chatDescription;
    this.alias = alias;
    if (chatColour != "") {
      this.chatColor = Color(int.parse("0xFF$chatColour"));
    }
    this.unreadMessages = unreadMessages;
    this.blocked = blocked;
    this.mute = mute;
    if (lastActivity != null) {
      this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    } else {
      this.lastActivity = DateTime.now();
    }
    this.roomName = roomName;
    this.isBroup = isBroup;
  }

  @override
  String getBroNameOrAlias() {
    if (this.alias != null && this.alias.isNotEmpty) {
      return this.alias;
    } else {
      return this.chatName;
    }
  }
}
