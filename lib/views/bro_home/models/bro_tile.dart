 import 'package:brocast/views/chat_view/bro_messaging/bro_messaging.dart';
import 'package:flutter/material.dart';

import '../../../objects/broup.dart';
import '../../../services/navigation_service.dart';
import '../../../utils/new/locator.dart';
import '../../../utils/new/utils.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import '../../chat_view/broup_messaging/broup_messaging.dart';


class BroTile extends StatefulWidget {
  final Broup chat;

  BroTile({required Key key, required this.chat}) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {
  final NavigationService _navigationService = locator<NavigationService>();
  var _tapPosition;

  selectBro(BuildContext context) {
    if (widget.chat.isPrivate()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BroMessaging(
                  key: UniqueKey(),
                  chat: widget.chat
              )
          ),
          // ModalRoute.withName(routes.ChatRoute)
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BroupMessaging(
                key: UniqueKey(),
                chat: widget.chat
            )
        ),
        // ModalRoute.withName(routes.ChatRoute)
      );
    }
  }

  Color getColorStrength() {
    if (widget.chat.unreadMessages == 0) {
      return widget.chat.getColor().withOpacity(0.6);
    }
    if (widget.chat.unreadMessages == 1) {
      return widget.chat.getColor().withOpacity(0.7);
    }
    if (widget.chat.unreadMessages == 2) {
      return widget.chat.getColor().withOpacity(0.8);
    }
    if (widget.chat.unreadMessages == 3) {
      return widget.chat.getColor().withOpacity(0.9);
    }
    return widget.chat.getColor().withOpacity(1);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onLongPress: _showChatDetailPopupMenu,
          onTapDown: _storePosition,
          onTap: () {
            selectBro(context);
          },
          child: Container(
              color: widget.chat.unreadMessages < 4
                  ? widget.chat.unreadMessages < 3
                  ? widget.chat.unreadMessages < 2
                  ? widget.chat.unreadMessages < 1
                  ? widget.chat.getColor().withOpacity(0.6)
                  : widget.chat.getColor().withOpacity(0.7)
                  : widget.chat.getColor().withOpacity(0.8)
                  : widget.chat.getColor().withOpacity(0.9)
                  : widget.chat.getColor().withOpacity(1),
              padding: EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      widget.chat.isMuted() ||
                          widget.chat.isBlocked() ||
                          widget.chat.hasLeft()
                          ? Container(
                          width: 35,
                          child: Column(children: [
                            widget.chat.isBlocked() || widget.chat.hasLeft()
                                ? Icon(
                                widget.chat.hasLeft()
                                    ? Icons.person_remove
                                    : Icons
                                    .block, // Block or left can't both be true
                                color:
                                getTextColor(widget.chat.getColor())
                                    .withOpacity(0.6))
                                : Container(
                              height: 20,
                            ),
                            widget.chat.isMuted()
                                ? Icon(Icons.volume_off,
                                color:
                                getTextColor(widget.chat.getColor())
                                    .withOpacity(0.6))
                                : Container(
                              height: 20,
                            ),
                          ]))
                          : SizedBox(width: 35),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // All the padding and sizedboxes (and message bal) added up it's 103.
                              // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                              width: MediaQuery.of(context).size.width - 110,
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
                              MediaQuery.of(context).size.width - 110,
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
                              MediaQuery.of(context).size.width - 110,
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
        if (!widget.chat.isPrivate()) {
          _navigationService.navigateTo(routes.BroupRoute,
              arguments: widget.chat);
        } else {
          _navigationService.navigateTo(routes.BroHomeRoute,
              arguments: widget.chat);
        }
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
