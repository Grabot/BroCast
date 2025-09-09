import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:brocast/objects/me.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/v1_4/auth_service_social.dart';
import 'package:brocast/utils/life_cycle_service.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../utils/settings.dart';
import '../utils/storage.dart';
import '../views/chat_view/messaging_change_notifier.dart';
import 'bro.dart';
import 'data_type.dart';

class Broup {
  late int broupId;
  late int unreadMessages;
  bool updateBroup = false;
  bool newMessages = false;
  bool newAvatar = false;

  // We initialize variables with empty values
  // This is because the broup objects are updated later
  // This might cause an initialization error
  bool mute = false;
  String? muteValue;
  bool deleted = false;
  bool removed = false;
  // The `blocked` boolean might be confusing, it's only true for the bro that did the blocking
  // This can only be true in a private chat
  // Both bros will have their broup set to `removed` but only the blocker can unblock it again
  bool blocked = false;
  Uint8List? avatar;
  bool avatarDefault = true;

  late List<Bro> broupBros;
  List<Bro> messageBroRemaining = [];
  // Chat details. Initialized with empty values
  List<int> broIds = [];
  List<int> adminIds = [];
  List<int> updateBroIds = [];
  List<int> newUpdateBroIds = [];
  List<int> updateBroAvatarIds = [];
  List<int> newUpdateBroAvatarIds = [];
  String broupName = "";
  String broupDescription = "";
  String alias = "";
  String broupColour = "";
  bool private = false;

  bool dateTilesAdded = false;
  bool checkedRemainingBros = false;

  bool joinedBroupRoom = false;
  late List<int> messageIds;
  late List<Message> messages;
  int lastMessageId = 1;
  int lastMessageReadId = 1;
  int localLastMessageReadId = 1;

  String? lastActivity;

