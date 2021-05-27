import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/shared.dart';
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

  String token;

  bool isSearching = false;
  List<Bro> bros = [];

  Widget broList() {
    return bros.isNotEmpty ?
    ListView.builder(
        shrinkWrap: true,
        itemCount: bros.length,
        itemBuilder: (context, index) {
          return BroTile(
              bros[index]
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
    if (token != null) {
      setState(() {
        searchBros(token);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);

    // This is called after the build is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Bro chatBro = NotificationService.instance.getGoToBro();
      if (chatBro != null) {
        NotificationService.instance.resetGoToBro();
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroMessaging(bro: chatBro)
        ));
      } else {
        HelperFunction.getBroToken().then((val) {
          if (val == null || val == "") {
            print("no token, should not be possible here!");
          } else {
            token = val.toString();
            searchBros(val.toString());
            SocketServices.instance.joinRoomSolo(token);
            SocketServices.instance.listenForBroHome(this);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    SocketServices.instance.leaveRoomSolo(token);
    SocketServices.instance.stopListeningForBroHome();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    SocketServices.instance.leaveRoomSolo(token);
    SocketServices.instance.closeSockConnection();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return true;
  }

  void goToDifferentChat(Bro chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(bro: chatBro)
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

class BroTile extends StatelessWidget {
  final Bro bro;

  BroTile(this.bro);

  selectBro(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(bro: bro)
    ));
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
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bro.broColor,
                      borderRadius: BorderRadius.circular(40)
                    ),
                    child: Text("${bro.bromotion}", style: simpleTextStyle())
                  ),
                  SizedBox(width: 8),
                  Text(bro.getFullBroName(), style: simpleTextStyle())
                ],
            )
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
