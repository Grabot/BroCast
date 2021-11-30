import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'bro.dart';
import 'chat.dart';


class Broup extends Chat {

  List<int> participants = [];
  List<int> admins = [];
  List<Bro> broupBros = [];

  late int left;

  Broup(
      int id,
      String broupName,
      String? broupDescription,
      String? alias,
      String chatColor,
      int unreadMessages,
      String lastActivity,
      String roomName,
      int blocked,
      int mute,
      int broup,
      int left
    ) {
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
    // We send the utc time, but to make sure flutter gets the same time
    // we have to add the utc indicator for flutter DateTime
    this.lastActivity = lastActivity + 'Z';
    this.roomName = roomName;
    this.broup = broup;
    this.left = left;
  }

  bool hasLeft() {
    return left == 1;
  }

  DateTime getLastActivity() {
    return DateTime.parse(lastActivity).toLocal();
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
  setMuted(bool muted) {
    if (muted) {
      this.mute = 1;
    } else {
      this.mute = 0;
    }
  }

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
    map['left'] = left;
    map['isBroup'] = 1;
    map['participants'] = jsonEncode(participants);
    map['admins'] = jsonEncode(admins);
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
    left = map['left'];
    broup = 1;

    List<dynamic> broIds = jsonDecode(map['participants']);
    List<int> broIdList = broIds.map((s) => s as int).toList();
    this.participants = broIdList;
    List<dynamic> broAdminsIds = jsonDecode(map['admins']);
    List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
    this.admins = broAdminIdList;
  }
}
