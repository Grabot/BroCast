import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  String? data;
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

  static Future<Message> fromJson(Map<String, dynamic> json) async {
    String timeStampMessage = json['timestamp'];
    if (!timeStampMessage.endsWith("Z")) {
      timeStampMessage = timeStampMessage + "Z";
    }
    final message = Message(
      json['message_id'],
      json['sender_id'],
      json['body'],
      json.containsKey('text_message') ? json['text_message'] : "",
      timeStampMessage,
      null,
      json['info'],
      json['broup_id'],
    );

    if (json.containsKey('data') && json['data'] != null) {
      Map<String, dynamic> messageData = json['data'];

      if (messageData.containsKey('data')) {
        if (messageData['data'] is List<int>) {
          Uint8List dataBytes = Uint8List.fromList(messageData['data']);
          message.data = await saveImageData(dataBytes);
          print("saved image on location ${message.data}");
        } else if (messageData['data'] is String) {
          Uint8List dataBytes = base64Decode(messageData['data'].replaceAll("\n", ""));
          message.data = await saveImageData(dataBytes);
        }
      }
      if (messageData.containsKey('type')) {
        message.dataType = messageData['type'];
      }
    }

    if (json.containsKey('replied_to') && json['replied_to'] != null) {
      message.repliedTo = json['replied_to'];
    }
    return message;
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

Future<String> saveImageData(Uint8List imageData) async {
  final directory = await getApplicationDocumentsDirectory();
  final imageDirectory = Directory('${directory.path}/images');
  final filePath = '${imageDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.brocastPng';
  final file = File(filePath);
  await file.writeAsBytes(imageData);
  return filePath;
}

Future<String> saveVideoData(Uint8List videoData) async {
  final directory = await getApplicationDocumentsDirectory();
  final imageDirectory = Directory('${directory.path}/videos');
  final filePath = '${imageDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.brocastMp4';
  final file = File(filePath);
  await file.writeAsBytes(videoData);
  return filePath;
}