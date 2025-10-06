import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:brocast/utils/location_sharing.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/storage.dart';
import 'data_type.dart';

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

  bool dataIsReceived = true;

  bool deleted = false;
  int? deletedByBroId;

  Message({
    required this.messageId,
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
    map['deleted'] = deleted ? 1 : 0;
    map['deletedByBroId'] = deletedByBroId;
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
    dataIsReceived = map['dataIsReceived'] == 1;
    repliedTo = map['repliedTo'];
    isRead = map['isRead'];
    emojiReactions = Map<String, String>.from(jsonDecode(map['emojiReactions']));
    clicked = false;
    deleted = map['deleted'] == 1;
    deletedByBroId = map['deletedByBroId'];
  }

  static Future<Message> fromJson(Map<String, dynamic> json) async {
    String timeStampMessage = json['timestamp'];
    if (!timeStampMessage.endsWith("Z")) {
      timeStampMessage = timeStampMessage + "Z";
    }
    final message = Message(
        messageId: json['message_id'],
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
      if (messageData.containsKey('data') || messageData.containsKey('location_data')) {
        if (messageData['data'] is List<int>) {
          // If the data is present, we set the flag to received
          message.dataIsReceived = true;
          Uint8List dataBytes = Uint8List.fromList(messageData['data']);
          message.data = await saveMediaData(dataBytes, DataType.image.value, null);
        } else if (messageData['data'] is String) {
          message.dataIsReceived = true;
          Uint8List dataBytes = base64Decode(messageData['data'].replaceAll("\n", ""));
          message.data = await saveMediaData(dataBytes, DataType.image.value, null);
        }
        if (messageData['location_data'] is String) {
          message.dataIsReceived = true;
          // For location data we don't save a path, but just the data itself
          message.data = messageData['location_data'];
        }
      }
      if (messageData.containsKey('type')) {
        message.dataType = messageData['type'];
        // If it's a live location message we keep track
        // of how long it needs to be active and from whom it is (and in which broup)
        if (message.dataType == DataType.liveLocation.value) {
          if (message.data != null) {
            message.dataIsReceived = true;
            // Get the information from the data field.
            String endTimeString = message.data!.split(";")[1];
            DateTime endTime = DateTime.parse(endTimeString).toLocal();
            int broId = message.senderId;
            int broupId = message.broupId;
            if (!DateTime.now().toLocal().isAfter(endTime)) {
              // Still active
              await Storage().addLocationSharing(
                  broId: broId,
                  broupId: broupId,
                  endTime: endTime,
                  meSharing: false,
                  messageId: message.messageId
              );
              await LocationSharing().startEndTimeBroTimer(endTime, broupId, broId);
            }
          }
        } else if (message.dataType == DataType.liveLocationStop.value) {
          message.dataIsReceived = true;
          int broId = message.senderId;
          int broupId = message.broupId;
          await LocationSharing().broShareTimeReached(broupId, broId, false);
        }
      }
    }

    if (json.containsKey('replied_to') && json['replied_to'] != null) {
      message.repliedTo = json['replied_to'];
    }
    if (json.containsKey('deleted') && json['deleted'] != null) {
      message.deleted = json['deleted'];
      // deleted by bro id will be send as a message update on the broup.
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
    return other is Message
        && other.messageId == messageId
        && other.senderId == senderId
        && other.broupId == broupId;
  }

  @override
  String toString() {
    return 'Message{messageId: $messageId, senderId: $senderId, body: $body, textMessage: $textMessage, timestamp: $timestamp, isRead: $isRead, clicked: $clicked, info: $info, broupId: $broupId, data: ${data != null}';
  }

  deleteMessageLocally(int broIdDelete) {
    if (data != null) {
      String filePath = data!;
      // Delete the file if it exists no matter the extension
      File file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    if (emojiReactions.isNotEmpty) {
      emojiReactions = {};
    }
    deleted = true;
    deletedByBroId = broIdDelete;
  }
}

Future<String> saveMediaData(Uint8List mediaData, int dataType, String? fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  Directory? mediaDirectory;
  if (dataType == DataType.image.value || dataType == DataType.gif.value) {
    mediaDirectory = Directory('${directory.path}/images');
  } else if (dataType == DataType.video.value) {
    mediaDirectory = Directory('${directory.path}/videos');
  } else if (dataType == DataType.audio.value) {
    mediaDirectory = Directory('${directory.path}/audio');
  } else if (dataType == DataType.other.value) {
    mediaDirectory = Directory('${directory.path}/other');
  } else {
    throw Exception('Unsupported data type');
  }
  String extension = "";
  if (dataType == DataType.image.value) {
    extension = 'brocastPng';
  } else if (dataType == DataType.video.value) {
    extension = 'brocastMp4';
  } else if (dataType == DataType.audio.value) {
    extension = 'brocastM4a';
  } else if (dataType == DataType.gif.value) {
    extension = 'brocastGif';
  } else if (dataType == DataType.other.value) {
    if (fileName == null) {
      throw Exception('Unsupported extension');
    }
  }
  String filePath = '${mediaDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.${extension}';
  if (dataType == DataType.other.value) {
    filePath = '${mediaDirectory.path}/${fileName}';
  }
  final file = File(filePath);
  await file.writeAsBytes(mediaData);
  return filePath;
}

Future<String> saveMediaFile(File mediaFile, int dataType) async {
  final directory = await getApplicationDocumentsDirectory();
  Directory? mediaDirectory;
  if (dataType == DataType.image.value || dataType == DataType.gif.value) {
    mediaDirectory = Directory('${directory.path}/images');
  } else if (dataType == DataType.video.value) {
    mediaDirectory = Directory('${directory.path}/videos');
  } else if (dataType == DataType.audio.value) {
    mediaDirectory = Directory('${directory.path}/audio');
  } else if (dataType == DataType.other.value) {
    mediaDirectory = Directory('${directory.path}/other');
  } else {
    throw Exception('Unsupported data type');
  }
  String extension = "";
  if (dataType == DataType.image.value) {
    extension = 'brocastPng';
  } else if (dataType == DataType.video.value) {
    extension = 'brocastMp4';
  } else if (dataType == DataType.audio.value) {
    extension = 'brocastM4a';
  } else if (dataType == DataType.gif.value) {
    extension = 'brocastGif';
  }
  String filePath = '${mediaDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.${extension}';
  if (dataType == DataType.other.value) {
    // For "other" we keep the original filename.
    String fileName = mediaFile.path.split("/").last;
    List<String> notAllowedExtensions = [
      'sh', 'bash', 'zsh', 'py', 'js', 'ts', 'ps1', 'rb', 'pl', 'php',
      'lua', 'bat', 'cmd', 'vbs', 'awk', 'sed', 'fish', 'tcl', 'psm1',
      'exe', 'msi', 'bin', 'out', 'run', 'app', 'jar',
    ];
    filePath = '${mediaDirectory.path}/${fileName}';
    String fileExtension = fileName.split('.').last.toLowerCase();
    if (notAllowedExtensions.contains(fileExtension)) {
      fileName += ".txt";
      filePath = '${mediaDirectory.path}/${fileName}';
    }
  }
  await mediaFile.copy(filePath);
  return filePath;
}
