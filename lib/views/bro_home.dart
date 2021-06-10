import 'dart:io';

import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:brocast/views/find_bros.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bro_profile.dart';
import 'bro_settings.dart';

class BroCastHome extends StatefulWidget {
  BroCastHome({Key key}) : super(key: key);

  @override
  _BroCastHomeState createState() => _BroCastHomeState();
}

class _BroCastHomeState extends State<BroCastHome> with WidgetsBindingObserver {
  GetBros getBros = new GetBros();
  Auth auth = new Auth();

  bool isSearching = false;
  List<BroBros> bros = [];

  bool showNotification = true;

  Widget broList() {
    return bros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: bros.length,
            itemBuilder: (context, index) {
              return BroTile(broBros: bros[index]);
            })
        : Container();
  }

  searchBros(String token) {
    setState(() {
      isSearching = true;
    });

    getBros.getBros(token).then((val) {
      if (!(val is String)) {
        setState(() {
          bros = val;
          BroList.instance.setBros(bros);
        });
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
      setState(() {
        isSearching = false;
      });
    });
  }

  void broAddedYou() {
    if (mounted) {
      setState(() {
        searchBros(Settings.instance.getToken());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    joinRoomSolo(Settings.instance.getBroId());
    NotificationService.instance.setScreen(this);

    // This is called after the build is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BroBros chatBro = NotificationService.instance.getGoToBro();
      if (chatBro != null) {
        NotificationService.instance.resetGoToBro();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroMessaging(broBros: chatBro)));
      } else {
        searchBros(Settings.instance.getToken());
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  joinRoomSolo(int broId) {
    if (SocketServices.instance.socket.connected) {
      SocketServices.instance.socket.on('message_event_send_solo', (data) => messageReceivedSolo(data));
      SocketServices.instance.socket.on('message_event_bro_added_you', (data) {
        broAddedYou();
      });
      SocketServices.instance.socket.emit(
        "join_solo",
        {
          "bro_id": broId,
        },
      );
    }
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      updateMessages(data["sender_id"]);

      for (BroBros br0 in BroList.instance.getBros()) {
        if (br0.id == data["sender_id"]) {
          if (showNotification) {
            NotificationService.instance
                .showNotification(br0.id, br0.chatName, "", data["body"]);
          }
        }
      }
    }
  }

  updateMessages(int senderId) {
    if (mounted) {
      for (BroBros br0 in bros) {
        if (senderId == br0.id) {
          br0.unreadMessages += 1;
          br0.lastActivity = DateTime.now();
        }
      }

      setState(() {
        bros.sort((b, a) => a.lastActivity.compareTo(b.lastActivity));
      });
    }
  }


  leaveRoomSolo() {
    if (mounted) {
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket.off('message_event_send_solo', (data) => print(data));
        SocketServices.instance.socket.emit(
          "leave_solo",
          {"bro_id": Settings.instance.getBroId()},
        );
      }
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  void goToDifferentChat(BroBros chatBro) {
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroMessaging(broBros: chatBro)));
    }
  }

  Widget appBarHome(BuildContext context) {
    return AppBar(
      title: Container(alignment: Alignment.centerLeft, child: Text("Brocast")),
      actions: [
      PopupMenuButton<int>(
          onSelected: (item) => onSelect(context, item),
          itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text("Profile")),
            PopupMenuItem<int>(value: 1, child: Text("Settings")),
            PopupMenuItem<int>(value: 2, child: Text("Exit Brocast")),
            PopupMenuItem<int>(
                value: 3,
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Log Out")
                ]))
          ])
      ]
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings()));
        break;
      case 2:
        leaveRoomSolo();
        SocketServices.instance.closeSockConnection();
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
        break;
      case 3:
        HelperFunction.logOutBro().then((value) {
          leaveRoomSolo();
          ResetRegistration resetRegistration = new ResetRegistration();
          resetRegistration.removeRegistrationId(Settings.instance.getBroId());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        });
        break;
    }
  }

  DateTime lastPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarHome(context),
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final maxDuration = Duration(seconds: 2);
          final isWarning = lastPressed == null ||
              now.difference(lastPressed) > maxDuration;

          if (isWarning) {
            lastPressed = DateTime.now();

            final snackBar = SnackBar(
              content: Text('Press back twice to exit the application'),
              duration: maxDuration,
            );

            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snackBar);

            return false;
          } else {
            leaveRoomSolo();
            SocketServices.instance.closeSockConnection();
            return true;
          }
        },
        child: Container(
            child: Column(children: [
          Container(
            child: Expanded(child: broList()),
          ),
        ])),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FindBros()));
        },
      ),
    );
  }
}

class BroTile extends StatefulWidget {
  final BroBros broBros;

  BroTile({Key key, this.broBros}) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {
  selectBro(BuildContext context) {
    NotificationService.instance.dismissAllNotifications();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BroMessaging(broBros: widget.broBros)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: () {
            selectBro(context);
          },
          child: Container(
              color: widget.broBros.unreadMessages < 5
                  ? widget.broBros.unreadMessages < 4
                      ? widget.broBros.unreadMessages < 3
                          ? widget.broBros.unreadMessages < 2
                              ? widget.broBros.unreadMessages < 1
                                  ? widget.broBros.broColor.withOpacity(0.3)
                                  : widget.broBros.broColor.withOpacity(0.4)
                              : widget.broBros.broColor.withOpacity(0.5)
                          : widget.broBros.broColor.withOpacity(0.6)
                      : widget.broBros.broColor.withOpacity(0.7)
                  : widget.broBros.broColor.withOpacity(0.8),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 15),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // All the padding and sizedboxes (and message bal) added up it's 103.
                              // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                              width: MediaQuery.of(context).size.width - 110,
                              child: Text(widget.broBros.chatName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                            widget.broBros.chatDescription != ""
                                ? Container(
                                    // All the padding and sizedboxes (and message bal) added up it's 103.
                                    // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                                    width:
                                        MediaQuery.of(context).size.width - 110,
                                    child: Text(widget.broBros.chatDescription,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
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
                          color: widget.broBros.broColor,
                          borderRadius: BorderRadius.circular(40)),
                      child: Text(
                        widget.broBros.unreadMessages.toString(),
                        style: TextStyle(
                            color: getTextColor(widget.broBros.broColor),
                            fontSize: 16),
                      )),
                ],
              )),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
