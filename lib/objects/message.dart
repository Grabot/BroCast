class Message {

  late int id;
  late int senderId;
  late int recipientId;
  late String body;
  late String textMessage;
  late String timestamp;

  late bool isRead;
  late bool clicked;
  late int info;

  Message(int id, int senderId, int recipientId, String body,
      String textMessage, String timestamp, int info) {
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
    isRead = false;
    clicked = false;
  }

  DateTime getTimeStamp() {
    return DateTime.parse(timestamp).toLocal();
  }

  bool isInformation() {
    return info == 1;
  }
}
