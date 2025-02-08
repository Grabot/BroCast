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
  // TODO: Check if this is needed
  // bool isPrivate = true;

  String? data;

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
    map['info'] = info;
    map['timestamp'] = timestamp;
    map['data'] = data;
    return map;
  }

  Message.fromDbMap(Map<String, dynamic> map) {
    messageId = map['messageId'];
    senderId = map['senderId'];
    broupId = map['broupId'];
    body = map['body'];
    textMessage = map['textMessage'];
    info = map['info'];
    timestamp = map['timestamp'];
    data = map['data'];
    isRead = 0;
    clicked = false;
  }

  Message.fromJson(Map<String, dynamic> json) {
    messageId = json['message_id'];
    senderId = json['sender_id'];
    broupId = json['broup_id'];
    body = json['body'];
    if (json.containsKey('text_message')) {
      textMessage = json['text_message'];
    }
    info = json['info'];
    timestamp = json['timestamp'];
    if (json.containsKey('data')) {
      data = json['data'];
    }
    isRead = 0;
    clicked = false;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    // We don't check the messageId because it's not available when sending.
    // similarly we don't check the timestamp
    return other is Message
        && other.senderId == senderId
        && other.broupId == broupId
        && other.body == body
        && other.textMessage == textMessage
        && other.data == data;
  }
}