  bool sendingMessage = false;

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
      this.avatar,
      this.avatarDefault
      ) {
    broupBros = [];
    messages = [];
    messageIds = [];
    lastMessageId = 1;
  }

  int getBroupId() {
    return broupId;
  }

  DateTime getLastActivity() {
    if (lastActivity == null) {
      return DateTime(2025, 1, 1);
    } else {
      return DateTime.parse(lastActivity!).toLocal();
    }
  }

  updateLastActivity(String newLastActivity) {
    lastActivity = newLastActivity;
  }

  setBroupColor(String newBroupColour) {
    this.broupColour = newBroupColour;
  }

  setBroupDescription(String newBroupDescription) {
    this.broupDescription = newBroupDescription;
  }

  setAvatar(Uint8List avatar) {
    newAvatar = false;
    this.avatar = avatar;
  }

  Uint8List? getAvatar() {
    if (private) {
      for (Bro bro in broupBros) {
        Me? me = Settings().getMe();
        if (me == null) {
          return null;
        } else {
          if (bro.getId() != Settings().getMe()!.getId()) {
            if (bro.getAvatar() != null) {
              return bro.getAvatar();
            }
          }
        }
      }
    }
    return this.avatar;
  }

  setAvatarDefault(bool avatarDefault) {
    this.avatarDefault = avatarDefault;
  }

  bool getAvatarDefault() {
    return avatarDefault;
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

  String getBroupNameOrAlias() {
    if (alias.isEmpty) {
      if (private) {
        for (Bro bro in broupBros) {
          Me? me = Settings().getMe();
          if (me == null) {
            return "";
          } else {
            if (bro.getId() != Settings().getMe()!.getId()) {
              return bro.getFullName();
            }
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

  insertBro(Bro bro) {
    if (bro is Me) {
      broupBros.insert(0, bro);
    } else {
      broupBros.add(bro);
    }
  }

  addBro(Bro bro) {
    if (!broIds.contains(bro.getId())) {
      broIds.add(bro.getId());
    }
    if (!broupBros.any((element) => element.getId() == bro.getId())) {
      insertBro(bro);
    } else {
      broupBros.removeWhere((element) => element.getId() == bro.getId());
      insertBro(bro);
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

  setMuted(bool mute) {
    this.mute = mute;
  }

  setMuteValue(String? muteUntil) {
    if (muteUntil != null) {
      if (!muteUntil.endsWith("Z")) {
        muteUntil = muteUntil + "Z";
      }
    }
    this.muteValue = muteUntil;
  }

  processEmojiReactions(Map<String, dynamic> emojiReactions) {
    // After retrieval we will process it immediately by setting it on the right message
    Storage storage = Storage();
    List<String> messagesToRetrieveStrings = [...emojiReactions.keys];
    List<int> messagesToRetrieve = messagesToRetrieveStrings.map((e) => int.parse(e)).toList();
    storage.retrieveMessages(this.broupId, messagesToRetrieve).then((messagesEmojiReactions) {
      for (Message emojiReactionMessage in messagesEmojiReactions) {
        messagesToRetrieve.remove(emojiReactionMessage.messageId);
        Map<String, dynamic> emojiReaction = emojiReactions[emojiReactionMessage.messageId.toString()]!;
        List<String> broIdsReactionsStrings = [...emojiReaction.keys];
        List<int> broIdsReactions = broIdsReactionsStrings.map((e) => int.parse(e)).toList();
        // We don't need to retrieve the bro here, the id is enough
        for (int broIdReaction in broIdsReactions) {
          List<dynamic> emojiList = emojiReaction[broIdReaction.toString()]!;
          String emoji = emojiList[0];
          bool isAdd = true;
          if (emojiList[1] == "0") {
            isAdd = false;
          }
          if (isAdd) {
            emojiReactionMessage.addEmojiReaction(emoji, broIdReaction);
          } else {
            emojiReactionMessage.removeEmojiReaction(broIdReaction);
          }
          storage.updateMessage(emojiReactionMessage);
        }
      }
      if (messagesToRetrieve.isNotEmpty) {
        // It's highly possible that the message was not yet retrieved. It will only do that
        // If you open the chat.
        // If you don't open the chat, you won't retrieve the message.
        // To process the emoji reaction, we will create a placeholder Message
        // And store it, if we retrieve the messages later it might be updated.
        for (int messageId in messagesToRetrieve) {
          Map<String, dynamic> emojiReaction = emojiReactions[messageId.toString()]!;
          List<String> broIdsReactionsStrings = [...emojiReaction.keys];
          List<int> broIdsReactions = broIdsReactionsStrings.map((e) => int.parse(e)).toList();
          // We create the message with what we know.
          // We don't know the senderId yet, so we set it to -1
          for (int broIdReaction in broIdsReactions) {
            List<dynamic> emojiList = emojiReaction[broIdReaction.toString()]!;
            String emoji = emojiList[0];
            bool isAdd = true;
            if (emojiList[1] == "0") {
              isAdd = false;
            }
            if (isAdd) {
              Message placeHolderMessage = Message(
                  messageId: messageId,
                  senderId: -1,
                  body: "",
                  textMessage: null,
                  timestamp: DateTime.now().toUtc().toString(),
                  data: null,
                  dataType: null,
                  repliedTo: null,
                  info: false,
                  broupId: getBroupId()
              );
              placeHolderMessage.addEmojiReaction(emoji, broIdReaction);
              storage.addMessage(placeHolderMessage);
            }
          }
        }
      }
    });
  }

  Broup.fromJson(Map<String, dynamic> json) {
    // These 4 values should always be present
    broupId = json["broup_id"];
    unreadMessages = json.containsKey("unread_messages") ? json["unread_messages"] : 0;
    updateBroup = json.containsKey("broup_updated") ? json["broup_updated"] : false;
    newMessages = json.containsKey("new_messages") ? json["new_messages"] : false;
    // These might not be present
    alias = json.containsKey("alias") ? json["alias"] : "";
    mute = json.containsKey("mute") ? json["mute"] : false;
    deleted = json.containsKey("deleted") ? json["deleted"] : false;
    removed = json.containsKey("removed") ? json["removed"] : false;
    newAvatar = json.containsKey("new_avatar") ? json["new_avatar"] : false;
    if (json.containsKey("emoji_reactions")) {
      // We retrieve the emoji reactions on message via the broup object.
      // This is because the message object will be removed if everyone has received them.
      // So if a emoji reaction is made later we will let the bro know via the broup object.
      processEmojiReactions(json["emoji_reactions"]);
    }

    // These are the core chat values. Stored in a coupling table on the server
    broupName = "";
    if (json.containsKey("chat")) {
      Map<String, dynamic> chat_details = json["chat"];
      broupName = chat_details.containsKey("broup_name") ? chat_details["broup_name"] : "";
      broupDescription = chat_details["broup_description"];
      broupColour = chat_details["broup_colour"];
      private = chat_details["private"];
      broIds = chat_details["bro_ids"].cast<int>();
      adminIds = chat_details["admin_ids"].cast<int>();
      if (private && removed) {
        Me? me = Settings().getMe();
        int meId = me != null ? me.getId() : -1;
        if (adminIds.contains(meId)) {
          // In a private chat the admin id is not needed, so it is repurposed for the blocked status
          // The id of the bro that blocked the chat is stored in the adminIds
          this.blocked = true;
        }
      }
      if (chat_details.containsKey("avatar") && chat_details["avatar"] != null) {
        avatar = base64Decode(chat_details["avatar"].replaceAll("\n", ""));
        // This variable can only ever be here if the avatar was send as well.
        avatarDefault = chat_details.containsKey("avatar_default") ? chat_details["avatar_default"] : true;
      }
    }
    broupBros = [];
    messages = [];
    messageIds = [];

    if (json.containsKey("update_bros") && json["update_bros"] != null) {
      List<int> brosUpdate = json["update_bros"].cast<int>();
      newUpdateBroIds = brosUpdate;
    }
    if (json.containsKey("update_bros_avatar") && json["update_bros_avatar"] != null) {
      List<int> brosAvatarUpdate = json["update_bros_avatar"].cast<int>();
      newUpdateBroAvatarIds = brosAvatarUpdate;
    }
    lastMessageReadId = json.containsKey("last_message_read_id_chat") ? json["last_message_read_id_chat"] : 0;
    lastActivity = DateTime.now().toUtc().toString();
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['broupId'] = broupId;
    map['broIds'] = jsonEncode(broIds);
    map['adminIds'] = jsonEncode(adminIds);
    map['updateBroIds'] = jsonEncode(updateBroIds);
    map['updateBroAvatarIds'] = jsonEncode(updateBroAvatarIds);
    map['broupName'] = broupName;
    map['broupDescription'] = broupDescription;
    map['alias'] = alias;
    map['broupColour'] = broupColour;
    map['unreadMessages'] = unreadMessages;
    map['private'] = private ? 1 : 0;
    map['mute'] = mute ? 1 : 0;
    map['muteValue'] = muteValue;
    map['deleted'] = deleted ? 1 : 0;
    map['removed'] = removed ? 1 : 0;
    map['blocked'] = blocked ? 1 : 0;
    map['lastMessageId'] = lastMessageId;
    map['avatar'] = avatar;
    map['avatarDefault'] = avatarDefault ? 1 : 0;
    map['lastActivity'] = lastActivity;
    // Get the ids of all the messages in a list
    List<int> messageIds = messages.map((e) => e.messageId).toList();
    map['messages'] = jsonEncode(messageIds);
    map['lastMessageReadId'] = lastMessageReadId;
    map['localLastMessageReadId'] = localLastMessageReadId;
    return map;
  }

  updateMute() {
    Storage().fetchBroup(broupId).then((dbBroup) {
      if (dbBroup != null) {
        // We want to update the db object and the current broup object
        dbBroup.mute = false;
        dbBroup.muteValue = null;
        Storage().updateBroup(dbBroup).then((value) {
          for (Broup checkBroup in Settings().getMe()!.broups) {
            if (checkBroup.getBroupId() == broupId) {
              checkBroup.mute = false;
              checkBroup.muteValue = null;
              break;
            }
          }
          BroHomeChangeNotifier().notify();
        });
      }
    });
  }

  checkMute() {
    // We set a time until the muteValue is reached
    DateTime muteDateTime = DateTime.parse(muteValue!).toLocal();
    Duration remainingTime = muteDateTime.difference(DateTime.now());
    if (remainingTime.inSeconds > 0) {
      // The mute is still active
      Future.delayed(remainingTime).then((value) {
        updateMute();
      });
    } else {
      updateMute();
    }
  }

  Broup.fromDbMap(Map<String, dynamic> map) {
    broupId = map['broupId'];

    List<dynamic> broIds = jsonDecode(map['broIds']);
    List<int> broIdList = broIds.map((s) => s as int).toList();
    this.broIds = broIdList;
    List<dynamic> broAdminsIds = jsonDecode(map['adminIds']);
    List<int> broAdminIdList = broAdminsIds.map((s) => s as int).toList();
    this.adminIds = broAdminIdList;

    List<dynamic> updateBroIds = jsonDecode(map['updateBroIds']);
    List<int> updateBroIdsList = updateBroIds.map((s) => s as int).toList();
    this.updateBroIds = updateBroIdsList;
    List<dynamic> updateBroAvatarIds = jsonDecode(map['updateBroAvatarIds']);
    List<int> updateBroAvatarIdsList = updateBroAvatarIds.map((s) => s as int).toList();
    this.updateBroAvatarIds = updateBroAvatarIdsList;

    broupName = map['broupName'];
    broupDescription = map['broupDescription'];
    alias = map['alias'];
    broupColour = map['broupColour'];
    unreadMessages = map['unreadMessages'];
    private = map['private'] == 1;
    mute = map['mute'] == 1;
    muteValue = map['muteValue'];
    if (muteValue != null) {
      checkMute();
    }
    deleted = map['deleted'] == 1;
    removed = map['removed'] == 1;
    blocked = map['blocked'] == 1;
    lastMessageId = map['lastMessageId'];
    avatar = map['avatar'];
    avatarDefault = map['avatarDefault'] == 1;
    lastActivity = map['lastActivity'];
    List<dynamic> messageIds = jsonDecode(map['messages']);
    List<int> messageIdsList = messageIds.map((s) => s as int).toList();
    this.messageIds = messageIdsList;
    lastMessageReadId = map['lastMessageReadId'];
    localLastMessageReadId = map['localLastMessageReadId'];
    broupBros = [];
    messages = [];
  }

  addBlockMessage(Broup localBroup) {
    // Add block message
    String blockMessageText = "Chat is blocked! 😭";
    if (!localBroup.private) {
      blockMessageText = "You are removed from the broup! 😭";
    }
    Message blockMessage = Message(
        messageId: lastMessageId + 1,
        senderId: 0,
        body: blockMessageText,
        textMessage: "",
        timestamp: DateTime.now().toUtc().toString(),
        data: null,
        info: true,
        broupId: getBroupId()
    );
    Storage().addMessage(blockMessage);
    this.messages.insert(
        0,
        blockMessage);
  }

  updateBroupLocalDB(Broup localBroup) {
    // This is only called if the broup is updated, so we will update the update time.
    // It's not perfect, since it will not update the broup that was updated the most recently
    // but it updates all the broups that were updated since the last time the app was opened.
    // This is good enough and is just as user friendly as the perfect last update time.
    // But this way we don't need to keep track of this time on the server and only on the client.
    updateLastActivity(DateTime.now().toUtc().toString());
    // Check if the data from the server indicates that the bro is now blocked from the chat.
    if (this.removed && !localBroup.removed) {
      // It's possible that a blocked message is already added, we will not add it again
      if (this.messages.isEmpty) {
        addBlockMessage(localBroup);
      } else {
        if (this.messages.first.body != "Chat is blocked! 😭" && this.messages.first.body != "You are removed from the broup! 😭") {
          addBlockMessage(localBroup);
        }
      }
    }

    // If there are messages on this chat we want to ensure that the date tiles are set correctly.
    // It might be cleared but we will remove all the date tiles and set the chat to reapply them.
    dateTilesAdded = false;
    if (messages.isNotEmpty) {
      messages.removeWhere((element) => element.messageId == 0);
    }

    if (this.updateBroup && this.removed) {
      // We have been removed and that's the only information we will receive.
      this
        ..alias = localBroup.alias
        ..unreadMessages = localBroup.unreadMessages
        ..mute = localBroup.mute
        ..updateBroup = localBroup.updateBroup
        ..newMessages = localBroup.newMessages
        ..newAvatar = localBroup.newAvatar
        ..broIds = localBroup.broIds
        ..adminIds = localBroup.adminIds
        ..broupName = localBroup.broupName
        ..private = localBroup.private
        ..broupDescription = localBroup.broupDescription
        ..broupColour = localBroup.broupColour
        ..updateBroIds = localBroup.updateBroIds
        ..updateBroAvatarIds = localBroup.updateBroAvatarIds
        ..avatarDefault = localBroup.avatarDefault
        ..localLastMessageReadId = localBroup.localLastMessageReadId
        ..avatar = localBroup.avatar;
      return;
    }
    // If updateBroup was true, these values should be taken from the server, which are now on `this` broup object.
    if (this.updateBroup) {
      this
        ..alias = this.alias
        ..unreadMessages = this.unreadMessages
        ..removed = this.removed
        ..mute = this.mute
        ..updateBroup = this.updateBroup
        ..newMessages = this.newMessages
        ..newAvatar = this.newAvatar
        ..broIds = this.broIds
        ..adminIds = this.adminIds
        ..broupName = this.broupName
        ..private = this.private
        ..broupDescription = this.broupDescription
        ..broupColour = this.broupColour
        ..lastMessageReadId = this.lastMessageReadId;
    } else if (this.newAvatar) {
      this
        ..unreadMessages = this.unreadMessages
        ..newMessages = this.newMessages
        ..lastMessageReadId = this.lastMessageReadId
        ..newAvatar = this.newAvatar;

      this
        ..removed = localBroup.removed
        ..mute = localBroup.mute
        ..updateBroup = localBroup.updateBroup
        ..broIds = localBroup.broIds
        ..adminIds = localBroup.adminIds
        ..broupName = localBroup.broupName
        ..private = localBroup.private
        ..broupDescription = localBroup.broupDescription
        ..broupColour = localBroup.broupColour;
    } else if (this.newMessages) {
      // If newMessages is true, (and updateBroup is false) we want to take the
      // `newMessages` and `unreadMessages` from the server
      // Which means we take everything from the db except these values.
      this
        ..newMessages = this.newMessages
        ..unreadMessages = this.unreadMessages
        ..lastMessageReadId = this.lastMessageReadId;

      this
        ..removed = localBroup.removed
        ..mute = localBroup.mute
        ..updateBroup = localBroup.updateBroup
        ..newAvatar = localBroup.newAvatar
        ..broIds = localBroup.broIds
        ..adminIds = localBroup.adminIds
        ..broupName = localBroup.broupName
        ..private = localBroup.private
        ..broupDescription = localBroup.broupDescription
        ..broupColour = localBroup.broupColour;
    } else {
      // If both updateBroup and newMessages are false we will take almost everything from the db.
      // Since probably nothing has changed.
      this
        ..alias = localBroup.alias
        ..unreadMessages = localBroup.unreadMessages
        ..removed = localBroup.removed
        ..mute = localBroup.mute
        ..updateBroup = localBroup.updateBroup
        ..newMessages = localBroup.newMessages
        ..newAvatar = localBroup.newAvatar
        ..broIds = localBroup.broIds
        ..adminIds = localBroup.adminIds
        ..broupName = localBroup.broupName
        ..private = localBroup.private
        ..broupDescription = localBroup.broupDescription
        ..broupColour = localBroup.broupColour;
    }

    // We might have some new bros to update, add them to the `updateBroIds`
    if (newUpdateBroIds.isNotEmpty) {
      // The updateBroIds is only additive. Once the broup is opened, these are retrieved.
      for (int broId in newUpdateBroIds) {
        if (!localBroup.updateBroIds.contains(broId)) {
          localBroup.updateBroIds.add(broId);
        }
      }
    }
    if (newUpdateBroAvatarIds.isNotEmpty) {
      for (int broAvatarId in newUpdateBroAvatarIds) {
        if (!localBroup.updateBroAvatarIds.contains(broAvatarId)) {
          localBroup.updateBroAvatarIds.add(broAvatarId);
        }
      }
    }
    // Always take these values locally.
    this
      ..updateBroIds = localBroup.updateBroIds
      ..updateBroAvatarIds = localBroup.updateBroAvatarIds
      ..avatarDefault = localBroup.avatarDefault
      ..lastMessageId = localBroup.lastMessageId
      ..lastActivity = localBroup.lastActivity
      ..localLastMessageReadId = localBroup.localLastMessageReadId
      ..avatar = localBroup.avatar;
  }

  updateBroupDataServer(Broup serverBroup) {
    if (serverBroup.removed) {
      if (serverBroup.private) {
        if (serverBroup.adminIds.contains(Settings().getMe()!.getId())) {
          // In a private chat the admin id is not needed, so it is repurposed for the blocked status
          // The id of the bro that blocked the chat is stored in the adminIds
          this.blocked = true;
        }
      }
      // When it's removed, we still want to know the updateBroup status.
      this
        ..updateBroup = serverBroup.updateBroup;
      // In the edge case when a broup is added and blocked before the user opens the app
      // we want to retrieve some details anyway. We identify this by an empty broupColour
      // This can only happen in this edge case and we will update some details
      if (broupColour.isEmpty) {
        this
          ..broIds = serverBroup.broIds
          ..adminIds = serverBroup.adminIds
          ..broupName = serverBroup.broupName
          ..broupColour = serverBroup.broupColour
          ..private = serverBroup.private
          ..updateBroup = serverBroup.updateBroup;
      }
    }
    // If the broup is removed we want to set the flag, but also add a block message
    // If it's no longer removed we want to updated it again.
    if (checkRemoved(serverBroup)) {
      return;
    }
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
      ..newAvatar = serverBroup.newAvatar
      ..newMessages = serverBroup.newMessages
      ..newUpdateBroIds = serverBroup.newUpdateBroIds
      ..lastMessageReadId = serverBroup.lastMessageReadId
      ..newUpdateBroAvatarIds = serverBroup.newUpdateBroAvatarIds;

    // If there are messages on this chat we want to ensure that the date tiles are set correctly.
    // It might be cleared but we will remove all the date tiles and set the chat to reapply them.
    dateTilesAdded = false;
    if (messages.isNotEmpty) {
      messages.removeWhere((element) => element.messageId == 0);
    }
    this
      ..updateBroIds = this.updateBroIds
      ..updateBroAvatarIds = this.updateBroAvatarIds
      ..lastMessageId = this.lastMessageId
      ..messages = this.messages
      ..avatarDefault = this.avatarDefault
      ..lastActivity = this.lastActivity
      ..localLastMessageReadId = this.localLastMessageReadId
      ..avatar = this.avatar;
  }

  checkRemoved(Broup serverBroup) {
    // If the bro did not have their phone active when this message was send
    // They will not have the message in their chat
    // In this specific case we will add indication that the chat is blocked
    if (!this.removed && serverBroup.removed) {
      // Add block message
      String blockMessageText = "Chat is blocked! 😭";
      if (!serverBroup.private) {
        blockMessageText = "You are removed from the broup! 😭";
      }
      Message blockMessage = Message(
          messageId: lastMessageId + 1,
          senderId: 0,
          body: blockMessageText,
          textMessage: "",
          timestamp: DateTime.now().toUtc().toString(),
          data: null,
          info: true,
          broupId: getBroupId()
      );
      Storage().addMessage(blockMessage);
      this.messages.insert(
          0,
          blockMessage);
      this.removed = serverBroup.removed;
      this.unreadMessages = 0;
    }
    // Return removed, because if the broup is removed we don't want any updates.
    return serverBroup.removed;
  }

  updateDateTiles(Message message) {
    // If the day tiles need to be updated after sending a message it will be the today tile.
    if (this.messages.isEmpty) {
      return;
    }
    Message messageFirst = this.messages.first;
    DateTime dayFirst = DateTime(messageFirst.getTimeStamp().year,
        messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
    String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

    DateTime current = message.getTimeStamp();
    DateTime dayMessage = DateTime(current.year, current.month, current.day);
    String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

    if (chatTimeTile != currentDayMessage) {

      DateTime datetimeTimeMessage = DateTime(message.getTimeStamp().year,
          message.getTimeStamp().month, message.getTimeStamp().day);
      Message timeMessage = Message(
          messageId: 0,
          senderId: 0,
          body: "Today",
          textMessage: "",
          timestamp: datetimeTimeMessage.toUtc().toString(),
          data: null,
          info: true,
          broupId: getBroupId()
      );
      this.messages.insert(0, timeMessage);
    }
  }

  updateMessages(Message message) {
    Me? me = Settings().getMe();
    bool updated = false;
    if (me != null) {
      if (!message.isInformation() && message.senderId == Settings().getMe()!.getId()) {
        // We added it immediately as a placeholder.
        // When we get it from the server we add it for real and remove the placeholder
        // Do a few simple extra checks, like body comparison
        for (int i = 0; i < 5; i++) {
          // There might be some messages retrieved in between this period.
          // While this is unlikely, check for the correct message to remove.
          if (messages[i] == message) {
            // Update the message with the messageId, which might have changed on the server.
            Message m = messages[i];
            // Update the received message object with the local data that you don't need to retrieve again.
            message.data = m.data;
            message.dataType = m.dataType;
            message.repliedMessage = m.repliedMessage;
            message.repliedTo = m.repliedTo;
            message.dataIsReceived = true;
            messages[i] = message;
            updated = true;
            break;
          }
        }
      }
    }
    updateDateTiles(message);
    // `isRead` 0 indicates it was successfully send to the server
    message.isRead = 0;
    if (!updated) {
      this.messages.insert(0, message);
    } else {
      Storage().updateMessage(message);
    }
    checkReceivedMessages(message);
  }

  checkReceivedMessages(Message message) {
    // We will check if the message we have just received is the
    // latest message that the bro had to retrieve.
    // We will compare the lastMessageId with the messageId of the message
    // If the message is 1 higher, the bro is up to date with all the messages
    // The bro still has not read anything so the unreadMessages will stay
    if (message.messageId == lastMessageId + 1 && LifeCycleService().appOpen) {
      // The bro is up to date with all the messages
      // We will increase the lastMessageId
      lastMessageId += 1;
      if ((message.dataType == null
          || message.dataType == DataType.location.value
          || message.dataType == DataType.liveLocation.value)
            && message.dataIsReceived) {
        AuthServiceSocial().receivedMessageSingle(broupId, message.messageId).then((value) {
          if (value) {
            // The message that was received really was the last one so no update required
            newMessages = false;
            if (MessagingChangeNotifier().getBroupId() != broupId) {
              if (!message.isInformation()) {
                unreadMessages++;
              }
            } else {
              if (LifeCycleService().appOpen) {
                unreadMessages = 0;
                // We had the correct page open, so we have read the message.
                if (localLastMessageReadId < lastMessageId) {
                  AuthServiceSocial().readMessages(broupId, lastMessageId).then((value) {
                    if (value) {
                      localLastMessageReadId = lastMessageId;
                      unreadMessages = 0;
                    }
                  });
                }
              }
            }
          } else {
            if (!newMessages) {
              newMessages = true;
            }
          }
          // notify the home screen because the call
          // might not have finished when a notify was send out
          Storage().updateBroup(this);
          BroHomeChangeNotifier().notify();
        });
      } else {
        // The message has data, but the bro will still have read it if the chat is open.
        if (MessagingChangeNotifier().getBroupId() != broupId) {
          unreadMessages++;
        } else {
          if (LifeCycleService().appOpen) {
            unreadMessages = 0;
            // We had the correct page open, so we have read the message.
            if (localLastMessageReadId < lastMessageId) {
              AuthServiceSocial().readMessages(broupId, lastMessageId).then((value) {
                if (value) {
                  localLastMessageReadId = lastMessageId;
                  unreadMessages = 0;
                }
              });
            }
          }
        }
      }
    } else {
      if (!message.isInformation()) {
        unreadMessages++;
        newMessages = true;
      }
    }
  }

  updateLastReadMessages(int lastMessageReadIdChat, Storage storage) {
    // Go through the messages and set the isRead to 1 if the message is older than the lastReadDateTime
    for (Message message in messages) {
      if (!message.isInformation()) {
        if (message.isRead == 1) {
          break;
        }
        if (message.messageId <= lastMessageReadIdChat) {
          message.isRead = 1;
          storage.updateMessage(message);
        }
      }
    }
  }

  retrieveBros(List<int> brosIds) async {
    Storage storage = Storage();
    AuthServiceSocial().retrieveBros(brosIds).then((brosServer) {
      // We might update it on a broup object which is overridden
      // We update the bro in the storage and then update the broup list.
      storage.fetchBros(brosIds).then((brosDb) {
        for (Bro broServer in brosServer) {
          bool found = false;
          for (Bro broDb in brosDb) {
            if (broServer.getId() == broDb.getId()) {
              found = true;
              // Here we only update the broname or the bromotion
              // So we take the avatar from the db
              if (broDb.getAvatar() != null ) {
                broServer.setAvatar(broDb.getAvatar()!);
              }
              break;
            }
          }
          if (found) {
            storage.updateBro(broServer);
          } else {
            storage.addBro(broServer);
          }
        }
      });
      Me? me = Settings().getMe();
      if (me != null) {
        for (Broup broup in me.broups) {
          if (broup.getBroupId() == broupId) {
            for (Bro broServer in brosServer) {
              broup.addBro(broServer);
            }
            BroHomeChangeNotifier().notify();
            AuthServiceSocial().broupBrosRetrieved(broupId, brosIds);
            break;
          }
        }
      }
    });
  }
}

