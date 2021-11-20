import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat.dart';


class BroBros extends Chat {
  BroBros(int id, String chatName, String? chatDescription, String? alias, String chatColor,
      int unreadMessages, String lastActivity, String roomName, int blocked, int mute, int broup) {
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
    this.lastActivity = DateTime.parse(lastActivity + 'Z').toLocal();
    this.roomName = roomName;
    this.broup = broup;
  }

  Color getColor() {
    return Color(int.parse("0xFF${this.chatColor}"));
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
