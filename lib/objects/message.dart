class Message {

  late int id;
  late int senderId;
  late int recipientId;
  late String body;
  late String textMessage;
  late String timestamp;

  late int isRead;
  late bool clicked;
  late int info;

  late int chatId;
  late int isBroup;

  Message(int id, int senderId, int recipientId, String body,
      String textMessage, String timestamp, int info, int chatId, int isBroup) {
    this.id = id;
    this.senderId = senderId;
    this.recipientId = recipientId;
    this.body = body;
    this.textMessage = textMessage;
    if (timestamp.endsWith("Z")) {
      this.timestamp = timestamp;
    } else {
      // The server has utc timestamp, but it's not formatted with the 'Z'.
      this.timestamp = timestamp + "Z";
    }
    this.info = info;
    this.chatId = chatId;
    this.isBroup = isBroup;
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
    return info == 1;
  }

  bool hasBeenRead() {
    return isRead == 1;
  }

  Map<String, dynamic> toDbMap() {
    var map = Map<String, dynamic>();
    map['messageId'] = id;
    map['senderId'] = senderId;
    if (isBroup == 1) {
      map['chatId'] = chatId;
    } else {
      map['chatId'] = recipientId;
    }
    map['body'] = body;
    map['textMessage'] = textMessage;
    map['info'] = info;
    map['timestamp'] = timestamp;
    map['isBroup'] = isBroup;
    return map;
  }

  Message.fromDbMap(Map<String, dynamic> map) {
    id = map['messageId'];
    senderId = map['senderId'];
    if (map['isBroup'] == 1) {
      recipientId = map['senderId'];
    } else {
      recipientId = map['chatId'];
    }
    chatId = map['chatId'];
    body = map['body'];
    textMessage = map['textMessage'];
    info = map['info'];
    timestamp = map['timestamp'];
    isBroup = map['isBroup'];
    isRead = 0;
    clicked = false;
  }
}
