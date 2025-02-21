import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:flutter/material.dart';

import '../../../../objects/bro.dart';
import '../../../../objects/broup.dart';
import '../../../../objects/me.dart';
import '../../../../utils/settings.dart';
import '../../../../utils/utils.dart';
import '../../chat_messaging.dart';
import '../../messaging_change_notifier.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

class BroTileDetails extends StatefulWidget {
  final Bro bro;
  final bool broAdmin;
  final bool broAdded;
  final int broupId;
  final bool userAdmin;
  final void Function(int, int) broHandling;

  BroTileDetails(
      {required Key key,
        required this.bro,
        required this.broAdmin,
        required this.broAdded,
        required this.broupId,
        required this.userAdmin,
        required this.broHandling})
      : super(key: key);

  @override
  _BroTileDetailsState createState() => _BroTileDetailsState();
}

class _BroTileDetailsState extends State<BroTileDetails> {
  Settings settings = Settings();

  var _tapPosition;

  selectBro(BuildContext context) {
    if (widget.bro.id != settings.getMe()!.getId()) {
      if (widget.userAdmin) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(actions: <Widget>[
                getPopupItemsAdmin(
                    context,
                    widget.bro,
                    widget.broupId,
                    true,
                    widget.broAdded,
                    widget.broAdmin,
                    widget.broHandling)
              ]);
            });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(actions: <Widget>[
                getPopupItemsNormal(
                    context,
                    widget.bro,
                    widget.broupId,
                    true,
                    widget.broAdded,
                    widget.broAdmin,
                    widget.broHandling)
              ]);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: GestureDetector(
          onLongPress: _showBroupPopupMenu,
          onTapDown: _storePosition,
          child: InkWell(
            onTap: () {
              selectBro(context);
            },
            child: Row(children: [
              Container(
                width: widget.broAdmin
                    ? MediaQuery.of(context).size.width - 124
                    : MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(widget.bro.getFullName(), style: simpleTextStyle()),
              ),
              widget.broAdmin
                  ? Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green)),
                      child: Text(
                        "admin",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                        textAlign: TextAlign.center,
                      ))
                  : Container(),
            ]),
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }

  void _showBroupPopupMenu() {
    if (widget.bro.id != settings.getMe()!.getId()) {
      final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

      showMenu(
          context: context,
          items: [
            BroupParticipantPopup(
                key: UniqueKey(),
                broName: widget.bro.getFullName(),
                bro: widget.bro,
                broupId: widget.broupId,
                userAdmin: widget.userAdmin,
                broAdded: widget.broAdded,
                broAdmin: widget.broAdmin,
                broHandling: widget.broHandling)
          ],
          position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
              Offset.zero & overlay.size))
          .then((int? delta) {
        return;
      });
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}

class BroupParticipantPopup extends PopupMenuEntry<int> {
  final String broName;
  final Bro bro;
  final int broupId;
  final bool userAdmin;
  final bool broAdded;
  final bool broAdmin;
  final void Function(int, int) broHandling;

  BroupParticipantPopup(
      {required Key key,
        required this.broName,
        required this.bro,
        required this.broupId,
        required this.userAdmin,
        required this.broAdded,
        required this.broAdmin,
        required this.broHandling})
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  BroupParticipantPopupState createState() => BroupParticipantPopupState();

  @override
  double get height => 1;
}

class BroupParticipantPopupState extends State<BroupParticipantPopup> {
  Settings settings = Settings();

  @override
  Widget build(BuildContext context) {
    return widget.userAdmin
        ? getPopupItemsAdmin(context, widget.bro, widget.broupId, false, widget.broAdded, widget.broAdmin, widget.broHandling)
        : getPopupItemsNormal(context, widget.bro, widget.broupId, false, widget.broAdded, widget.broAdmin, widget.broHandling);
  }
}

void buttonMessage(BuildContext context, Bro bro, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
  Settings settings = Settings();
  Me? me = settings.getMe();
  if (me != null) {
    for (Broup broup in me.broups) {
      if (broup.private) {
        for (int broId in broup.broIds) {
          if (broId != me.getId()) {
            if (broId == bro.id) {
              navigateToChat(context, settings, broup);
              return;
            }
          }
        }
      }
    }
  }
}

void buttonAddBro(
    BuildContext context, Bro bro, bool alertDialog, broHandling) {
  print("button add bro ");
  broHandling(1, bro.id);
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
}

void buttonMakeAdmin(BuildContext context, Bro bro, int broupId,
    bool alertDialog, broHandling) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 2);
  }
  broHandling(2, bro.id);
}

void buttonDismissAdmin(BuildContext context, Bro bro, int broupId,
    bool alertDialog, broHandling) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  broHandling(3, bro.id);
}

void buttonRemove(BuildContext context, Bro bro, int broupId, bool alertDialog, broHandling) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  broHandling(4, bro.id);
}

Widget getPopupItemsAdmin(BuildContext context, Bro bro,
    int broupId, bool alertDialog, bool broAdded, bool broAdmin, broHandling) {
  return Column(
    children: [
      SizedBox(height: 20),
      Text(
          "Bro Options",
          style: TextStyle(color: Colors.black, fontSize: 16)
      ),
      SizedBox(height: 10),
      broAdded
          ? Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      buttonMessage(context, bro, alertDialog);
                    },
                    child: Text(
                      'Message ${bro.getFullName()}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    )),
              ),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      buttonAddBro(context, bro, alertDialog, broHandling);
                    },
                    child: Text(
                      'Add ${bro.getFullName()}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    )),
              ),
            ),
      broAdmin
          ? Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      buttonDismissAdmin(
                          context, bro, broupId, alertDialog, broHandling);
                    },
                    child: Text(
                      'Dismiss ${bro.getFullName()} from admins',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    )),
              ),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      buttonMakeAdmin(context, bro, broupId, alertDialog, broHandling);
                    },
                    child: Text(
                      'Make ${bro.getFullName()} admin',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    )),
              ),
            ),
      Container(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: double.infinity,
          child: TextButton(
              onPressed: () {
                buttonRemove(context, bro, broupId, alertDialog, broHandling);
              },
              child: Text(
                'Remove ${bro.getFullName()}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 14),
              )),
        ),
      )
    ],
  );
}

Widget getPopupItemsNormal(BuildContext context, Bro bro,
    int broupId, bool alertDialog, bool broAdded, bool broAdmin, broHandling) {
  return Column(
    children: [
      SizedBox(height: 20),
      Text(
          "Bro Options",
          style: TextStyle(color: Colors.black, fontSize: 16)
      ),
      SizedBox(height: 10),
      broAdded ?
          Container(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  buttonMessage(context, bro, alertDialog);
                },
                child: Text(
                  'Message ${bro.getFullName()}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          )
          : Container(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      buttonAddBro(context, bro, alertDialog, broHandling);
                    },
                    child: Text(
                      'Add ${bro.getFullName()}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    )),
              ),
            ),
    ],
  );
}
