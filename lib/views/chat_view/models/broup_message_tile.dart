import 'dart:typed_data';
import 'package:brocast/views/chat_view/image_viewer/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../objects/message.dart';
import '../../../objects/bro.dart';
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
  final void Function(int, int) broHandling;

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
    required this.broHandling
  }) : super(key: key);

  @override
  _BroupMessageTileState createState() => _BroupMessageTileState();
}

class _BroupMessageTileState extends State<BroupMessageTile> with SingleTickerProviderStateMixin {
  var _tapPosition;
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

  replyToMessage() {
    widget.broHandling(3, widget.message.messageId);
  }

  clickedReplyMessage() {
    if (widget.message.repliedTo != null) {
      // It's possible that the message is not on your phone anymore
      // In this case we have an empty message with messageId 0 and info set to true
      // We want to ignore this
      if (widget.message.repliedMessage != null && widget.message.repliedMessage!.messageId != 0 && !widget.message.repliedMessage!.info) {
        widget.broHandling(6, widget.message.repliedTo!);
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

  Widget getMessageContent() {
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
      child: IntrinsicWidth(
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
                            onLongPress: _showMessageDetailPopupMenu,
                            onTapDown: _storePosition,
                            onTap: () {
                              selectMessage(context);
                            },
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
                        timeIndicator(messageWidth),
                      ]
                  ),
                  color: Colors.transparent,
                ),
              ]
          ),
        )
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

  void _showMessageDetailPopupMenu() {
    bool imageShowing = isImage && widget.message.clicked;
    if (!widget.myMessage || imageShowing) {
      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu(
          context: context,
          items: [
            MessageDetailPopup(
                key: UniqueKey(),
                myMessage: widget.myMessage,
                sender: widget.bro != null ? widget.bro!.getFullName() : "",
                broAdded: widget.broAdded,
                broAdmin: widget.broAdmin,
                userAdmin: widget.userAdmin,
                imageShowing: imageShowing
            )
          ],
          position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
              Offset.zero & overlay.size))
      .then((int? delta) {
        if (delta == 1) {
          if (widget.bro != null) {
            widget.broHandling(delta!, widget.bro!.getId());
          }
        } else if (delta == 2) {
          if (widget.bro != null) {
            widget.broHandling(delta!, widget.bro!.getId());
          }
        } else if (delta == 3) {
          saveImageToGallery();
        } else if (delta == 4) {
          if (widget.bro != null) {
            widget.broHandling(delta!, widget.bro!.getId());
          }
        } else if (delta == 5) {
          if (widget.bro != null) {
            widget.broHandling(delta!, widget.bro!.getId());
          }
        }
        return;
      });
    }
  }

  Future<bool> requestPermissions() async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      return await Gal.requestAccess();
    } else {
      return true;
    }
  }

  Future<void> saveImageToGallery() async {
    try {
      bool access = await requestPermissions();
      if (!access) {
        showToastMessage("No access to gallery");
        return;
      }
      if (widget.message.data != null) {
        Uint8List decoded = widget.message.data!;
        final albumName = "Brocast";
        await Gal.putImageBytes(decoded, album: albumName);
        showToastMessage("Image saved");
      }
    } catch (e) {
      showToastMessage("Failed to save image: $e");
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

class MessageDetailPopup extends PopupMenuEntry<int> {
  final String sender;
  final bool myMessage;
  final bool broAdded;
  final bool broAdmin;
  final bool userAdmin;
  final bool imageShowing;

  MessageDetailPopup(
      {
        required Key key,
        required this.myMessage,
        required this.sender,
        required this.broAdded,
        required this.broAdmin,
        required this.userAdmin,
        required this.imageShowing
      })
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  MessageDetailPopupState createState() => MessageDetailPopupState();

  @override
  double get height => 1;
}

class MessageDetailPopupState extends State<MessageDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context, widget.sender, widget.broAdded, widget.broAdmin, widget.imageShowing, widget.myMessage, widget.userAdmin);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonAdd(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

void buttonSaveImage(BuildContext context) {
  Navigator.pop<int>(context, 3);
}

void buttonAddToAdmin(BuildContext context) {
  Navigator.pop<int>(context, 4);
}

void buttonRemoveToAdmin(BuildContext context) {
  Navigator.pop<int>(context, 5);
}

Widget getPopupItems(BuildContext context, String sender, bool broAdded, bool broIsAdmin, bool imageShowing, bool myMessage, bool userAdmin) {
  return Column(children: [
    broAdded && !myMessage
        ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonMessage(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            'Message $sender',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    )
        : Container(),
    !broAdded && !myMessage
        ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonAdd(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            'Add $sender',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ) : Container(),
    userAdmin && !broIsAdmin ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonAddToAdmin(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            'Make $sender admin',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ) : Container(),
    userAdmin && broIsAdmin ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonRemoveToAdmin(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            'Dismiss $sender from admins',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ) : Container(),
    imageShowing ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonSaveImage(context);
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            'Save image to gallery',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ) : Container(),
  ]);
}
