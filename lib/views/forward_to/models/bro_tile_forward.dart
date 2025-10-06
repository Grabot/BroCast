import 'dart:io';
import 'dart:typed_data';

import 'package:brocast/objects/data_type.dart';
import 'package:brocast/utils/share_with_service.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:image/image.dart' as img;
import '../../../objects/broup.dart';
import '../../../objects/message.dart';
import '../../../services/auth/v1_4/auth_service_social.dart';
import '../../../utils/settings.dart';
import '../../../utils/storage.dart';
import '../../../utils/utils.dart';
import '../../chat_view/preview_page_chat/preview_page_chat.dart';
import '../../chat_view/preview_page_text_chat/preview_page_text_chat.dart';


class BroTileForward extends StatefulWidget {
  final Broup chat;
  final Message forwardMessage;
  final void Function() callback;

  BroTileForward({required Key key, required this.chat, required this.forwardMessage, required this.callback}) : super(key: key);

  @override
  _BroTileForwardState createState() => _BroTileForwardState();
}

class _BroTileForwardState extends State<BroTileForward> {
  var _tapPosition;

  selectBro(BuildContext context) {
    shareWithBroup(context, widget.chat, widget.forwardMessage);
  }

  shareWithBroup(BuildContext context, Broup broupShare, Message forwardMessage) async {

    if (forwardMessage.dataType != null && forwardMessage.dataType != "") {
      File mediaFile = File(forwardMessage.data!);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PreviewPageChat(
                  key: UniqueKey(),
                  fromGallery: true,
                  chat: broupShare,
                  mediaFile: mediaFile,
                  dataType: forwardMessage.dataType!,
                  messageBodyForward: forwardMessage.body,
                  textMessageForward: forwardMessage.textMessage
              ),
        ),
      );
      return;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PreviewPageTextChat(
                  key: UniqueKey(),
                  chat: broupShare,
                  shareText: forwardMessage.textMessage,
                  shareTextBody: forwardMessage.body,
                  url: false
              ),
        ),
      );
      return;
    }
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
                                      color: getTextColor(widget.chat.getColor()), fontSize: 20)),
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

  showDialogUnMuteChat(BuildContext context) {
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
                  muteTheChat(-1);
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

  muteTheChat(int muteValue) {
    AuthServiceSocial().muteBroup(widget.chat.broupId, muteValue).then((value) {
      if (value) {
        setState(() {
          widget.chat.setMuted(muteValue >= 0);
        });
        // 0 is 1 hour 1 is 8 hours 2 is 1 week 3 is indefinitely
        DateTime now = DateTime.now().toUtc();
        if (muteValue == 0) {
          widget.chat.setMuteValue(now.add(Duration(hours: 1)).toString());
          widget.chat.checkMute();
        } else if (muteValue == 1) {
          widget.chat.setMuteValue(now.add(Duration(hours: 8)).toString());
          widget.chat.checkMute();
        } else if (muteValue == 2) {
          widget.chat.setMuteValue(now.add(Duration(days: 7)).toString());
          widget.chat.checkMute();
        }
        Storage().fetchBroup(widget.chat.broupId).then((dbBroup) {
          if (dbBroup != null) {
            dbBroup.mute = widget.chat.mute;
            dbBroup.muteValue = widget.chat.muteValue;
            Storage().updateBroup(dbBroup).then((value) {
              BroHomeChangeNotifier().notify();
            });
          }
        });
      } else {
        showToastMessage("Broup muting failed at this time.");
      }
    });
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
  return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                buttonMessage(context);
              },
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: Size(double.infinity, 0), // Make the button take full width
              ),
              child: Text(
                'Message ${chat.getBroupNameOrAlias()}',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 14),
              )
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () {
                chat.isMuted() ? buttonUnmute(context) : buttonMute(context);
              },
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: Size(double.infinity, 0), // Make the button take full width
              ),
              child: Text(
                chat.isMuted() ? 'Unmute chat' : 'Mute chat',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.black, fontSize: 14),
              )
          ),
        ),
      ]
  );
}
