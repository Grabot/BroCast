import 'dart:ui';
import 'package:flutter/material.dart';
import 'bro.dart';
import 'chat.dart';


class Broup extends Chat {

  List<int> participants = [];
  List<int> admins = [];
  List<Bro> broupBros = [];

  bool meAdmin = false;

  Broup(int id, String broupName, String broupDescription, String alias, String chatColor,
      int unreadMessages, String lastActivity, String roomName, int blocked, int mute, int broup) {
    this.id = id;
    this.chatName = broupName;
    this.chatDescription = broupDescription;
    this.alias = alias;
    this.chatColor = chatColor;
    this.unreadMessages = unreadMessages;
    this.blocked = blocked;
    this.mute = mute;
    if (lastActivity != null) {
      this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    } else {
      this.lastActivity = DateTime.now();
    }
    this.roomName = roomName;
    this.broup = broup;
  }

  Color getColor() {
    if (this.chatColor == null) {
      return Colors.black;
    } else {
      return Color(int.parse("0xFF${this.chatColor}"));
    }
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
}
