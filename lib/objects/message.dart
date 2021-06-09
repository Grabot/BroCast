class Message {
  int id;
  int broBrosId;
  int senderId;
  int recipientId;
  String body;
  String textMessage;
  DateTime timestamp;

  bool isRead;
  bool clicked;

  Message(int id, int broBrosId, int senderId, int recipientId, String body,
      String textMessage, String timestamp) {
    this.id = id;
    this.broBrosId = broBrosId;
    this.senderId = senderId;
    this.recipientId = recipientId;
    this.body = body;
    this.textMessage = textMessage;
    if (timestamp != null) {
      this.timestamp = DateTime.parse(timestamp + 'Z').toLocal();
    } else {
      this.timestamp = null;
    }
    isRead = false;
    clicked = false;
  }
}
