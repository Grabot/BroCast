import 'dart:io';
import 'package:flutter/material.dart';
import '../../../objects/broup.dart';
import '../../../utils/utils.dart';
import '../../chat_view/chat_messaging.dart';
import '../../chat_view/messaging_change_notifier.dart';


class BroTile extends StatefulWidget {
  final Broup chat;
  final void Function() callback;

  BroTile({required Key key, required this.chat, required this.callback}) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {
  var _tapPosition;

  selectBro(BuildContext context) {
    MessagingChangeNotifier().setBroupId(widget.chat.broupId);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ChatMessaging(
              key: UniqueKey(),
              chat: widget.chat
          )
      ),
      // ModalRoute.withName(routes.ChatRoute)
    );
  }

  Color getColorStrength() {
    if (widget.chat.unreadMessages == 0) {
      return widget.chat.getColor().withAlpha(153);
    }
    if (widget.chat.unreadMessages == 1) {
      return widget.chat.getColor().withAlpha(180);
    }
    if (widget.chat.unreadMessages == 2) {
      return widget.chat.getColor().withAlpha(205);
    }
    if (widget.chat.unreadMessages == 3) {
      return widget.chat.getColor().withAlpha(230);
    }
    return widget.chat.getColor().withAlpha(255);
  }

  Widget broAvatarBox(double avatarSize) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      child: avatarBox(avatarSize, avatarSize, widget.chat.getAvatar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double avatarSize = 60;
    return Container(
      child: Material(
        child: InkWell(
          onLongPress: _showChatDetailPopupMenu,
          onTapDown: _storePosition,
          onTap: () {
            selectBro(context);
          },
          child: Container(
              color: getColorStrength(),
              padding: EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      widget.chat.isMuted() ||
                          widget.chat.isRemoved()
                          ? Container(
                          width: 25,
                          child: Column(children: [
                            widget.chat.isRemoved()
                                ? Icon(
                                Icons.block,
                                color:
                                getTextColor(widget.chat.getColor())
                                    .withAlpha(160))
                                : Container(
                              height: 20,
                            ),
                            widget.chat.isMuted()
                                ? Icon(Icons.volume_off,
                                color:
                                getTextColor(widget.chat.getColor())
                                    .withAlpha(160))
                                : Container(
                              height: 20,
                            ),
                          ]))
                          : SizedBox(width: 25),
                      broAvatarBox(avatarSize),
                      SizedBox(width: 10),
                      Container(
                        width: MediaQuery.of(context).size.width - (103 + avatarSize + 35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // All the padding and sizedboxes (and message bal) added up it's 103.
                              // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                              width: MediaQuery.of(context).size.width - (103 + avatarSize + 35),
                              child: Text(widget.chat.getBroupNameOrAlias(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                            widget.chat.alias != ""
                                ? Container(
                              // If there is an alias, we want to show the name of the bro as well.
                              // We will do that in smaller letters underneath
                              width:
                              MediaQuery.of(context).size.width - (103 + avatarSize + 35),
                              child: Text("     -" + widget.chat.getBroupName(),
                                  style: TextStyle(
                                      color: getTextColor(
                                          widget.chat.getColor()),
                                      fontSize: 10)),
                            )
                                : Container(),
                            widget.chat.getBroupDescription() != ""
                                ? Container(
                              // All the padding and sizedboxes (and message bal) added up it's 103.
                              // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                              width:
                              MediaQuery.of(context).size.width - (103 + avatarSize + 35),
                              child: Text(widget.chat.getBroupDescription(),
                                  style: TextStyle(
                                      color: getTextColor(
                                          widget.chat.getColor()),
                                      fontSize: 12)),
                            )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: widget.chat.getColor(),
                          borderRadius: BorderRadius.circular(40)),
                      child: Text(
                        widget.chat.unreadMessages.toString(),
                        style: TextStyle(
                            color: getTextColor(widget.chat.getColor()),
                            fontSize: 16),
                      )),
                ],
              )),
        ),
        color: Colors.transparent,
      ),
    );
  }

  void showDialogUnMuteChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Unmute notifications?"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Unmute"),
                onPressed: () {
                  unmuteTheChat();
                },
              ),
            ],
          );
        });
  }

  void showDialogMuteChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Mute notifications for..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(4, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedRadio = index);
                      },
                      child: Row(children: [
                        Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => selectedRadio = value);
                              }
                            }),
                        index == 0
                            ? Container(child: Text("1 hour"))
                            : Container(),
                        index == 1
                            ? Container(child: Text("8 hours"))
                            : Container(),
                        index == 2
                            ? Container(child: Text("1 week"))
                            : Container(),
                        index == 3
                            ? Container(child: Text("Indefinitely"))
                            : Container(),
                      ]),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Mute"),
                onPressed: () {
                  muteTheChat(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  void unmuteTheChat() {
    // TODO: add mute functionality
    // if (widget.chat is BroBros) {
    //   socketServices.socket.emit("message_event_change_chat_mute", {
    //     "token": settings.getToken(),
    //     "bros_bro_id": widget.chat.id,
    //     "bro_id": settings.getBroId(),
    //     "mute": -1
    //   });
    // } else {
    //   socketServices.socket.emit("message_event_change_broup_mute", {
    //     "token": settings.getToken(),
    //     "broup_id": widget.chat.id,
    //     "bro_id": settings.getBroId(),
    //     "mute": -1
    //   });
    // }
    Navigator.of(context).pop();
  }

  void muteTheChat(int selectedRadio) {
    // TODO: add mute functionality
    // if (widget.chat is BroBros) {
    //   socketServices.socket.emit("message_event_change_chat_mute", {
    //     "token": settings.getToken(),
    //     "bros_bro_id": widget.chat.id,
    //     "bro_id": settings.getBroId(),
    //     "mute": selectedRadio
    //   });
    // } else {
    //   socketServices.socket.emit("message_event_change_broup_mute", {
    //     "token": settings.getToken(),
    //     "broup_id": widget.chat.id,
    //     "bro_id": settings.getBroId(),
    //     "mute": selectedRadio
    //   });
    // }
    Navigator.of(context).pop();
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [ChatDetailPopup(key: UniqueKey(), chat: widget.chat)],
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), Offset.zero & overlay.size))
        .then((int? delta) {
      if (delta == 1) {
        selectBro(context);
      } else if (delta == 2) {
        showDialogMuteChat(context);
      } else if (delta == 3) {
        showDialogUnMuteChat(context);
      }
      return;
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

class ChatDetailPopup extends PopupMenuEntry<int> {
  final Broup chat;

  ChatDetailPopup({required Key key, required this.chat}) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  ChatDetailPopupState createState() => ChatDetailPopupState();

  @override
  double get height => 1;
}

class ChatDetailPopupState extends State<ChatDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context, widget.chat);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonMute(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

void buttonUnmute(BuildContext context) {
  Navigator.pop<int>(context, 3);
}

Widget getPopupItems(BuildContext context, Broup chat) {
  return Column(children: [
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonMessage(context);
          },
          child: Text(
            'Message ${chat.getBroupNameOrAlias()}',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ),
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            chat.isMuted() ? buttonUnmute(context) : buttonMute(context);
          },
          child: Text(
            chat.isMuted() ? 'Unmute chat' : 'Mute chat',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ),
  ]);
}
