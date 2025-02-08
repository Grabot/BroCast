import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/add_broup.dart';
import 'package:brocast/views/find_bros/find_bros.dart';
import 'package:brocast/views/sign_in/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../utils/new/secure_storage.dart';
import '../../utils/new/storage.dart';
import '../bro_profile.dart';
import '../bro_settings.dart';
import 'bro_home_change_notifier.dart';
import 'models/bro_tile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

class BroCastHome extends StatefulWidget {
  BroCastHome({required Key key}) : super(key: key);

  @override
  _BroCastHomeState createState() => _BroCastHomeState();
}

class _BroCastHomeState extends State<BroCastHome> {

  bool showEmojiKeyboard = false;
  bool searchMode = false;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  late SocketServices socketServices;
  late Settings settings;
  // late Storage storage;

  late BroHomeChangeNotifier broHomeChangeNotifier;

  List<Broup> bros = [];
  List<Broup> shownBros = [];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    socketServices = SocketServices();
    settings = Settings();
    // storage = Storage();

    broHomeChangeNotifier = BroHomeChangeNotifier();
    broHomeChangeNotifier.addListener(broHomeChangeListener);
    socketServices.addListener(broHomeChangeListener);
    // Wait until page is loaded and then call the broHomeChangeListener
    SchedulerBinding.instance.addPostFrameCallback((_) {
      settings.doneRoutes.add(routes.BroHomeRoute);
      broHomeChangeListener();
    });
  }

  broHomeChangeListener() {
    print("listen to home");
    if (mounted) {
      Me? me = settings.getMe();
      if (me != null) {
        bros = me.bros;
        if (!searchMode) {
          // Set all bros to be shown, except when the bro is searching.
          shownBros = bros;
        }
        // Join Broups if not already joined.
        for (Broup broup in bros) {
          if (!broup.joinedBroupRoom) {
            socketServices.joinRoomBroup(broup.getBroupId());
            broup.joinedBroupRoom = true;
          }
        }
      }
      setState(() {});
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

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onChangedBroNameField(String typedText, String emojiField) {
    if (emojiField.isEmpty && typedText.isNotEmpty) {
      shownBros = bros
          .where((element) => element
          .getBroupNameOrAlias().toLowerCase()
          .contains(typedText.toLowerCase()))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      shownBros = bros
          .where((element) =>
          element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
          .toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      shownBros = bros
          .where((element) =>
      element
          .getBroupNameOrAlias().toLowerCase()
          .contains(typedText.toLowerCase()) &&
          element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
          .toList();
    } else {
      // both empty
      shownBros = bros;
    }
    setState(() {});
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
    onChangedBroNameField(broNameController.text, bromotionController.text);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return backButtonFunctionality();
  }

  bool backButtonFunctionality() {
    if (mounted) {
      if (searchMode) {
        setState(() {
          searchMode = false;
        });
      } else {
        exitApp();
      }
      return true;
    }
    return false;
  }

  exitApp() {
    Me? me = settings.getMe();
    if (me != null) {
      socketServices.leaveRoomSolo(me.getId());
      for (Broup broup in me.bros) {
        if (broup.joinedBroupRoom) {
          socketServices.leaveRoomBroup(broup.getBroupId());
          broup.joinedBroupRoom = false;
        }
      }
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  PreferredSize appBarHome(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: searchMode
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    backButtonFunctionality();
                  })
              : Container(),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Brocast",
                style: TextStyle(color: Colors.white),
              )),
          actions: [
            searchMode
                ? IconButton(
                    icon: Icon(Icons.search_off, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        searchMode = false;
                      });
                    })
                : IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        searchMode = true;
                      });
                    }),
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(
                          value: 2, child: Text("Find a new Bro")),
                      PopupMenuItem<int>(
                          value: 3, child: Text("Add new Broup")),
                      PopupMenuItem<int>(value: 4, child: Text("Exit Brocast")),
                      PopupMenuItem<int>(
                          value: 5,
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
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => FindBros(key: UniqueKey())));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AddBroup(key: UniqueKey())));
        break;
      case 4:
        exitApp();
        break;
      case 5:
        Me? me = settings.getMe();
        if (me != null) {
          socketServices.leaveRoomSolo(me.getId());
        }
        settings.logout();
        SecureStorage().logout();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SignIn(
              key: UniqueKey(),
              showRegister: false
            )));
        break;
    }
  }

  Widget listOfBros() {
    return shownBros.isNotEmpty
        ? ListView.builder(
        shrinkWrap: true,
        itemCount: shownBros.length,
        itemBuilder: (context, index) {
          return BroTile(key: UniqueKey(), chat: shownBros[index]);
        })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    String broName = "";
    String bromotion = "";
    Me? me = settings.getMe();
    if (me != null) {
      broName = me.getBroName();
      bromotion = me.getBromotion();
    }
    return Scaffold(
      appBar: appBarHome(context),
      body: Container(
          child: Stack(
              children: [
                Column(
                    children: [
                      Container(
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BroProfile(key: UniqueKey())));
                            },
                            child: Container(
                                color: Color(0x8b2d69a3),
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                alignment: Alignment.center,
                                child: Text(
                                  "Hey $broName $bromotion!",
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                )),
                          ),
                          color: Colors.transparent,
                        ),
                      ),
                      searchMode
                          ? Container(
                        child: Row(children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              onTap: () {
                                onTapTextField();
                              },
                              onChanged: (text) {
                                onChangedBroNameField(text, bromotionController.text);
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
                        ]),
                      )
                          : Container(),
                      Container(
                        child: Expanded(child: listOfBros()),
                      ),
                    ]
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: EmojiKeyboard(
                      emojiController: bromotionController,
                      emojiKeyboardHeight: 300,
                      showEmojiKeyboard: showEmojiKeyboard,
                      darkMode: settings.getEmojiKeyboardDarkMode()),
                ),
              ]
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => FindBros(key: UniqueKey())));
        },
      ),
    );
  }
}

