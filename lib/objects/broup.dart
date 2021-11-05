import 'dart:ui';

import 'bro.dart';
import 'chat.dart';

class Broup extends Chat {

  List<int> participants = [];
  List<int> admins = [];
  List<Bro> broupBros = [];

  bool meAdmin = false;

  Broup(int id, String broupName, String broupDescription, String alias, String broupColor,
      int unreadMessages, String lastActivity, String roomName, bool blocked, bool mute, bool isBroup) {
    this.id = id;
    this.chatName = broupName;
    this.chatDescription = broupDescription;
    this.alias = alias;
    if (broupColor != null && broupColor != "") {
      this.chatColor = Color(int.parse("0xFF$broupColor"));
    } else {
      this.chatColor = null;
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

  void setParticipants(List<int> participants) {
    this.participants = participants;
  }

  List<int> getParticipants() {
    return this.participants;
  }

  void setAdmins(List<int> admins) {
    this.admins = admins;
  }

  List<int> getAdmins() {
    return this.admins;
  }

  void addAdmin(int newAdmin) {
    if (!this.admins.contains(newAdmin)) {
      this.admins.add(newAdmin);
    }
  }

  void dismissAdmin(int oldAdmin) {
    if (this.admins.contains(oldAdmin)) {
      this.admins.remove(oldAdmin);
    }
  }

  void setBroupBros(List<Bro> broupBros) {
    this.broupBros = broupBros;
  }

  List<Bro> getBroupBros() {
    return this.broupBros;
  }

  void setAmIAdmin(bool meAdmin) {
    this.meAdmin = meAdmin;
  }

  bool amIAdmin() {
    return meAdmin;
  }

  String getchatDescription() {
    return this.chatDescription;
  }

  void setChatDescription(String description) {
    this.chatDescription = description;
  }

  String getChatName() {
    return this.chatName;
  }

  void setChatName(String chatName) {
    this.chatName = chatName;
  }

  void addBro(Bro addBro) {
    if (!this.broupBros.contains(addBro)) {
      this.broupBros.add(addBro);
    }
  }

  void removeBro(int oldBro) {
    if (this.participants.contains(oldBro)) {
      this.participants.remove(oldBro);
      for (Bro bro in broupBros) {
        if (bro.id == oldBro) {
          broupBros.remove(bro);
          return;
        }
      }
    }
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
