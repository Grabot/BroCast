import 'dart:ui';
import 'package:flutter/material.dart';
import 'bro.dart';
import 'chat.dart';


class Broup extends Chat {

  List<int> participants = [];
  List<int> admins = [];
  List<Bro> broupBros = [];

  bool meAdmin = false;

  Broup(int id, String broupName, String? broupDescription, String? alias, String chatColor,
      int unreadMessages, String lastActivity, String roomName, int blocked, int mute, int broup) {
    this.id = id;
    this.chatName = broupName;
    if (broupDescription == null) {
      this.chatDescription = "";
    } else {
      this.chatDescription = broupDescription;
    }
    if (alias == null) {
      this.alias = "";
    } else {
      this.alias = alias;
    }
    this.chatColor = chatColor;
    this.unreadMessages = unreadMessages;
    this.blocked = blocked;
    this.mute = mute;
    this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    this.roomName = roomName;
    this.broup = broup;
  }

  Color getColor() {
    return Color(int.parse("0xFF${this.chatColor}"));
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
    if (this.alias != "") {
      return this.alias;
    } else {
      return this.chatName;
    }
  }

  @override
  bool isBlocked() {
    return this.blocked == 1;
  }

  @override
  bool isBroup() {
    return true;
  }

  @override
  bool isMuted() {
    return this.mute == 1;
  }

  @override
  setBlocked(bool blocked) {
    if (blocked) {
      this.blocked = 1;
    } else {
      this.blocked = 0;
    }
  }

  @override
  setBroup(bool broup) {
    if (broup) {
      this.broup = 1;
    } else {
      this.broup = 0;
    }
  }

  @override
  setMuted(bool muted) {
    if (muted) {
      this.mute = 1;
    } else {
      this.mute = 0;
    }
  }

  // TODO: @Skools add the participants?
  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['chatId'] = id;
    map['lastActivity'] = lastActivity;
    map['chatName'] = chatName;
    map['chatDescription'] = chatDescription;
    map['alias'] = alias;
    map['chatColor'] = chatColor;
    map['roomName'] = roomName;
    map['unreadMessages'] = unreadMessages;
    map['blocked'] = blocked;
    map['mute'] = mute;
    map['isBroup'] = broup; // probably true, but set anyway
    return map;
  }

  Broup.fromDbMap(Map<String, dynamic> map) {
    id = map['chatId'];
    chatName = map['chatName'];
    chatDescription = map['chatDescription'];
    alias = map['alias'];
    chatColor = map['chatColor'];
    unreadMessages = map['unreadMessages'];
    lastActivity = map['lastActivity'];
    roomName = map['roomName'];
    blocked = map['blocked'];
    mute = map['mute'];
    broup = map['isBroup']; // probably true, but get from map anyway
  }
}
