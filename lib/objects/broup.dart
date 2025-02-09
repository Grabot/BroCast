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
  late int unreadMessages;
  late bool updateBroup;
  late bool newMessages;

  // We initialize variables with empty values
  // This is because the broup objects are updated later
  // This might cause an initialization error
  bool mute = false;
  bool left = false;
  Uint8List? avatar;
  // Chat details. Initialized with empty values
  List<int> broIds = [];
  List<int> adminIds = [];
  String broupName = "";
  String broupDescription = "";
  String alias = "";
  String broupColour = "";
  bool private = false;

  bool joinedBroupRoom = false;
  late List<int> messageIds;
  late List<Message> messages;
  late int lastMessageId;

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
      this.updateBroup,
      this.newMessages,
      this.avatar
      ) {
    messages = [];
    messageIds = [];
    lastMessageId = 0;
  }

  getBroupId() {
    return broupId;
  }

  setBroupColor(String newBroupColour) {
    this.broupColour = newBroupColour;
  }

  setBroupDescription(String newBroupDescription) {
    this.broupDescription = newBroupDescription;
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
    messageIds.add(message.messageId);
    messages.add(message);
  }

  Broup.fromJson(Map<String, dynamic> json) {
    // These 4 values should always be present
    broupId = json["broup_id"];
    unreadMessages = json["unread_messages"];
    updateBroup = json["broup_updated"];
    newMessages = json["new_messages"];
    // These might not be present
    alias = json.containsKey("alias") ? json["alias"] : "";
    broupName = json.containsKey("broup_name") ? json["broup_name"] : "";
    mute = json.containsKey("mute") ? json["mute"] : false;
    left = json.containsKey("left") ? json["left"] : false;
    // These are the core chat values. Stored in a coupling table on the server
    if (json.containsKey("chat")) {
      Map<String, dynamic> chat_details = json["chat"];
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
    messageIds = [];
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
    map['updateBroup'] = updateBroup ? 1 : 0;
    map['newMessages'] = newMessages ? 1 : 0;
    map['avatar'] = avatar;
    // Get the ids of all the messages in a list
    List<int> messageIds = messages.map((e) => e.messageId).toList();
    print("message ids $messageIds");
    map['messages'] = jsonEncode(messageIds);
    print("map $map");
    return map;
  }

  Broup.fromDbMap(Map<String, dynamic> map) {
    print("mapping broup from db");
    broupId = map['broupId'];

    List<dynamic> broIds = jsonDecode(map['broIds']);
    List<int> broIdList = broIds.map((s) => s as int).toList();
    this.broIds = broIdList;
    List<dynamic> broAdminsIds = jsonDecode(map['adminIds']);
    List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
    this.adminIds = broAdminIdList;

    broupName = map['broupName'];
    broupDescription = map['broupDescription'];
    alias = map['alias'];
    broupColour = map['broupColour'];
    unreadMessages = map['unreadMessages'];
    private = map['private'] == 1;
    mute = map['mute'] == 1;
    left = map['left'] == 1;
    // blocked = map['blocked'];
    lastMessageId = map['lastMessageId'];
    updateBroup = map['updateBroup'] == 1;
    newMessages = map['newMessages'] == 1;
    avatar = map['avatar'];
    List<dynamic> messageIds = jsonDecode(map['messages']);
    List<int> messageIdsList = messageIds.map((s) => s as int).toList();
    this.messageIds = messageIdsList;
    // this.messages = messageIdsList;
    // TODO: load the messages? Or load it only when the chat is opened?
    this.messages = [];
    print("retrieved from db $this");
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
      checkReceivedMessages(message);
    }
  }

  checkReceivedMessages(Message message) {
    print("checking unread messages");
    // We will check if the message we have just received is the
    // latest message that the bro had to retrieve.
    // We will compare the lastMessageId with the messageId of the message
    // If the message is 1 higher, the bro is up to date with all the messages
    // The bro still has not read anything so the unreadMessages will stay
    print("last message id $lastMessageId and message id ${message.messageId}");
    if (message.messageId == lastMessageId + 1) {
      // The bro is up to date with all the messages
      // We will increase the lastMessageId
      lastMessageId += 1;
      // If we have send the message, we have obviously received it
      // So no need to send the received update if the message was from us.
      if (message.senderId != Settings().getMe()!.getId()) {
        AuthServiceSocial().receivedMessage(broupId, lastMessageId).then((value) {
          if (value) {
            // The message that was received really was the last one so no update required
            newMessages = false;
            // Check if the user has the broup page open. if not send a notification
            if (BroMessagingChangeNotifier().getBroupId() == broupId) {
              readMessages();
            } else {
              unreadMessages++;
              // TODO: send notification?
            }
          } else {
            if (!newMessages) {
              newMessages = true;
              // TODO: If page is open do update immediately?
            }
          }
        });
      }
    } else {
      newMessages = true;
    }
  }

   updateLastReadMessages(String lastRead) {
    String lastReadTime = lastRead;
    if (!lastReadTime.endsWith("Z")) {
      lastReadTime = lastReadTime + "Z";
    }

    DateTime lastReadDateTime = DateTime.parse(lastReadTime).toLocal();
    // Go through the messages and set the isRead to 1 if the message is older than the lastReadDateTime
    for (Message message in messages) {
      if (!message.isInformation()) {
        if (message.isRead == 1) {
          break;
        }
        DateTime messageDateTime = message.getTimeStamp();
        if (messageDateTime.compareTo(lastReadDateTime) <= 0) {
          message.isRead = 1;
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
