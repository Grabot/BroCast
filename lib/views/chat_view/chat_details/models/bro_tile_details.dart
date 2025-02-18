import 'package:flutter/material.dart';

import '../../../../objects/bro.dart';
import '../../../../utils/new/settings.dart';
import '../../../../utils/new/utils.dart';

class BroTileDetails extends StatefulWidget {
  final Bro bro;
  final bool broAdmin;
  final bool broAdded;
  final int broupId;
  final bool userAdmin;
  final void Function(int) addNewBro;

  BroTileDetails(
      {required Key key,
        required this.bro,
        required this.broAdmin,
        required this.broAdded,
        required this.broupId,
        required this.userAdmin,
        required this.addNewBro})
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
                    widget.addNewBro)
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
                    widget.addNewBro)
              ]);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: admin check via admin ids for broup?
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
                addNewBro: widget.addNewBro)
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
  final void Function(int) addNewBro;

  BroupParticipantPopup(
      {required Key key,
        required this.broName,
        required this.bro,
        required this.broupId,
        required this.userAdmin,
        required this.broAdded,
        required this.broAdmin,
        required this.addNewBro})
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
        ? getPopupItemsAdmin(context, widget.bro, widget.broupId, false, widget.broAdded, widget.broAdmin, widget.addNewBro)
        : getPopupItemsNormal(context, widget.bro, widget.broupId, false, widget.broAdded, widget.broAdmin, widget.addNewBro);
  }
}

void buttonMessage(BuildContext context, Bro bro, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
  // BroList broList = BroList();
  // for (Chat br0 in broList.getBros()) {
  //   if (!br0.isBroup()) {
  //     if (br0.id == bro.id) {
  //       Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) =>
  //                   BroMessaging(key: UniqueKey(), chat: br0 as BroBros)));
  //     }
  //   }
  // }
}

void buttonAddBro(
    BuildContext context, Bro bro, bool alertDialog, addNewBro) {
  print("button add bro ");
  addNewBro(bro.id);
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 1);
  }
}

void buttonMakeAdmin(BuildContext context, Bro bro, int broupId,
    bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 2);
  }
  // SocketServices socketServices = SocketServices();
  // socketServices.socket.emit("message_event_change_broup_add_admin",
  //     {"token": token, "broup_id": broupId, "bro_id": bro.id});
}

void buttonDismissAdmin(BuildContext context, Bro bro, int broupId,
    bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  // SocketServices socketServices = SocketServices();
  // socketServices.socket.emit("message_event_change_broup_dismiss_admin",
  //     {"token": token, "broup_id": broupId, "bro_id": bro.id});
}

void buttonRemove(BuildContext context, Bro bro, int broupId, bool alertDialog) {
  if (alertDialog) {
    Navigator.of(context).pop();
  } else {
    Navigator.pop<int>(context, 3);
  }
  // SocketServices socketServices = SocketServices();
  // socketServices.socket.emit("message_event_change_broup_remove_bro",
  //     {"token": token, "broup_id": broupId, "bro_id": bro.id});
}

Widget getPopupItemsAdmin(BuildContext context, Bro bro,
    int broupId, bool alertDialog, bool broAdded, bool broAdmin, addNewBro) {
  return Column(
    children: [
      broAdded
          ? Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    buttonMessage(context, bro, alertDialog);
                  },
                  child: Text(
                    'Message ${bro.getFullName()}',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    buttonAddBro(context, bro, alertDialog, addNewBro);
                  },
                  child: Text(
                    'Add ${bro.getFullName()}',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            ),
      broAdmin
          ? Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    buttonDismissAdmin(
                        context, bro, broupId, alertDialog);
                  },
                  child: Text(
                    'Dismiss as admin',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    buttonMakeAdmin(context, bro, broupId, alertDialog);
                  },
                  child: Text(
                    'Make ${bro.getFullName()} admin',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonRemove(context, bro, broupId, alertDialog);
            },
            child: Text(
              'Remove ${bro.getFullName()}',
              style: TextStyle(color: Colors.black, fontSize: 14),
            )),
      )
    ],
  );
}

Widget getPopupItemsNormal(BuildContext context, Bro bro,
    int broupId, bool alertDialog, bool broAdded, bool broAdmin, addNewBro) {
  return Column(
    children: [
      broAdded ?
          Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    buttonMessage(context, bro, alertDialog);
                  },
                  child: Text(
                    'Message ${bro.getFullName()}',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            )
          : Container(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () {
                    // buttonAddBro(context, bro, alertDialog, token, addNewBro);
                  },
                  child: Text(
                    'Add ${bro.getFullName()}',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
            ),
    ],
  );
}
