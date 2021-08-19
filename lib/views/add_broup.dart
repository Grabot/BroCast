import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'bro_profile.dart';
import 'bro_settings.dart';

class AddBroup extends StatefulWidget {
  AddBroup({Key key}) : super(key: key);

  @override
  _AddBroupState createState() => _AddBroupState();
}

class _AddBroupState extends State<AddBroup> with WidgetsBindingObserver {

  GetBros getBros = new GetBros();

  List<BroBros> bros = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<BroBros> brobros = BroList.instance.getBros();
      if (brobros.isEmpty) {
        searchBros(Settings.instance.getToken());
      } else {
        setState(() {
          bros = brobros;
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  searchBros(String token) {
    getBros.getBros(token).then((val) {
      if (!(val is String)) {
        setState(() {
          bros = val;
          BroList.instance.setBros(bros);
        });
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  Widget appBarFindBros(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              backButtonFunctionality();
            }),
        title: Container(
            alignment: Alignment.centerLeft, child: Text("Create Broup")),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelect(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Profile")),
                    PopupMenuItem<int>(value: 1, child: Text("Settings")),
                    PopupMenuItem<int>(
                        value: 2,
                        child: Row(children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 8),
                          Text("Log Out")
                        ]))
                  ])
        ]);
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => BroCastHome()));
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
        HelperFunction.logOutBro().then((value) {
          ResetRegistration resetRegistration = new ResetRegistration();
          resetRegistration.removeRegistrationId(Settings.instance.getBroId());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        });
        break;
    }
  }

  Widget broList() {
    return bros.isNotEmpty
        ? ListView.builder(
        shrinkWrap: true,
        itemCount: bros.length,
        itemBuilder: (context, index) {
          return BroTileAddBroup(broBros: bros[index]);
        })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFindBros(context),
      body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "bros",
                  style: simpleTextStyle()
                ),
              ),
              Container(
                  height: 40
              ),
              SizedBox(
                height: 10
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children:
                  [
                    Container(
                      width: MediaQuery.of(context).size.width-100,
                      child: TextFormField(
                        onTap: () {
                          print("text form field");
                        },
                        validator: (val) {
                          return val.isEmpty
                              ? "Please provide a Broup name"
                              : null;
                        },
                        textAlign: TextAlign.center,
                        style: simpleTextStyle(),
                        decoration:
                        textFieldInputDecoration("Type Broup name here"),
                      ),
                    ),
                    SizedBox(width: 15),
                    Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(40))
                        ),
                        child: IconButton(
                          onPressed: () {
                            print("pressed the check");
                          },
                          icon: Icon(
                              Icons.check,
                              color: Colors.white
                          ),
                        )
                    ),
                    SizedBox(width: 15),
                  ]
                ),
              ),
              SizedBox(
                  height: 10
              ),
              broList(),
            ],
          )
      ),
    );
  }
}

class BroTileAddBroup extends StatefulWidget {
  final BroBros broBros;

  BroTileAddBroup({Key key, this.broBros}) : super(key: key);

  @override
  _BroTileAddBroupState createState() => _BroTileAddBroupState();
}

class _BroTileAddBroupState extends State<BroTileAddBroup> {

  void selectBro(BuildContext context) {
    print("bro selected");
  }

  bool checkedValue = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        selectBro(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: widget.broBros.broColor.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              width: 50,
            ),
            Container(
              width: MediaQuery.of(context).size.width-50,
              child: Material(
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width - 160,
                                      child: Text(widget.broBros.chatName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 20)),
                                    ),
                                    widget.broBros.chatDescription != ""
                                        ? Container(
                                      width:
                                      MediaQuery.of(context).size.width - 160,
                                      child: Text(widget.broBros.chatDescription,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 12)),
                                    )
                                        : Container(),
                                  ],
                                ),
                          ),
                        ],
                      )
                  ),
                color: Colors.transparent,
              ),
            ),
          ]
        ),
      ),
    );
  }
}
