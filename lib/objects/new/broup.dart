import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Broup {
  late int id;
  late List<int> broIds;
  late List<int> adminIds;
  late String broupName;
  late String broupDescription;
  late String alias;
  late String broupColour;
  late int unreadMessages;
  late String lastTimeActivity;
  late bool private;
  late bool mute;
  late bool isLeft;
  Uint8List? avatar;

  Broup(
      this.id,
      this.broIds,
      this.adminIds,
      this.broupName,
      this.broupDescription,
      this.alias,
      this.broupColour,
      this.unreadMessages,
      this.lastTimeActivity,
      this.mute,
      this.private,
      this.isLeft,
      this.avatar
      ) {
    if (lastTimeActivity.endsWith("Z")) {
      this.lastTimeActivity = lastTimeActivity;
    } else {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      this.lastTimeActivity = lastTimeActivity + "Z";
    }
  }

  getId() {
    return id;
  }

  setAvatar(Uint8List avatar) {
    this.avatar = avatar;
  }

  Uint8List? getAvatar() {
    return this.avatar;
  }

  bool isPrivate() {
    return private;
  }

  Color getColor() {
    return Color(int.parse("0xFF${this.broupColour}"));
  }

  bool isMuted() {
    return mute;
  }

  bool hasLeft() {
    return isLeft;
  }

  bool isBlocked() {
    // TODO: add blocked?
    return false;
  }

  String getBroupNameOrAlias() {
    if (alias.isEmpty) {
      return broupName;
    } else {
      return alias;
    }
  }

  String getBroupName() {
    return broupName;
  }

  String getBroupDescription() {
    return broupDescription;
  }

  Broup.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    broIds = json["bro_ids"].cast<int>();
    adminIds = json["admin_ids"].cast<int>();
    broupName = json["broup_name"];
    broupDescription = json["broup_description"];
    alias = json["alias"];
    broupColour = json["broup_colour"];
    unreadMessages = json["unread_messages"];
    lastTimeActivity = json["last_time_activity"];
    private = json["private"];
    mute = json["mute"];
    isLeft = json["left"];
    if (json.containsKey("avatar") && json["avatar"] != null) {
      avatar = base64Decode(json["avatar"].replaceAll("\n", ""));
    }
  }
}
