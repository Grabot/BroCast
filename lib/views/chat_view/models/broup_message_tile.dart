import 'dart:typed_data';
import 'package:brocast/views/chat_view/image_viewer/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import '../../../../objects/message.dart';
import '../../../objects/bro.dart';
import 'dart:ui';

import '../../../utils/utils.dart';

class BroupMessageTile extends StatefulWidget {
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

  BroupMessageTile({
    required Key key,
    required this.message,
    required this.bro,
    required this.broAdded,
    required this.broAdmin,
    required this.myMessage,
    required this.userAdmin,
    required this.repliedMessage,
    required this.repliedBro,
    required this.messageHandling,
    required this.messageLongPress
  }) : super(key: key);

  @override
  _BroupMessageTileState createState() => _BroupMessageTileState();
}

class _BroupMessageTileState extends State<BroupMessageTile> with SingleTickerProviderStateMixin {

  bool isImage = false;

  selectMessage(BuildContext context) {
    if ((widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) || isImage) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
    }
  }

  Image? broImage;

  late final controller = SlidableController(this);
  bool replying = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.data != null) {
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
    replying = false;
    super.dispose();
  }

  Color getBorderColour() {
    Color borderColour = widget.myMessage
        ? Color(0xFF009E00)
        : Color(0xFF0060BB);

    if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
      borderColour = Colors.yellow;
    }

    if (isImage) {
      borderColour = Colors.red;
    }

    return borderColour;
  }


  clickedEmojiReaction() {
    widget.messageHandling(3, widget.message.messageId);
  }

  replyToMessage() {
    widget.messageHandling(1, widget.message.messageId);
  }

  clickedReplyMessage() {
    if (widget.message.repliedTo != null) {
      // It's possible that the message is not on your phone anymore
      // In this case we have an empty message with messageId 0 and info set to true
      // We want to ignore this
      if (widget.message.repliedMessage != null && widget.message.repliedMessage!.messageId != 0 && !widget.message.repliedMessage!.info) {
        widget.messageHandling(2, widget.message.repliedTo!);
      }
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  Widget viewImageButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageViewer(
                      key: UniqueKey(),
                      image: widget.message.data!,
                    ),
                  ),
                ).then((_) { });
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(
                  Icons.remove_red_eye,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget repliedToView() {
    Message? repliedToMessage = widget.repliedMessage;
    if (repliedToMessage == null) {
      return Container();
    } else {
      String replySenderName = "Message not available";
      if (widget.repliedBro != null) {
        replySenderName = widget.repliedBro!.getFullName();
      }
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            clickedReplyMessage();
          },
          splashColor: const Color(0x56e4e4e4),
          child: Container(
            color: Colors.black.withAlpha(64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.reply,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      replySenderName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                if (repliedToMessage.body != "")
                  Text(
                    repliedToMessage.body,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  double getOptionWidth(String messageContent, TextStyle textStyle) {
    final textSpan = TextSpan(
      text: messageContent,
      style: textStyle
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    final textWidth = textPainter.size.width;

    // Add the padding and some final adjustments
    return textWidth + 8;
  }

  double getMessageWidgetWidth() {
    if (widget.message.clicked) {
      if (isImage) {
        return MediaQuery.of(context).size.width;
      }
    }
    double widgetWidth = getOptionWidth(widget.message.body, simpleTextStyle());
    if (widget.message.clicked) {
      // If it is clicked we want to check which is larger, the body or the textMessage
      // The width is the largest of the two
      // Or, if it has data than the width is maximum
      if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
        double textMessageWidth = getOptionWidth(widget.message.textMessage!, simpleTextStyle());
        if (textMessageWidth > widgetWidth) {
          widgetWidth = textMessageWidth;
        }
      }
    }
    if (widget.message.repliedMessage != null) {
      Message repliedToMessage = widget.message.repliedMessage!;
      if (repliedToMessage.body != "") {
        TextStyle replyTextStyle = TextStyle(color: Colors.white);
        double repliedToBodyWidth = getOptionWidth(repliedToMessage.body, replyTextStyle);
        String replySenderName = "Message not available";
        if (widget.repliedBro != null) {
          replySenderName = widget.repliedBro!.getFullName();
        }
        double repliedToNameWidth = getOptionWidth(replySenderName, replyTextStyle);
        // Add the reply icon width
        repliedToNameWidth += 20;
        if (repliedToBodyWidth > repliedToNameWidth) {
          if (repliedToBodyWidth > widgetWidth) {
            widgetWidth = repliedToBodyWidth;
          }
        } else {
          if (repliedToNameWidth > widgetWidth) {
            widgetWidth = repliedToNameWidth;
          }
        }
      }
    }
    return widgetWidth;
  }

  Widget getMessageContent(double messageWidth) {
    Widget content;
    if (widget.message.clicked) {
      if (isImage) {
        if (widget.message.textMessage != null && widget.message.textMessage!.isNotEmpty) {
          content = Column(
              mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                viewImageButton(),
                repliedToView(),
                Text(
                    widget.message.body,
                    style: simpleTextStyle()
                ),
                Image.memory(widget.message.data!),
                Linkify(
                    onOpen: _onOpen,
                    text: widget.message.textMessage!,
                    linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
                    style: simpleTextStyle()
                )
              ]
          );
        } else {
          content = Column(
              mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                viewImageButton(),
                repliedToView(),
                Text(
                    widget.message.body,
                    style: simpleTextStyle()
                ),
                Image.memory(widget.message.data!),
              ]
          );
        }
      } else {
        content = Column(
            mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              repliedToView(),
              Text(
                  widget.message.body,
                  style: simpleTextStyle()
              ),
              Linkify(
                  onOpen: _onOpen,
                  text: widget.message.textMessage!,
                  linkStyle: TextStyle(color: Color(0xffFFC0CB), fontSize: 18),
                  style: simpleTextStyle()
              ),
            ]
        );
      }
    } else {
      content = Column(
          mainAxisAlignment: widget.myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: widget.myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            repliedToView(),
            Text(
                widget.message.body,
                style: simpleTextStyle()
            ),
          ]
      );
    }

    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        width: messageWidth,
        child: content,
      ),
    );
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
          ),
        ]
    );
  }

  Widget senderIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.bro != null ? widget.bro!.getFullName() : "",
                  style: TextStyle(
                      color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget broTimeIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('HH:mm')
                      .format(widget.message.getTimeStamp()),
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                WidgetSpan(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myTimeIndicator(double messageWidth) {
    return Container(
      width: messageWidth,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: DateFormat('HH:mm')
                      .format(widget.message.getTimeStamp()),
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                widget.message.isRead == 2
                    ? WidgetSpan(
                    child: Icon(Icons.done,
                        color: Colors.white54, size: 18))
                    : WidgetSpan(
                    child: Icon(Icons.done_all,
                        color: widget.message.hasBeenRead()
                            ? Colors.blue
                            : Colors.white54,
                        size: 18))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget timeIndicator(double messageWidth) {
    return widget.myMessage ? myTimeIndicator(messageWidth) : broTimeIndicator(messageWidth);
  }

  Widget emojiReactionWidget(double messageWidth) {
    if (widget.message.getEmojiReaction().isEmpty) {
      return Container();
    } else {
      final ScrollController scrollController = ScrollController();
      List<String> emojiReactions = widget.message.getEmojiReaction().values.toList();
      double emojiWidth = 24;
      double totalEmojiWidth = 24;
      if (emojiReactions.length > 1) {
        totalEmojiWidth += (emojiReactions.length - 1) * 16.0;
      }

      double maxPosition = totalEmojiWidth - (messageWidth + 24);
      bool disableScrolling = totalEmojiWidth < (messageWidth + 24);
      scrollController.addListener(() {
        if (scrollController.position.pixels > maxPosition) {
          scrollController.jumpTo(maxPosition);
        }
      });
      double actualWidth = messageWidth + 24;
      double difference = 0;
      if (totalEmojiWidth < actualWidth) {
        difference = actualWidth - totalEmojiWidth;
        actualWidth = totalEmojiWidth;
      }
      return Positioned(
        bottom: 0,
        right: widget.myMessage ? 12 + difference : null,
        left: widget.myMessage ? null : 12 + difference,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              clickedEmojiReaction();
            },
            child: Container(
              height: emojiWidth,
              width: actualWidth,
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: disableScrolling ? NeverScrollableScrollPhysics() : null,
                child: Row(
                  children: List.generate(emojiReactions.length, (index) {
                    return Transform.translate(
                      offset: Offset(-index * 8.0, 0),
                      child: Container(
                        width: emojiWidth,
                        height: emojiWidth,
                        child: Text(
                          emojiReactions[index],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget messageBox() {
    // The width that is bound by the message content.
    // Used for the messageBox and the emojiReactionWidget
    double messageWidth = getMessageWidgetWidth();
    return Stack(
      children: [
        Align(
          alignment: widget.myMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: widget.message.getEmojiReaction().length == 0 ? 12 : 20
            ),
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
                child: getMessageContent(messageWidth)
            ),
          ),
        ),
        emojiReactionWidget(messageWidth)
      ],
    );
  }

  Widget regularMessage() {
    double avatarSize = 50;
    double messageWidth = MediaQuery.of(context).size.width - avatarSize;
    Uint8List? broAvatar = null;
    if (widget.bro != null) {
      broAvatar = widget.bro!.getAvatar();
    }
    return Container(
        margin: EdgeInsets.only(top: 6),
        child: Container(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    width: avatarSize,
                    child: widget.myMessage ? Container() : avatarBox(avatarSize, avatarSize, broAvatar)
                ),
                Material(
                  child: Column(
                      children: [
                        widget.myMessage
                            ? Container()
                            : senderIndicator(messageWidth),
                        Container(
                          width: messageWidth,
                          alignment: widget.myMessage
                              ? Alignment.bottomRight
                              : Alignment.bottomLeft,
                          child: GestureDetector(
                            onLongPressStart: (details) =>
                                onLongPressMessage(context, details),
                            onTap: () {
                              selectMessage(context);
                            },
                            child: messageBox(),
                          ),
                        ),
                        timeIndicator(messageWidth),
                      ]
                  ),
                  color: Colors.transparent,
                ),
              ]
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.isInformation()
      ? informationMessage()
      : Slidable(
      controller: controller,
      key: const ValueKey(0),
      closeOnScroll: true,
      // The start action pane is the one at the left or the top side.
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
