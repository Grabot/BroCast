import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/search.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

import 'add_broup.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';


class FindBros extends StatefulWidget {
  FindBros(
      {
        required Key key
      }) : super(key: key);

  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {
  Search search = new Search();
  Settings settings = Settings();
  BroList broList = BroList();
  SocketServices socketServices = SocketServices();

  bool isSearching = false;
  bool showNotification = true;
  List<Bro> brosToBeAdded = [];

  bool showEmojiKeyboard = false;
  bool clickedNewBro = false;

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  Storage storage = Storage();

  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);
    socketServices.checkConnection();
    BackButtonInterceptor.add(myInterceptor);
    initFindBrosSockets();
  }

  void initFindBrosSockets() {
    // The "message_event_bro_added_you" socket is handled in the background.
    // The "message_event_add_bro_success" should be handled in this screen.
    socketServices.socket.on('message_event_add_bro_success', (data) =>
        youAddedABro(data));
    socketServices.socket.on('message_event_add_bro_failed', (data) =>
        broAddingFailed());
  }

  bromotionListener() {
    bromotionController.selection =
        TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionController.text.replaceFirst(lastEmoji, "");
      bromotionController.text = newText;
    }
  }

  youAddedABro(data) {
    BroBros broBros = new BroBros(
        data["bros_bro_id"],
        data["chat_name"],
        data["chat_description"],
        data["alias"],
        data["chat_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        data["blocked"] ? 1 : 0,
        data["mute"] ? 1 : 0,
        0
    );
    broList.addBro(broBros);
    storage.addChat(broBros).then((value) {
      clickedNewBro = false;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome(
          key: UniqueKey()
      )));
    });
  }

  broAddingFailed() {
    clickedNewBro = false;
    ShowToastComponent.showDialog(
        "Bro could not be added at this time", context);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    bromotionController.removeListener(bromotionListener);
    socketServices.socket.off('message_event_add_bro_success');
    socketServices.socket.off('message_event_add_bro_failed');
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void addBroup() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AddBroup(key: UniqueKey())));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  void onTapEmojiField() {
    if (!showEmojiKeyboard) {
      // We add a quick delay, this is to ensure that the keyboard is gone at this point.
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  searchBros() {
    if (formFieldKey.currentState!.validate()) {
      setState(() {
        isSearching = true;
      });

      String broNameSearch = broNameController.text.trimRight();
      String bromotionSearch = bromotionController.text;

      search.searchBro(settings.getToken(), broNameSearch, bromotionSearch).then((val) {
        if (!(val is String)) {
          setState(() {
            brosToBeAdded = val;
          });
        } else {
          ShowToastComponent.showDialog(val.toString(), context);
        }
        setState(() {
          isSearching = false;
        });
      });
    }
  }

  Widget listOfBros() {
    return brosToBeAdded.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: brosToBeAdded.length,
            itemBuilder: (context, index) {
              return BroTileSearch(
                  brosToBeAdded[index],
                  settings.getToken(),
                  addNewBro
              );
            })
        : Container();
  }

  addNewBro(int addBroId) {
    if (!clickedNewBro) {
      clickedNewBro = true;
      socketServices.socket.emit("message_event_add_bro",
          {"token": settings.getToken(), "bros_bro_id": addBroId}
      );
    }
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BroCastHome(
        key: UniqueKey()
      )));
    }
  }

  PreferredSize appBarFindBros(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft, child: Text("Add new bros")),
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
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile(
            key: UniqueKey()
        )));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings(
            key: UniqueKey()
        )));
        break;
      case 2:
        ResetRegistration resetRegistration = new ResetRegistration();
        resetRegistration.removeRegistrationId(settings.getBroId());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFindBros(context),
      body: Container(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                addBroup();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                height: 80,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(40))
                      ),
                      child: IconButton(
                        onPressed: () {
                          addBroup();
                        },
                        icon: Icon(
                            Icons.group_add,
                            color: Colors.white
                        ),
                      )
                    ),
                    SizedBox(width: 20),
                    Text(
                        "Add new Broup",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                    )
                  ]
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: Text(
                  "Or search for a bro using their bro name \n(bromotion optional)",
                  style: simpleTextStyle()
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      key: formFieldKey,
                      onTap: () {
                        onTapTextField();
                      },
                      validator: (val) {
                        return val == null || val.isEmpty ? "Please provide a bro name" : null;
                      },
                      controller: broNameController,
                      textAlign: TextAlign.center,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("Bro name"),
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      onTap: () {
                        onTapEmojiField();
                      },
                      controller: bromotionController,
                      style: simpleTextStyle(),
                      textAlign: TextAlign.center,
                      decoration: textFieldInputDecoration("😀"),
                      readOnly: true,
                      showCursor: true,
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      searchBros();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: const Color(0x36FFFFFF),
                            borderRadius: BorderRadius.circular(40)),
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.search)),
                  )
                ],
              ),
            ),
            Expanded(child: listOfBros()),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  bromotionController: bromotionController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode()),
            ),
          ],
        ),
      ),
    );
  }
}

class BroTileSearch extends StatelessWidget {
  final Bro bro;
  final String token;
  final void Function(int) addNewBro;

  BroTileSearch(
      this.bro,
      this.token,
      this.addNewBro
    );

  addBro() {
    addNewBro(bro.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width - 110,
              child: Text(
                  bro.getFullName(),
                  overflow: TextOverflow.ellipsis,
                  style: simpleTextStyle()
              )
          ),
          Spacer(),
          Container(
            width: 62,
            child: GestureDetector(
              onTap: () {
                addBro();
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Add")),
            ),
          )
        ],
      ),
    );
  }
}
