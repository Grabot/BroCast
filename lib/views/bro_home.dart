import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:brocast/views/find_bros.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BroCastHome extends StatefulWidget {

  BroCastHome({ Key key }): super(key: key);

  @override
  _BroCastHomeState createState() => _BroCastHomeState();
}

class _BroCastHomeState extends State<BroCastHome> {

  GetBros getBros = new GetBros();
  Auth auth = new Auth();

  bool isSearching = false;
  List<BroBros> bros = [];

  Widget broList() {
    return bros.isNotEmpty ?
    ListView.builder(
        shrinkWrap: true,
        itemCount: bros.length,
        itemBuilder: (context, index) {
          return BroTile(
              broBros: bros[index]
          );
        }) : Container();
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
    setState(() {
      searchBros(Settings.instance.getToken());
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);
    SocketServices.instance.resetMessaging();

    // This is called after the build is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BroBros chatBro = NotificationService.instance.getGoToBro();
      if (chatBro != null) {
        NotificationService.instance.resetGoToBro();
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroMessaging(broBros: chatBro)
        ));
      } else {
        searchBros(Settings.instance.getToken());
        SocketServices.instance.setBroHome(this);
      }
    });
  }

  updateMessages(int senderId) {
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

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    SocketServices.instance.resetBroHome();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    SocketServices.instance.leaveRoomSolo(Settings.instance.getToken());
    SocketServices.instance.closeSockConnection();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  void goToDifferentChat(BroBros chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(broBros: chatBro)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, true, "Bro Cast"),
        body: Container(
            child: Column(
                children: [
                Container(
                  child: Expanded(
                            child: broList()
                        ),
                  ),
      ])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => FindBros()
          ));
        },
      ),
    );
  }
}

class BroTile extends StatefulWidget {

  final BroBros broBros;

  BroTile({
    Key key,
    this.broBros
  }): super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {

  selectBro(BuildContext context) {
    NotificationService.instance.dismissAllNotifications();
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(broBros: widget.broBros)
    ));
  }

  Color getTextColor(Color color) {
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // If the color is very bright we make the text colour black.
    // We set the limit high because we want it to be white mostly
    if (luminance > 0.80) {
      return Colors.black;
    } else {
      return Colors.white;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: (){
            selectBro(context);
          },
          child: Container(
              color:
              widget.broBros.unreadMessages < 5 ?
              widget.broBros.unreadMessages < 4 ?
              widget.broBros.unreadMessages < 3 ?
              widget.broBros.unreadMessages < 2 ?
              widget.broBros.unreadMessages < 1 ? widget.broBros.broColor.withOpacity(0.3)
                  : widget.broBros.broColor.withOpacity(0.4)
                  : widget.broBros.broColor.withOpacity(0.5)
                  : widget.broBros.broColor.withOpacity(0.6)
                  : widget.broBros.broColor.withOpacity(0.7)
                  : widget.broBros.broColor.withOpacity(0.8),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                      SizedBox(width: 15),
                      Text(
                          widget.broBros.chatName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                          )),
                    ],
                  ),
                  Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: widget.broBros.broColor,
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: Text(
                          widget.broBros.unreadMessages.toString(),
                          style: TextStyle(
                              color: getTextColor(widget.broBros.broColor),
                              fontSize: 16
                          ),
                      )
                  ),
                ],
              )
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
