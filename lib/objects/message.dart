import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Message {
  late int messageId;
  // Can be null for information messages
  String? messageIdentifier;
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

  bool dataIsReceived = true;

  Message({
    required this.messageId,
    required this.messageIdentifier,
    required this.broupId,
    required this.senderId,
    required this.body,
    required this.textMessage,
    required this.timestamp,
    required this.info,
    this.data,
    this.dataType,
    this.repliedTo,
    this.repliedMessage,
  }) {
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
    map['messageIdentifier'] = messageIdentifier;
    map['senderId'] = senderId;
    map['broupId'] = broupId;
    map['body'] = body;
    map['textMessage'] = textMessage;
    map['info'] = info ? 1 : 0;
    map['timestamp'] = timestamp;
    map['isRead'] = isRead;
    map['data'] = data;
    map['dataType'] = dataType;
    map['dataIsReceived'] = dataIsReceived ? 1 : 0;
    map['repliedTo'] = repliedTo;
    map['emojiReactions'] = jsonEncode(emojiReactions);
    return map;
  }

  Message.fromDbMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    messageIdentifier = map['messageIdentifier'];
    senderId = map['senderId'];
    broupId = map['broupId'];
    body = map['body'];
    textMessage = map['textMessage'];
    info = map['info'] == 1;
    timestamp = map['timestamp'];
    data = map['data'];
    dataType = map['dataType'];
    dataIsReceived = map['dataIsReceived'] == 1;
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
        messageId: json['message_id'],
        messageIdentifier: json['message_identifier'],
        senderId: json['sender_id'],
        body: json['body'],
        textMessage: json.containsKey('text_message') ? json['text_message'] : "",
        timestamp: timeStampMessage,
        data: null,
        info: json['info'],
        broupId: json['broup_id'],
    );

    if (json.containsKey('data') && json['data'] != null) {
      Map<String, dynamic> messageData = json['data'];
      // If there is data we want to set the flag to not received.
      message.dataIsReceived = false;
      if (messageData.containsKey('data')) {
        if (messageData['data'] is List<int>) {
          // If the data is present, we set the flag to received
          message.dataIsReceived = true;
          Uint8List dataBytes = Uint8List.fromList(messageData['data']);
          message.data = await saveImageData(dataBytes);
        } else if (messageData['data'] is String) {
          message.dataIsReceived = true;
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
    // We just check the messageIdentifier, senderId and broupId since these are the fields that
    // are now client side when sending the message. This combination will be unique.
    return other is Message
        && other.messageIdentifier == messageIdentifier
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

Future<String> saveMediaData(Uint8List videoData, int dataType) async {
  final directory = await getApplicationDocumentsDirectory();
  Directory? mediaDirectory;
  if (dataType == 1) {
    mediaDirectory = Directory('${directory.path}/videos');
  } else {
    // dataType 0
    mediaDirectory = Directory('${directory.path}/images');
  }
  String? extension;
  if (dataType == 1) {
    extension = 'brocastMp4';
  } else {
    extension = 'brocastPng';
  }
  final filePath = '${mediaDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.${extension}';
  final file = File(filePath);
  await file.writeAsBytes(videoData);
  return filePath;
}