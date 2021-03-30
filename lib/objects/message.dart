


class Message {

  int id;
  int broBrosId;
  int senderId;
  int recipientId;
  String body;
  DateTime timestamp;

  Message(
  int id,
  int broBrosId,
  int senderId,
  int recipientId,
  String body,
  String timestamp
      ) {
    this.id = id;
    this.broBrosId = broBrosId;
    this.senderId = senderId;
    this.recipientId = recipientId;
    this.body = body;
    this.timestamp = DateTime.parse(timestamp + 'Z');
  }

}