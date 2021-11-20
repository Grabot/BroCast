class Message {

  late int id;
  late int broBrosId;
  late int senderId;
  late int recipientId;
  late String body;
  late String textMessage;
  late DateTime timestamp;

  late bool isRead;
  late bool clicked;

  Message(int id, int broBrosId, int senderId, int recipientId, String body,
      String? textMessage, String? timestamp) {
    this.id = id;
    this.broBrosId = broBrosId;
    this.senderId = senderId;
    this.recipientId = recipientId;
    this.body = body;
    if (textMessage == null) {
      this.textMessage = "";
    } else {
      this.textMessage = textMessage;
    }
    if (timestamp != null) {
      this.timestamp = DateTime.parse(timestamp + 'Z').toLocal();
    } else {
      this.timestamp = DateTime.now(); // TODO: @Skools check if time tiles stay correct. It sorts on time and LATER adds the time tiles, so it should be correct. Maybe make it better?
    }
    isRead = false;
    clicked = false;
  }
}
