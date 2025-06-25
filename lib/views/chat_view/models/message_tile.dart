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
  final void Function(int, int) broHandling;

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
    required this.broHandling
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.private) {
      BroMessageTile broMessageTile = BroMessageTile(
          key: UniqueKey(),
          message: widget.message,
          myMessage: widget.myMessage,
          repliedMessage: widget.repliedMessage,
          repliedBro: widget.repliedBro,
          broHandling: widget.broHandling);
      return broMessageTile;
    } else {
      return BroupMessageTile(
          key: UniqueKey(),
          message: widget.message,
          bro: widget.bro,
          broAdded: widget.broAdded,
          broAdmin: widget.broAdmin,
          myMessage: widget.myMessage,
          userAdmin: widget.userAdmin,
          repliedMessage: widget.repliedMessage,
          repliedBro: widget.repliedBro,
          broHandling: widget.broHandling);
    }
  }
}