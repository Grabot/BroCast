import 'dart:io';

import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/add_broup/add_broup.dart';
import 'package:brocast/views/find_bros/find_bros.dart';
import 'package:brocast/views/sign_in/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../objects/bro.dart';
import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../utils/secure_storage.dart';
import '../../utils/storage.dart';
import '../bro_profile/bro_profile.dart';
import '../bro_settings/bro_settings.dart';
import '../chat_view/messaging_change_notifier.dart';
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
  late Storage storage;

  late BroHomeChangeNotifier broHomeChangeNotifier;

  List<Broup> shownBros = [];

  Me? me;
  @override
  void initState() {
    super.initState();
    socketServices = SocketServices();
    settings = Settings();
    storage = Storage();

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
    me = settings.getMe();
    if (me != null) {
      // Set all bros to be shown, except when the bro is searching.
      if (!searchMode && (settings.retrievedBroupData && settings.retrievedBroData)) {
        shownBros = me!.broups;
      }
      // Join Broups if not already joined.
      for (Broup broup in me!.broups) {
        if (!broup.joinedBroupRoom) {
          socketServices.joinRoomBroup(broup.getBroupId());
          broup.joinedBroupRoom = true;
        }
      }
      getBroupData();
    }
    setState(() {});
  }

  getBroData() {
    Me? me = settings.getMe();
    if (me != null && !settings.loggingIn && !settings.retrievedBroData) {
      settings.retrievedBroData = true;
      storage.fetchAllBros().then((brosDB) {
        // Map with broId as key
        Map<String, Bro> broMap = {for (var bro in brosDB) bro.getId().toString(): bro};
        List<int> broIdsToRetrieve = [];
        // Get all the bro ids to retrieve. These are the only private chats
        // The broup chats bro objects are only needed when the chat is opened
        // We will remove from the list when it's not needed to retrieve them
        for (Broup broup in me.broups) {
          if (broup.private) {
            for (int broId in broup.broIds) {
              if (me.getId() != broId) {
                broIdsToRetrieve.add(broId);
              }
            }
          }
        }

        for (Broup broup in settings.getMe()!.broups) {
          for (int broId in broup.broIds) {
            Bro? dbBro = broMap[broId.toString()];
            if (dbBro != null) {
              broIdsToRetrieve.remove(broId);
              broup.addBro(dbBro);
            }
          }
        }

        if (broIdsToRetrieve.isNotEmpty) {
          AuthServiceSocial().retrieveBros(broIdsToRetrieve).then((brosServer) {
            for (Bro bro in brosServer) {
              for (Broup broup in me.broups) {
                broup.addBro(bro);
              }
              storage.addBro(bro);
            }
            setState(() {});
          });
        } else {
          setState(() {});
        }
      });
    }
  }

  getBroupData() {
    // This function is important.
    // We call it when the page is loaded and also
    // multiple times later in case `me.bros`
    // was not filled at the time.
    // The `retrievedData` flag on the settings will
    // ensure that we only call this once.
    Me? me = settings.getMe();
    // `loggingIn` is set to false when we have finished logging in
    if (me != null && !settings.loggingIn && !settings.retrievedBroupData) {
      settings.retrievedBroupData = true;
      storage.fetchAllBroups().then((broups) {
        List<int> broupIdsToRetrieve = me.broups.map((broup) => broup.broupId).toList();
        Map<String, Broup> broupMap = {for (var broup in broups) broup.getBroupId().toString(): broup};
        for (Broup broup in settings.getMe()!.broups) {
          // Update the properties of the broup from me.bros with the properties from the database
          Broup? dbBroup = broupMap[broup.getBroupId().toString()];
          if (dbBroup != null) {
            print("broup from db ${dbBroup.broupId}  ${dbBroup.broIds}");
            broup
              ..alias = dbBroup.alias
              ..broIds = dbBroup.broIds
              ..adminIds = dbBroup.adminIds
              ..broupName = dbBroup.broupName
              ..broupDescription = dbBroup.broupDescription
              ..broupColour = dbBroup.broupColour
              ..private = dbBroup.private
              ..lastMessageId = dbBroup.lastMessageId
              ..avatar = dbBroup.avatar
              ..deleted = dbBroup.deleted
              ..removed = dbBroup.removed
              ..messages = dbBroup.messages;

            // Keep the following properties from me.bros
            // These are from the server and are up to date.
            broup
              ..unreadMessages = broup.unreadMessages
              ..updateBroup = broup.updateBroup
              ..newMessages = broup.newMessages
              ..mute = broup.mute;

            // Only update it if we have to.
            // If it's not in the db yet we update it anyway
            if (!broup.updateBroup) {
              broupIdsToRetrieve.remove(broup.getBroupId());
            }
          }
        }
        shownBros = settings.getMe()!.broups;
        if (broupIdsToRetrieve.isNotEmpty) {
          retrieveServerBroups(broupIdsToRetrieve);
        }
        getBroData();
        setState(() {});
      });
    }
  }

  retrieveServerBroups(List<int> broupIds) {
    print("retrieve broups from the server $broupIds");
    AuthServiceSocial().retrieveBroups(broupIds).then((broups) {
      print("broups retrieved");
      Me? me = settings.getMe();
      for (Broup broup in me!.broups) {
        if (broupIds.contains(broup.getBroupId())) {
          Broup? serverBroup;
          for (var element in broups) {
            if (element.getBroupId() == broup.getBroupId()) {
              serverBroup = element;
              break;
            }
          }
          if (serverBroup != null) {
            // We update like this to not lost existing properties like messages
            broup.updateBroupDataServer(serverBroup);
            // Should be false from the server, but we also set it to false here
            broup.updateBroup = false;
            storage.updateBroup(broup);
          }
        }
      }
      setState(() {});
    });
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
    if (me != null) {
      if (emojiField.isEmpty && typedText.isNotEmpty) {
        shownBros = me!.broups
            .where((element) =>
            element
                .getBroupNameOrAlias().toLowerCase()
                .contains(typedText.toLowerCase()))
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isEmpty) {
        shownBros = me!.broups
            .where((element) =>
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
        shownBros = me!.broups
            .where((element) =>
        element
            .getBroupNameOrAlias().toLowerCase()
            .contains(typedText.toLowerCase()) &&
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .toList();
      } else {
        // both empty
        shownBros = me!.broups;
      }
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

  backButtonFunctionality() {
    print("back home");
    if (searchMode) {
      setState(() {
        searchMode = false;
      });
    } else {
      exitApp();
    }
  }

  exitApp() {
    Me? me = settings.getMe();
    if (me != null) {
      socketServices.leaveRoomSolo(me.getId());
      settings.setLoggingIn(true);
      settings.retrievedBroupData = false;
      for (Broup broup in me.broups) {
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
    broHomeChangeNotifier.removeListener(broHomeChangeListener);
    socketServices.removeListener(broHomeChangeListener);
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
                icon: Icon(Icons.more_vert, color: getTextColor(Colors.white)),
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

  navigateToFindBros() {
    settings.doneRoutes.add(routes.FindBroRoute);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FindBros(key: UniqueKey())));
  }

  navigateToAddBroup() {
    settings.doneRoutes.add(routes.AddBroupRoute);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddBroup(key: UniqueKey())));
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        navigateToFindBros();
        break;
      case 3:
        navigateToAddBroup();
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
        settings.setLoggingIn(true);
        settings.retrievedBroupData = false;
        // TODO: put this back only for debugging
        // SecureStorage().logout();
        storage.clearDatabase();
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
          return BroTile(
              key: UniqueKey(),
              chat: shownBros[index],
              callback: callback
          );
        })
        : Container();
  }

  callback() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        print("didPop home: $didPop");
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
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
                                navigateToProfile(context, settings);
                              },
                              child: Container(
                                  color: Color(0x8b2d69a3),
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Hey ${settings.getMe()!.getBroName()} ${settings.getMe()!.getBromotion()}!",
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
            navigateToFindBros();
          },
        ),
      ),
    );
  }
}

