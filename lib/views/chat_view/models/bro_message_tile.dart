import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../objects/bro.dart';
import '../../../objects/message.dart';
import '../../../utils/utils.dart';


class BroMessageTile extends StatefulWidget {
  final Message message;
  final bool myMessage;
  final Message? repliedMessage;
  final Bro? repliedBro;
  final void Function(int, int) messageHandling;
  final void Function(Message, Offset) messageLongPress;

  BroMessageTile(
      {
        required Key key,
        required this.message,
        required this.myMessage,
        required this.repliedMessage,
        required this.repliedBro,
        required this.messageHandling,
        required this.messageLongPress,
      })
      : super(key: key);

  @override
  _BroMessageTileState createState() => _BroMessageTileState();
}

class _BroMessageTileState extends State<BroMessageTile> with SingleTickerProviderStateMixin {

  var _tapPosition;
  bool isImage = false;

  late final controller = SlidableController(this);
  bool replying = false;

  selectMessage(BuildContext context) {
    if ((widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) || isImage) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
    }
  }

  Image? broImage;

  @override
  void initState() {
    super.initState();
    if (widget.message.data != null) {
      broImage = Image.memory(widget.message.data!);
      isImage = true;
    }

    // If the slide is made we want to trigger the replied to functionality.
    controller.endGesture.addListener(() {
      // We close the controller, which will put the message back in its original position
      // The replied to functionality is handled in the parent widget
      if (controller.animation.value > 0.1) {
        replying = true;
      }
      controller.close();
    });

    controller.direction.addListener(() {
      // 0 means stopped moving. If the replied to was triggered
      // and it is no longer moving, we want to trigger the replied to functionalit
      if (replying && controller.direction.value == 0) {
        replyToMessage();
      }
    });
  }

  @override
  void dispose() {
    controller.endGesture.removeListener(() {});
    super.dispose();
  }

  Color getBorderColour() {
    // First we set the border to be the colour of the message
    // Which is the colour for a normal plain message without content
    Color borderColour = widget.myMessage
        ? Color(0xFF009E00)
        : Color(0xFF0060BB);
    // We check if there is a message content
    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      // If this is the case the border should be yellow, but only if it's not clicked
      borderColour = Colors.yellow;
    }
    // Now we check if it's maybe a data message with an image!
    if (isImage) {
      borderColour = Colors.red;
    }
    return borderColour;
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  replyToMessage() {
    widget.messageHandling(1, widget.message.messageId);
  }

  Widget getMessageContent() {
    // We show the normal body, unless it's clicked. Than we show the extra info
    if (widget.message.clicked) {
      // If it's clicked we show the extra text message or the image!
      if (isImage) {
        if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
          return Column(
              children: [
                broImage!,
                Linkify(
                    onOpen: _onOpen,
                    text: widget.message.textMessage!,
                    linkStyle: TextStyle(color: Color(0xffD3D3D3), fontSize: 18),
                    style: simpleTextStyle()
                )
              ]
          );
        } else {
          return broImage!;
        }
      } else {
        return Linkify(
            onOpen: _onOpen,
            text: widget.message.textMessage!,
            linkStyle: TextStyle(color: Color(0xffD3D3D3), fontSize: 18),
            style: simpleTextStyle()
        );
      }
    } else {
      return Text(
          widget.message.body,
          style: simpleTextStyle()
      );
    }
  }

  Widget informationMessage() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            constraints: BoxConstraints(minWidth: 10, maxWidth: MediaQuery.of(context).size.width),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0x55D3D3D3),
                    const Color(0x55C0C0C0)
                  ]),
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.message.body,
                      style: TextStyle(
                          color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]);
  }
  Widget regularMessage() {
    return Container(
        child: new Material(
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              margin: EdgeInsets.only(top: 12),
              width: MediaQuery.of(context).size.width,
              alignment: widget.myMessage
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: new GestureDetector(
                onTap: () {
                  selectMessage(context);
                },
                onLongPressStart: (details) =>
                    onLongPressMessage(context, details),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: getBorderColour(),
                        width: 2,
                      ),
                      color: widget.myMessage
                          ? Color(0xFF009E00)
                          : Color(0xFF0060BB),
                      borderRadius: widget.myMessage
                          ? BorderRadius.only(
                          topLeft: Radius.circular(42),
                          bottomRight: Radius.circular(42),
                          bottomLeft: Radius.circular(42))
                          : BorderRadius.only(
                          bottomLeft: Radius.circular(42),
                          topRight: Radius.circular(42),
                          bottomRight: Radius.circular(42))),
                  child: Container(
                      child: getMessageContent()
                  ),
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: widget.myMessage
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: DateFormat('HH:mm')
                              .format(widget.message.getTimeStamp()),
                          style:
                          TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        widget.myMessage
                            ? widget.message.isRead != 2
                            ? WidgetSpan(
                            child: Icon(Icons.done_all,
                                color: widget.message.hasBeenRead()
                                    ? Colors.blue
                                    : Colors.white54,
                                size: 18))
                            : WidgetSpan(
                            child: Icon(Icons.done,
                                color: Colors.white54, size: 18))
                            : WidgetSpan(child: Container()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
          color: Colors.transparent,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.isInformation()
        ? informationMessage()
        : Slidable(
      controller: controller,
      key: const ValueKey(0),
      closeOnScroll: true,
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              replyToMessage();
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            icon: Icons.reply,
          ),
        ],
      ),
      child: regularMessage(),
    );
  }

  void onLongPressMessage(BuildContext context, LongPressStartDetails details) {
    print("long pressed message");
    Offset pressPosition = details.globalPosition;
    widget.messageLongPress(widget.message, pressPosition);
  }
}
