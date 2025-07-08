import 'dart:convert';
import 'dart:typed_data';

class Message {
  late int messageId;
  late int senderId;
  late String body;
  late String? textMessage;
  late String timestamp;

  // Used to determine if the message has been read.
  // Also if the message is only send or also received.
  late int isRead;
  late bool clicked;
  late bool info;

  late int broupId;

  Uint8List? data;
  int? dataType;
  // Used to determine if the message is a reply to another message.
  // repliedTo is stored on the local db and is a reference to a message Id
  int? repliedTo;
  // The Message object is not stored in the local db.
  // But it is retrieved when needed and stored on this object.
  Message? repliedMessage;

  // A mapping of the emoji reactions on the Message object.
  // It is a mapping of the bro id and the emoji reaction.
  Map<String, String> emojiReactions = {};

  Message(this.messageId, this.senderId, this.body, this.textMessage, this.timestamp,
      this.data, this.info, this.broupId) {
    if (timestamp.endsWith("Z")) {
      this.timestamp = timestamp;
    } else {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      this.timestamp = timestamp + "Z";
    }
    isRead = 0;
    clicked = false;
  }

  setBody(String body) {
    this.body = body;
  }

  DateTime getTimeStamp() {
    return DateTime.parse(timestamp).toLocal();
  }

  setTimeStamp(String newTimestamp) {
    if (!newTimestamp.endsWith("Z")) {
      this.timestamp = newTimestamp + "Z";
    } else {
      this.timestamp = newTimestamp;
    }
  }

  bool isInformation() {
    return info;
  }

  bool hasBeenRead() {
    return isRead == 1;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['messageId'] = messageId;
    map['senderId'] = senderId;
    map['broupId'] = broupId;
    map['body'] = body;
    map['textMessage'] = textMessage;
    map['info'] = info ? 1 : 0;
    map['timestamp'] = timestamp;
    map['isRead'] = isRead;
    map['data'] = data;
    map['dataType'] = dataType;
    map['repliedTo'] = repliedTo;
    map['emojiReactions'] = jsonEncode(emojiReactions);
    return map;
  }

  Message.fromDbMapV14(Map<String, dynamic> map) {
    // For the update of the database we have this function which can retrieve messages the old way
    // It will retrieve all the messages and turn the string data to blob data
    // and stores it in the new updated database.
    messageId = map['messageId'];
    senderId = map['senderId'];
    broupId = map['broupId'];
    body = map['body'];
    textMessage = map['textMessage'];
    info = map['info'] == 1;
    timestamp = map['timestamp'];
    String? oldData = map['data'];
    if (oldData != null) {
      data = base64.decode(oldData);
    }
    dataType = map['dataType'];
    repliedTo = map['repliedTo'];
    isRead = map['isRead'];
    clicked = false;
  }

  Message.fromDbMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    senderId = map['senderId'];
    broupId = map['broupId'];
    body = map['body'];
    textMessage = map['textMessage'];
    info = map['info'] == 1;
    timestamp = map['timestamp'];
    data = map['data'];
    dataType = map['dataType'];
    repliedTo = map['repliedTo'];
    isRead = map['isRead'];
    emojiReactions = Map<String, String>.from(jsonDecode(map['emojiReactions']));
    clicked = false;
  }

  Message.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    senderId = json['sender_id'];
    broupId = json['broup_id'];
    body = json['body'];
    if (json.containsKey('text_message')) {
      textMessage = json['text_message'];
    } else {
      textMessage = "";
    }
    info = json['info'];
    this.timestamp = json['timestamp'];
    if (!timestamp.endsWith("Z")) {
      this.timestamp = timestamp + "Z";
    }

    if (json.containsKey('data') && json['data'] != null) {
      Map<String, dynamic> messageData = json['data'];

      if (messageData.containsKey('data')) {
        if (messageData['data'] is List<int>) {
          data = Uint8List.fromList(messageData['data']);
        } else if (messageData['data'] is String) {
          data = base64Decode(messageData['data'].replaceAll("\n", ""));
        }
      }
      if (messageData.containsKey('type')) {
        dataType = messageData['type'];
      }
    }

    if (json.containsKey('replied_to') && json['replied_to'] != null) {
      repliedTo = json['replied_to'];
    }
    // emojiReactions are handled via the broup object from the server.
    isRead = 0;
    clicked = false;
  }

  addEmojiReaction(String emoji, int broId) {
    emojiReactions[broId.toString()] = emoji;
  }

  removeEmojiReaction(int broId) {
    if (emojiReactions.containsKey(broId.toString())) {
      emojiReactions.remove(broId.toString());
    }
  }

  updateEmojiReactions(Map<String, String> emojiReactions) {
    this.emojiReactions = emojiReactions;
  }

  getEmojiReaction() {
    return emojiReactions;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    // We don't check the messageId because it's not available when sending.
    // similarly we don't check the timestamp
    // We also don't check the body, text_message and the data because the rest is sufficient.
    // Basically just the messageId is sufficient since it's unique.
    return other is Message
        && other.messageId == messageId
        && other.senderId == senderId
        && other.broupId == broupId;
  }

  @override
  String toString() {
    return 'Message{messageId: $messageId, senderId: $senderId, body: $body, textMessage: $textMessage, timestamp: $timestamp, isRead: $isRead, clicked: $clicked, info: $info, broupId: $broupId, data: ${data != null}';
  }
}
