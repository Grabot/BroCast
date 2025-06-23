import '../../../objects/message.dart';

class RepliedToMessage {
  late Message repliedMessage;
  late String senderName;

  RepliedToMessage(Message repliedMessage, String senderName) {
    this.repliedMessage = repliedMessage;
    this.senderName = senderName;
  }
}
