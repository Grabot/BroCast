import 'dart:convert';
import 'dart:typed_data';

import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/new/settings.dart';
import '../utils/new/storage.dart';
import '../views/chat_view/message_util.dart';
import '../views/chat_view/messaging_change_notifier.dart';
import 'bro.dart';

class Broup {
  late int broupId;
  late int unreadMessages;
  late bool updateBroup;
  late bool newMessages;

  // We initialize variables with empty values
  // This is because the broup objects are updated later
  // This might cause an initialization error
  bool mute = false;
  bool deleted = false;
  bool removed = false;
  Uint8List? avatar;
  late List<Bro> broupBros;
  // Chat details. Initialized with empty values
  List<int> broIds = [];
  List<int> adminIds = [];
  String broupName = "";
  String broupDescription = "";
  String alias = "";
  String broupColour = "";
  bool private = false;

  // Simple solution to not add multiple "today" message tiles
  // And to not retrieve the Bro objects from the db multiple times
  bool todayTileAdded = false;
  bool retrievedBros = false;

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
      this.deleted,
      this.updateBroup,
      this.newMessages,
      this.avatar
      ) {
    broupBros = [];
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

  bool isRemoved() {
    return removed;
  }

  newMembersBroup() {
    retrievedBros = false;
  }

  String getBroupNameOrAlias() {
    if (alias.isEmpty) {
      if (private) {
        for (Bro bro in broupBros) {
          if (bro.getId() != Settings().getMe()!.getId()) {
            return bro.getFullName();
          }
        }
        return "";
      } else {
        return broupName;
      }
    } else {
      return alias;
    }
  }

  List<int> getBroIds() {
    return broIds;
  }



  addAdminId(int adminId) {
    if (!adminIds.contains(adminId)) {
      adminIds.add(adminId);
    }
  }

  removeAdminId(int adminId) {
    if (adminIds.contains(adminId)) {
      adminIds.remove(adminId);
    }
  }

  removeBroId(int broId) {
    if (broIds.contains(broId)) {
      broIds.remove(broId);
    }
  }

  addBroId(int broId) {
    // If the bro was added by me it is already in the list.
    if (!broIds.contains(broId)) {
      broIds.add(broId);
    }
  }

  addBro(Bro bro) {
    if (!broIds.contains(bro.getId())) {
      broIds.add(bro.getId());
    }
    if (!broupBros.any((element) => element.getId() == bro.getId())) {
      broupBros.add(bro);
    } else {
      broupBros.removeWhere((element) => element.getId() == bro.getId());
      broupBros.add(bro);
    }
  }

  removeBro(int broId) {
    if (broIds.contains(broId)) {
      broIds.remove(broId);
    }
    if (broupBros.isNotEmpty) {
      broupBros.removeWhere((element) => element.getId() == broId);
    }
  }

  List<int> getAdminIds() {
    return adminIds;
  }

  List<Bro> getBroupBros() {
    return broupBros;
  }

  setBroupName(String newBroupName) {
    this.broupName = newBroupName;
  }

  String getBroupName() {
    if (private) {
      for (Bro bro in broupBros) {
        if (bro.getId() != Settings().getMe()!.getId()) {
          return bro.getFullName();
        }
      }
      return "";
    } else {
      return broupName;
    }
  }

  String getBroupDescription() {
    return broupDescription;
  }

  addMessage(Message message) {
    messageIds.add(message.messageId);
    messages.add(message);
  }

  setUpdateBroup(bool update) {
    updateBroup = update;
  }

  Broup.fromJson(Map<String, dynamic> json) {
    // These 4 values should always be present
    broupId = json["broup_id"];
    unreadMessages = json["unread_messages"];
    updateBroup = json["broup_updated"];
    newMessages = json["new_messages"];
    // These might not be present
    alias = json.containsKey("alias") ? json["alias"] : "";
    mute = json.containsKey("mute") ? json["mute"] : false;
    deleted = json.containsKey("deleted") ? json["deleted"] : false;
    removed = json.containsKey("removed") ? json["removed"] : false;
    // These are the core chat values. Stored in a coupling table on the server
    broupName = "";
    lastMessageId = 0;
    if (json.containsKey("chat")) {
      Map<String, dynamic> chat_details = json["chat"];
      broupName = chat_details.containsKey("broup_name") ? chat_details["broup_name"] : "";
      broupDescription = chat_details["broup_description"];
      broupColour = chat_details["broup_colour"];
      private = chat_details["private"];
      broIds = chat_details["bro_ids"].cast<int>();
      adminIds = chat_details["admin_ids"].cast<int>();
      if (chat_details.containsKey("avatar") && chat_details["avatar"] != null) {
        avatar = base64Decode(chat_details["avatar"].replaceAll("\n", ""));
      }
      lastMessageId = chat_details.containsKey("current_message_id") ? chat_details["current_message_id"] : 0;
    }
    broupBros = [];
    messages = [];
    messageIds = [];
    if (json.containsKey("update_bros") && json["update_bros"] != null) {
      List<int> brosUpdate = json["update_bros"].cast<int>();
      if (brosUpdate.isNotEmpty) {
        retrieveBros(brosUpdate);
      }
    }
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
    map['deleted'] = deleted ? 1 : 0;
    map['removed'] = removed ? 1 : 0;
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
    deleted = map['deleted'] == 1;
    removed = map['removed'] == 1;
    lastMessageId = map['lastMessageId'];
    updateBroup = map['updateBroup'] == 1;
    newMessages = map['newMessages'] == 1;
    avatar = map['avatar'];
    List<dynamic> messageIds = jsonDecode(map['messages']);
    List<int> messageIdsList = messageIds.map((s) => s as int).toList();
    this.messageIds = messageIdsList;
    broupBros = [];
    messages = [];
  }

  updateBroupDataServer(Broup serverBroup) {
    // From the server we want to update most of the data.
    this
      ..broIds = serverBroup.broIds
      ..adminIds = serverBroup.adminIds
      ..alias = serverBroup.alias
      ..unreadMessages = serverBroup.unreadMessages
      ..deleted = serverBroup.deleted
      ..removed = serverBroup.removed
      ..mute = serverBroup.mute
      ..broupName = serverBroup.broupName
      ..broupDescription = serverBroup.broupDescription
      ..broupColour = serverBroup.broupColour
      ..private = serverBroup.private
      ..updateBroup = serverBroup.updateBroup
      ..newMessages = serverBroup.newMessages;

    this
      ..lastMessageId = this.lastMessageId
      ..messages = this.messages
      ..avatar = this.avatar;
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
      if (!todayTileAdded) {
        todayTileAdded = true;
        this.messages.insert(0, timeMessage);
      }
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
        if (!todayTileAdded) {
          todayTileAdded = true;
          this.messages.insert(0, timeMessage);
        }
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
      print("Check if we did not send the message ${message.senderId} != ${Settings().getMe()!.getId()}");
      if (message.senderId != Settings().getMe()!.getId()) {
        print("indicate that the message was received");
        AuthServiceSocial().receivedMessage(broupId, lastMessageId).then((value) {
          print("received message $value");
          if (value) {
            // The message that was received really was the last one so no update required
            newMessages = false;
            // Check if the user has the broup page open. if not send a notification
            print("Check if the user has the broup page open. if not send a notification");
            if (MessagingChangeNotifier().getBroupId() != broupId) {
              print("page was NOT open add unread messages");
              unreadMessages++;
              // TODO: send notification?
            } else {
              print("page was open when receiving");
              // If it was send by someone else wa want to indicate that we read it.
              // Because we had the correct page open
              print("message received, so indicate that we read it");
              readMessages();
            }
          } else {
            if (!newMessages) {
              newMessages = true;
              // TODO: If page is open do update immediately?
            }
          }
          // notify the home screen because the call
          // might not have finished when a notify was send out
          BroHomeChangeNotifier().notify();
        });
      }
    } else {
      unreadMessages++;
      newMessages = true;
    }
  }

  updateLastReadMessages(String lastRead) {
    String lastReadTime = lastRead;
    if (!lastReadTime.endsWith("Z")) {
      lastReadTime = lastReadTime + "Z";
    }

    Storage storage = Storage();
    DateTime lastReadDateTime = DateTime.parse(lastReadTime).toLocal();
    print("updating last read messages $lastReadDateTime");
    // Go through the messages and set the isRead to 1 if the message is older than the lastReadDateTime
    for (Message message in messages) {
      if (!message.isInformation()) {
        if (message.isRead == 1) {
          break;
        }
        DateTime messageDateTime = message.getTimeStamp();
        if (messageDateTime.compareTo(lastReadDateTime) <= 0) {
          message.isRead = 1;
          storage.updateMessage(message);
        }
      }
    }
  }

  readMessages() {
    AuthServiceSocial().readMessages(getBroupId()).then((value) {
      if (value) {
        if (MessagingChangeNotifier().getBroupId() == broupId) {
          MessagingChangeNotifier().notify();
        }
      }
    });
  }

  retrieveBros(List<int> brosIds) async {
    Storage storage = Storage();
    AuthServiceSocial().retrieveBros(brosIds).then((bros) {
      // We might update it on a broup object which is overridden
      // We update the bro in the storage and then update the broup list.
      for (Bro bro in bros) {
        storage.updateBro(bro);
      }
      for (Broup broup in Settings().getMe()!.broups) {
        if (broup.getBroupId() == broupId) {
          for (Bro bro in bros) {
            broup.addBro(bro);
          }
          broup.retrievedBros = true;
          BroHomeChangeNotifier().notify();
          AuthServiceSocial().broupBrosRetrieved(broupId);
          break;
        }
      }
    });
  }
}
