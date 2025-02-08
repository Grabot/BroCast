import 'dart:convert';
import 'dart:typed_data';

import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/new/settings.dart';
import '../views/chat_view/bro_messaging/bro_messaging_change_notifier.dart';

class Broup {
  late int broupId;
  late List<int> broIds;
  late List<int> adminIds;
  late String broupName;
  late String broupDescription;
  late String alias;
  late String broupColour;
  late int unreadMessages;
  late bool private;
  late bool mute;
  late bool left;
  Uint8List? avatar;
  bool joinedBroupRoom = false;
  late List<Message> messages;
  late int lastMessageId;
  bool updateBroup = false;

  Broup(
      this.broupId,
      this.broIds,
      this.adminIds,
      this.broupName,
      this.broupDescription,
      this.alias,
      this.broupColour,
      this.unreadMessages,
      this.mute,
      this.private,
      this.left,
      this.avatar
      ) {
    messages = [];
    lastMessageId = 0;
  }

  getBroupId() {
    return broupId;
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
    return left;
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

  addMessage(Message message) {
    messages.add(message);
  }

  Broup.fromJson(Map<String, dynamic> json) {
    alias = json["alias"];
    broupName = json["broup_name"];
    unreadMessages = json["unread_messages"];
    mute = json["mute"];
    left = json["left"];
    // These are the core chat values. Stored in a coupling table on the server
    if (json.containsKey("chat")) {
      Map<String, dynamic> chat_details = json["chat"];
      broupId = chat_details["broup_id"];
      broupDescription = chat_details["broup_description"];
      broupColour = chat_details["broup_colour"];
      private = chat_details["private"];
      broIds = chat_details["bro_ids"].cast<int>();
      adminIds = chat_details["admin_ids"].cast<int>();
      if (chat_details.containsKey("avatar") && chat_details["avatar"] != null) {
        avatar = base64Decode(chat_details["avatar"].replaceAll("\n", ""));
      }
    }
    messages = [];
    lastMessageId = 0;
  }

  Map<String, dynamic> toDbMap() {
    print("mapping broup");
    var map = Map<String, dynamic>();
    map['broupId'] = broupId;
    map['broIds'] = jsonEncode(broIds);
    map['adminIds'] = jsonEncode(adminIds);
    map['broupName'] = broupName;
    map['broupDescription'] = broupDescription;
    map['alias'] = alias;
    map['broupColour'] = broupColour;
    map['unreadMessages'] = unreadMessages;
    map['private'] = private ? 1 : 0;
    map['mute'] = mute ? 1 : 0;
    map['left'] = left ? 1 : 0;
    map['blocked'] = 0;
    map['lastMessageId'] = lastMessageId;
    map['avatar'] = avatar;
    map['updateBroup'] = updateBroup ? 1 : 0;
    // Get the ids of all the messages in a list
    List<int> messageIds = messages.map((e) => e.messageId).toList();
    print("message ids $messageIds");
    map['messages'] = jsonEncode(messageIds);
    print("map $map");
    return map;
  }

  updateDateTiles(Message message) {
    // If the day tiles need to be updated after sending a message it will be the today tile.
    if (this.messages.length == 0) {
      Message timeMessage = new Message(
        0,
        0,
        "Today",
        "",
        DateTime.now().toUtc().toString(),
        null,
        true,
        getBroupId(),
      );
      this.messages.insert(0, timeMessage);
    } else {
      Message messageFirst = this.messages.first;
      DateTime dayFirst = DateTime(messageFirst.getTimeStamp().year,
          messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
      String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

      DateTime current = message.getTimeStamp();
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

        Message timeMessage = new Message(
          0,
          0,
          "Today",
          "",
          DateTime.now().toUtc().toString(),
          null,
          true,
          getBroupId(),
        );
        this.messages.insert(0, timeMessage);
      }
    }
  }

  updateMessages(Message message) {
    if (!message.isInformation() && message.senderId == Settings().getMe()!.getId() && message.data == null) {
      // We added it immediately as a placeholder.
      // When we get it from the server we add it for real and remove the placeholder
      // Do a few simple extra checks, like body comparison
      if (messages[0] == message) {
        this.messages.removeAt(0);
      }
    }
    updateDateTiles(message);
    // `isRead` 0 indicates it was successfully send to the server
    message.isRead = 0;
    this.messages.insert(0, message);
    // TODO: add messages to storage?
    // storage.addMessage(message).then((value) {
    //   // stored the message
    // });
    if (!message.isInformation()) {
      // updateUserActivity(message.timestamp);
    }
  }

  checkReceivedMessages(Message message) {
    print("checking unread messages");
    // We will check if the message we have just received is the
    // latest message that the bro had to retrieve.
    // We will compare the lastMessageId with the messageId of the message
    // If the message is 1 higher, the bro is up to date with all the messages
    // The bro still has not read anything so the unreadMessages will stay
    // TODO: Fix the messageId check
    if (message.messageId == lastMessageId + 1) {
      // The bro is up to date with all the messages
      // We will increase the lastMessageId
      lastMessageId += 1;
      // TODO: update broups in local storage
      // If we have send the message, we have obviously received it
      // So no need to send the received update if the message was from us.
      if (message.senderId != Settings().getMe()!.getId()) {
        AuthServiceSocial().receivedMessage(broupId, lastMessageId).then((value) {
          if (value) {
            // The message that was received really was the last one so no update required
            updateBroup = false;
          } else {
            // TODO: update messages? Or only when chat is openend?
            updateBroup = true;
          }
        });
      }

    } else {
      updateBroup = true;
    }
  }

  updateLastReadMessages(String lastRead) {
    String lastReadTime = lastRead;
    if (!lastReadTime.endsWith("Z")) {
      lastReadTime = lastReadTime + "Z";
    }

    DateTime lastReadDateTime = DateTime.parse(lastReadTime);
    // Go through the messages and set the isRead to 1 if the message is older than the lastReadDateTime
    for (Message message in messages) {
      DateTime messageDateTime = message.getTimeStamp();
      if (messageDateTime.isBefore(lastReadDateTime)) {
        message.isRead = 1;
      } else {
        if (message.isRead == 1) {
          // We have reached the last read message
          // We assume that every message after this one is also set to read
          break;
        }
      }
    }
  }

  readMessages() {
    AuthServiceSocial().readMessages(getBroupId()).then((value) {
      if (value) {
        // messages read
      }
    });
  }
}
