import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat.dart';


class BroBros extends Chat {
  BroBros(int id, String chatName, String chatDescription, String alias, String chatColor,
      int unreadMessages, String lastActivity, String roomName, int blocked, int mute, int broup) {
    this.id = id;
    this.chatName = chatName;
    this.chatDescription = chatDescription;
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
    return false;
  }

  @override
  bool isMuted() {
    return this.mute == 1;
  }
}
