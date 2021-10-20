import 'dart:ui';

import 'bro.dart';
import 'chat.dart';

class Broup extends Chat {

  List<int> participants = [];
  List<Bro> broupBros = [];

  Broup(int id, String broupName, String broupDescription, String alias, String broupColor,
      int unreadMessages, String lastActivity, String roomName, bool blocked, bool isBroup) {
    this.id = id;
    this.chatName = broupName;
    this.chatDescription = broupDescription;
    this.alias = alias;
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

  void setParticipants(List<int> participants) {
    this.participants = participants;
  }

  List<int> getParticipants() {
    return this.participants;
  }

  void setBroupBros(List<Bro> broupBros) {
    this.broupBros = broupBros;
  }

  List<Bro> getBroupBros() {
    return this.broupBros;
  }
}
