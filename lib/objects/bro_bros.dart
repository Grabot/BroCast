import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat.dart';


class BroBros extends Chat {
  BroBros(
      int id,
      String chatName,
      String? chatDescription,
      String? alias,
      String chatColor,
      int unreadMessages,
      String lastActivity,
      String roomName,
      int blocked,
      int mute,
      int broup
    ) {
    this.id = id;
    this.chatName = chatName;
    if (chatDescription == null) {
      this.chatDescription = "";
    } else {
      this.chatDescription = chatDescription;
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
  }

  DateTime getLastActivity() {
    return DateTime.parse(lastActivity).toLocal();
  }

  Color getColor() {
    return Color(int.parse("0xFF${this.chatColor}"));
  }

  void updateActivityTime() {
    this.lastActivity = DateTime.now().toString();
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
    return false;
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

  @override
  bool hasLeft() {
    return false;
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
    map['isBroup'] = 0;
    return map;
  }


  BroBros.fromDbMap(Map<String, dynamic> map) {
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
    broup = 0;
  }
}
