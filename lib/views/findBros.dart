import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/search.dart';
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';

class FindBros extends StatefulWidget {
  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {

  Search search = new Search();

  bool isSearching = false;
  List<Bro> bros = [];

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  searchBros() {
      setState(() {
        isSearching = true;
      });

      search.searchBro(broNameController.text, "").then((val) {
        print("$val");
        if (!(val is String)) {
          print("it was successful");
          setState(() {
            bros = val;
            print(bros);
            for (Bro bro in bros) {
              print(bro.getFullBroName());
            }
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
          return BroTile(
              bros[index]
          );
        }) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
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

class BroTile extends StatelessWidget {
  final Bro bro;

  BroTile(this.bro);

  addBro() {
    // TODO: @Skools add bro
    print("adding bro: " + bro.getFullBroName());
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
              addBro();
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
