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
import 'package:flutter/services.dart';

import '../../objects/broup.dart';
import '../../objects/me.dart';
import '../../utils/life_cycle_service.dart';
import '../../utils/notification_controller.dart';
import '../../utils/storage.dart';
import 'bro_home_change_notifier.dart';
import 'models/bro_tile.dart';

class BrocastHome extends StatefulWidget {
  BrocastHome({required Key key}) : super(key: key);

  @override
  _BrocastHomeState createState() => _BrocastHomeState();
}

class _BrocastHomeState extends State<BrocastHome> {

  bool showEmojiKeyboard = false;
  bool searchMode = false;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  late SocketServices socketServices;
  late Settings settings;
  late Storage storage;

  late BroHomeChangeNotifier broHomeChangeNotifier;
  late NotificationController notificationController;
  late LifeCycleService lifeCycleService;

  List<Broup> shownBros = [];

  Me? me;

  @override
  void initState() {
    super.initState();
    socketServices = SocketServices();
    settings = Settings();
    storage = Storage();
    notificationController = NotificationController();
    broHomeChangeNotifier = BroHomeChangeNotifier();
    broHomeChangeNotifier.addListener(broHomeChangeListener);
    lifeCycleService = LifeCycleService();
    lifeCycleService.addListener(lifeCycleChangeListener);
    socketServices.addListener(broHomeChangeListener);

    // Wait until page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      broHomeChangeListener();
      checkNotificationListener();

      // A hacky way to check if all the avatars are available.
      // If one of the private or broup chats do not have a avatar after a few seconds we can assume something went wrong.
      Future.delayed(Duration(seconds: 2)).then((value) {
        if (me != null) {
          List<int> broAvatarIds = [];
          List<int> broupAvatarIds = [];
          for (Broup meBroup in me!.broups) {
            if (!meBroup.removed) {
              if (meBroup.private) {
                if (meBroup.getAvatar() == null) {
                  for (int broId in meBroup.broIds) {
                    if (broId != me!.getId()) {
                      if (!broAvatarIds.contains(broId)) {
                        broAvatarIds.add(broId);
                      }
                    }
                  }
                }
              } else {
                if (meBroup.getAvatar() == null) {
                  if (!broupAvatarIds.contains(meBroup.getBroupId())) {
                    broupAvatarIds.add(meBroup.getBroupId());
                  }
                }
              }
            }
          }
          if (broAvatarIds.isNotEmpty) {
            AuthServiceSocial().broDetails([], broAvatarIds, null);
          }
          if (broupAvatarIds.isNotEmpty) {
            AuthServiceSocial().broupDetails([], broupAvatarIds);
          }
        }
      });
    });
  }

  checkNotificationListener() {
    Me? me = settings.getMe();
    if (me != null) {
      if (notificationController.navigateChat) {
        notificationController.navigateChat = false;
        int chatId = notificationController.navigateChatId;
        Broup broup = me.broups.firstWhere((element) => element.getBroupId() == chatId);
        notificationController.navigateChatId = -1;
        if (broup.getBroupId() == chatId) {
          navigateToChat(context, settings, broup);
        }
      }
    }
  }

  lifeCycleChangeListener() {
    // To be sure we check the broups again when the app is resumed.
    broHomeChangeListener();
  }

  broHomeChangeListener() {
    me = settings.getMe();
    if (me != null) {
      // Set all bros to be shown, except when the bro is searching.
      if (!searchMode) {
        shownBros = me!.broups.where((broup) => !broup.deleted).toList();
        shownBros.sort((a, b) => b.getLastActivity().compareTo(a.getLastActivity()));
      }
      // Join Broups if not already joined.
      for (Broup broup in me!.broups) {
        if (!broup.joinedBroupRoom && !broup.removed && !broup.deleted) {
          socketServices.joinRoomBroup(broup.getBroupId());
          broup.joinedBroupRoom = true;
        }
      }
      if (!settings.retrievedBroupData) {
        settings.retrievedBroupData = true;
        getBroupData(storage, me!);
      }
    }
    setState(() {});
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
            .where((group) => !group.deleted).toList()
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isEmpty) {
        shownBros = me!.broups
            .where((element) =>
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .where((group) => !group.deleted).toList()
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
        shownBros = me!.broups
            .where((element) =>
        element
            .getBroupNameOrAlias().toLowerCase()
            .contains(typedText.toLowerCase()) &&
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .where((group) => !group.deleted).toList()
            .toList();
      } else {
        // both empty
        // the broup objects from `me.broups` where the deleted is false.
        shownBros = me!.broups.where((group) => !group.deleted).toList();
      }
      shownBros.sort((a, b) => b.getLastActivity().compareTo(a.getLastActivity()));
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
      settings.setLoggingIn(false);
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
    lifeCycleService.removeListener(lifeCycleChangeListener);
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
                  broNameController.text = "";
                  bromotionController.text = "";
                  onChangedBroNameField(broNameController.text, bromotionController.text);
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
                icon: Icon(Icons.more_vert, color: Colors.white),
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

  showDialogLogout(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Are you sure!?"),
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You want to logout of Brocast.\n",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextSpan(
                    text: "This means you will not receive any messages while you're logged out.\n",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
              new TextButton(
                child: new Text("Logout"),
                onPressed: () {
                  Navigator.of(context).pop();
                  AuthServiceSocial().updateFCMToken("").then((value) {
                    if (value) {
                    }
                  });
                  Future.delayed(Duration(milliseconds: 100), () {
                    actuallyLogout(settings, socketServices, context);

                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn(
                            key: UniqueKey(),
                            showRegister: false
                        )));
                  });
                },
              ),
            ],
          );
        });
  }

  navigateToFindBros() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => FindBros(key: UniqueKey())));
  }

  navigateToAddBroup() {
    Navigator.pushReplacement(
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
      showDialogLogout(context);

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

  Widget profileHeader() {
    Uint8List? avatar = null;
    if (me != null) {
      avatar = me!.getAvatar();
    }
    String broName = "";
    String bromotion = "";
    if (me != null) {
      broName = me!.getBroName();
      bromotion = me!.getBromotion();
    }
    return Container(
      child: Material(
        child: InkWell(
          onTap: () {
            navigateToProfile(context, settings);
          },
          child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Color(0x8b2d69a3),
                        width: 80,
                        height: 80,
                        child: avatarBox(80, 80, avatar),
                      ),
                      Column(
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 10, top: 5),
                                color: Color(0x8b2d69a3),
                                width: MediaQuery.of(context).size.width-80,
                                height: 30,
                                // alignment: Alignment.center,
                                child: Text(
                                  "Hey",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                )
                            ),
                            Container(
                                padding: EdgeInsets.only(left: 10, top: 5),
                                color: Color(0x8b2d69a3),
                                width: MediaQuery.of(context).size.width-80,
                                height: 50,
                                // alignment: Alignment.center,
                                child: Text(
                                  "$broName $bromotion!",
                                  style: TextStyle(color: Colors.white, fontSize: 22),
                                )
                            ),
                          ]
                      ),
                    ]
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 2,
                  color: Colors.white,
                )
              ]
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
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
                        profileHeader(),
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
                  Column(
                      children: [
                        !showEmojiKeyboard ? SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        ) : Container(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: EmojiKeyboard(
                              emojiController: bromotionController,
                              emojiKeyboardHeight: 350,
                              showEmojiKeyboard: showEmojiKeyboard,
                              darkMode: settings.getEmojiKeyboardDarkMode()),
                        ),
                      ]
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

