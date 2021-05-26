import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/add_bro.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/search.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:flutter/material.dart';

class FindBros extends StatefulWidget {

  FindBros({ Key key }): super(key: key);

  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {

  Search search = new Search();

  bool isSearching = false;
  List<Bro> bros = [];

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroCastHome()
    ));
    return true;
  }

  void goToDifferentChat(Bro chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(bro: chatBro)
    ));
  }

  searchBros() {
      setState(() {
        isSearching = true;
      });

      // TODO: @SKools bromotion functionality
      search.searchBro(broNameController.text, "").then((val) {
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

  Widget broList() {
    return bros.isNotEmpty ?
      ListView.builder(
      shrinkWrap: true,
      itemCount: bros.length,
        itemBuilder: (context, index) {
          return BroTileSearch(
              bros[index]
          );
        }) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, true),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: broNameController,
                        style: TextStyle(
                            color: Colors.white
                        ),
                        decoration: InputDecoration(
                          hintText: "Search Bros...",
                          hintStyle: TextStyle(
                            color: Colors.white54
                          ),
                          border: InputBorder.none
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      searchBros();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                       gradient: LinearGradient(
                        colors: [
                            const Color(0x36FFFFFF),
                            const Color(0x0FFFFFFF)
                          ]
                        ),
                        borderRadius: BorderRadius.circular(40)
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search)
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: broList()
            )
          ],
        )
      )
    );
  }
}

class BroTileSearch extends StatelessWidget {
  final Bro bro;

  BroTileSearch(this.bro);

  final AddBro add = new AddBro();

  addBro(BuildContext context) {
    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        print("no token found, this should not happen");
      } else {
        add.addBro(val.toString(), bro.id);

        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroMessaging(bro: bro)
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(bro.getFullBroName(), style: simpleTextStyle()),
          Spacer(),
          GestureDetector(
            onTap: () {
              addBro(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30)
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Add")
            ),
          )
        ],
      ),
    );
  }
}
