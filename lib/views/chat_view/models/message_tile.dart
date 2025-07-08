import 'package:flutter/material.dart';

import '../../../../objects/message.dart';
import '../../../objects/bro.dart';
import 'bro_message_tile.dart';
import 'broup_message_tile.dart';

class MessageTile extends StatefulWidget {
  final bool private;
  final Message message;
  final Bro? bro;
  final bool broAdded;
  final bool broAdmin;
  final bool myMessage;
  final bool userAdmin;
  final Message? repliedMessage;
  final Bro? repliedBro;
  final void Function(int, int) messageHandling;
  final void Function(Message, Offset) messageLongPress;

  MessageTile({
    required Key key,
    required this.private,
    required this.message,
    required this.bro,
    required this.broAdded,
    required this.broAdmin,
    required this.myMessage,
    required this.userAdmin,
    required this.repliedMessage,
    required this.repliedBro,
    required this.messageHandling,
    required this.messageLongPress,
  }) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.messageHandling(0, widget.message.messageId);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Widget messageTile = Container();
    if (widget.private) {
      messageTile = BroMessageTile(
          key: UniqueKey(),
          message: widget.message,
          bro: widget.bro,
          broAdded: widget.broAdded,
          broAdmin: widget.broAdmin,
          myMessage: widget.myMessage,
          userAdmin: widget.userAdmin,
          repliedMessage: widget.repliedMessage,
          repliedBro: widget.repliedBro,
          messageHandling: widget.messageHandling,
          messageLongPress: widget.messageLongPress);
    } else {
      messageTile = BroupMessageTile(
          key: UniqueKey(),
          message: widget.message,
          bro: widget.bro,
          broAdded: widget.broAdded,
          broAdmin: widget.broAdmin,
          myMessage: widget.myMessage,
          userAdmin: widget.userAdmin,
          repliedMessage: widget.repliedMessage,
          repliedBro: widget.repliedBro,
          messageHandling: widget.messageHandling,
          messageLongPress: widget.messageLongPress);
    }
    return messageTile;
  }
}