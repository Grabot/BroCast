import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/getBros.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broMessaging.dart';
import 'package:brocast/views/findBros.dart';
import 'package:flutter/material.dart';

class BroCastHome extends StatefulWidget {
  @override
  _BroCastHomeState createState() => _BroCastHomeState();
}

class _BroCastHomeState extends State<BroCastHome> {

  GetBros getBros = new GetBros();
  Auth auth = new Auth();

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
      print("$val");
      if (!(val is String)) {
        print("it was successful");
        setState(() {
          bros = val;
          print(bros);
        });
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
      setState(() {
        isSearching = false;
      });
    });
  }


  @override
  void initState() {
    HelperFunction.getBroToken().then((val) {
      print("this is the token NOW!");
      print("$val");
      if (val == null) {
        print("no token yet, wait untill a token is saved");
      } else {
        searchBros(val.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
        body: Container(
            child: Column(
                children: [
                Container(
                  child: Row(
                      children: [
                        Expanded(
                            child: broList()
                        )
                      ]
                  ),
        ),
      ])),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
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
    print("clicked bro " + bro.getFullBroName());
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //     builder: (context) => BroMessaging()
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new Material(
          child: new InkWell(
            onTap: (){
              selectBro(context);
            },
            child: new Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Text(bro.getFullBroName(), style: simpleTextStyle()),
              ],
            ),
          ),
        ),
        color: Colors.transparent,
      )
    );
  }
}
