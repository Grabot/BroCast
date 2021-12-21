import 'dart:io';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/services/get_bros.dart';
import 'package:brocast/services/navigation_service.dart';
import 'package:brocast/services/reset_registration.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/add_broup.dart';
import 'package:brocast/views/find_bros.dart';
import 'package:brocast/views/signin.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';


class BroCastHome extends StatefulWidget {
  BroCastHome(
      {
        required Key key
      }) : super(key: key);

  @override
  _BroCastHomeState createState() => _BroCastHomeState();
}

class _BroCastHomeState extends State<BroCastHome> {
  GetBros getBros = new GetBros();
  Settings settings = Settings();
  late SocketServices socketServices;
  BroList broList = BroList();

  bool isSearching = false;
  List<Chat> bros = [];
  List<Chat> shownBros = [];

  bool showEmojiKeyboard = false;
  bool searchMode = false;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  DateTime? lastPressed;

  Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    broList = BroList();
    socketServices = SocketServices();
    socketServices.setStorageInstance(storage);
    socketServices.setBroListInstance(broList);
    if (settings.getBroId() != -1) {
      socketServices.joinRoomSolo(settings.getBroId());
    }
    BackButtonInterceptor.add(myInterceptor);
    bromotionController.addListener(bromotionListener);
    socketServices.addListener(socketListener);
    socketServices.updateBroups();

    bros = broList.getBros();
    bros.sort((b, a) => a.getLastActivity().compareTo(b.getLastActivity()));
    setState(() {
      shownBros = bros;
    });

    setUser();
  }

  setUser() {
    storage.selectUser().then((user) async {
      if (user != null) {
        settings.setEmojiKeyboardDarkMode(user.getKeyboardDarkMode());
        settings.setBroId(user.id);
        settings.setBroName(user.broName);
        settings.setBromotion(user.bromotion);
        settings.setToken(user.token);
        if (mounted) {
          setState(() {});
        }
        if (user.shouldRecheck() || broList.getBros().length == 0) {
          broList.searchBros(user.token).then((value) {
            if (value) {
              user.recheckBros = 0;
              user.updateActivityTime();
              storage.updateUser(user).then((value) {
              });
              // We sign in again even though we are already signed in.
              // This is just to update the token in case it is invalidated.
              Auth auth = Auth();
              auth.signInUser(user).then((value) {
                if (mounted) {
                  setState(() {});
                }
              });
            }
          });
        }
      }
    });
  }

  socketListener() {
    bros = broList.getBros();
    bros.sort((b, a) => a.getLastActivity().compareTo(b.getLastActivity()));
    setState(() {
      shownBros = bros;
    });
  }

  Widget listOfBros() {
    return shownBros.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: shownBros.length,
            itemBuilder: (context, index) {
              return BroTile(
                key: UniqueKey(),
                chat: shownBros[index]
              );
            })
        : Container();
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
      shownBros = bros.where((element) =>
          element.getBroNameOrAlias().toLowerCase()
              .contains(typedText.toLowerCase())).toList();
    } else if (emojiField.isNotEmpty && typedText.isEmpty) {
      shownBros = bros.where((element) =>
          element.getBroNameOrAlias().toLowerCase()
              .contains(emojiField)).toList();
    } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
      shownBros = bros.where((element) =>
      element.getBroNameOrAlias().toLowerCase()
          .contains(typedText.toLowerCase()) &&
          element.getBroNameOrAlias().toLowerCase()
              .contains(emojiField)).toList();
    } else {
      // both empty
      shownBros = bros;
    }
    setState(() {
    });
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return backButtonFunctionality();
  }

  bool backButtonFunctionality() {
    if (mounted) {
      if (showEmojiKeyboard) {
        setState(() {
          showEmojiKeyboard = false;
        });
        return true;
      } else if (searchMode) {
        onChangedBroNameField("", "");
        bromotionController.text = "";
        broNameController.text = "";
        setState(() {
          searchMode = false;
        });
        return true;
      } else {
        return false;
      }
    }
    return false;
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

  @override
  void dispose() {
    socketServices.removeListener(socketListener);
    bromotionController.removeListener(bromotionListener);
    BackButtonInterceptor.remove(myInterceptor);
    bromotionController.dispose();
    broNameController.dispose();
    super.dispose();
  }

  PreferredSize appBarHome(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: searchMode ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }
          ) : Container(),
          title:
              Container(alignment: Alignment.centerLeft, child: Text("Brocast")),
          actions: [
            searchMode ? IconButton(
              icon: Icon(Icons.search_off, color: Colors.white),
              onPressed: () {
                setState(() {
                  searchMode = false;
                });
              }
            ) : IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    searchMode = true;
                  });
                }
            ),
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Find a new Bro")),
                      PopupMenuItem<int>(value: 3, child: Text("Add new Broup")),
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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FindBros(
            key: UniqueKey()
        )));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AddBroup(
            key: UniqueKey()
        )));
        break;
      case 4:
        socketServices.leaveRoomSolo(settings.getBroId());
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
        break;
      case 5:
        socketServices.leaveRoomSolo(settings.getBroId());
        ResetRegistration resetRegistration = new ResetRegistration();
        resetRegistration.removeRegistrationId(settings.getBroId());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SignIn(
          key: UniqueKey()
        )));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarHome(context),
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;

          if (isWarning) {
            lastPressed = DateTime.now();

            final snackBar = SnackBar(
              content: Text('Press back twice to exit the application'),
              duration: maxDuration,
            );

            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snackBar);

            return false;
          } else {
            socketServices.leaveRoomSolo(settings.getBroId());
            return true;
          }
        },
        child: Container(
            child: Column(children: [
          Container(
            child: Material(
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => BroProfile(
                        key: UniqueKey()
                      )));
                },
                child: Container(
                    color: Color(0x8b2d69a3),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      "Hey ${settings.getBroName()} ${settings.getBromotion()}!",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ),
              color: Colors.transparent,
            ),
          ),
          searchMode ? Container(
            child: Row(
                children: [
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
                ]
            ),
          ) : Container(),
          Container(
            child: Expanded(child: listOfBros()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: EmojiKeyboard(
                bromotionController: bromotionController,
                emojiKeyboardHeight: 300,
                showEmojiKeyboard: showEmojiKeyboard,
                darkMode: settings.getEmojiKeyboardDarkMode()
            ),
          ),
        ])),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FindBros(
            key: UniqueKey()
          )));
        },
      ),
    );
  }
}

class BroTile extends StatefulWidget {
  final Chat chat;

  BroTile(
      {
        required Key key,
        required this.chat
      }) : super(key: key);

  @override
  _BroTileState createState() => _BroTileState();
}

class _BroTileState extends State<BroTile> {

  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  final NavigationService _navigationService = locator<NavigationService>();
  var _tapPosition;

  selectBro(BuildContext context) {
    if (widget.chat.isBroup()) {
      _navigationService.navigateTo(routes.BroupRoute, arguments: widget.chat);
    } else {
      _navigationService.navigateTo(routes.BroRoute, arguments: widget.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onLongPress: _showChatDetailPopupMenu,
          onTapDown: _storePosition,
          onTap: () {
            selectBro(context);
          },
          child: Container(
              color: widget.chat.unreadMessages < 4
                      ? widget.chat.unreadMessages < 3
                          ? widget.chat.unreadMessages < 2
                              ? widget.chat.unreadMessages < 1
                                  ? widget.chat.getColor().withOpacity(0.6)
                              : widget.chat.getColor().withOpacity(0.7)
                          : widget.chat.getColor().withOpacity(0.8)
                      : widget.chat.getColor().withOpacity(0.9)
                  : widget.chat.getColor().withOpacity(1),
              padding: EdgeInsets.only(top: 16, bottom: 16, right: 24, left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      widget.chat.isMuted() || widget.chat.isBlocked() || widget.chat.hasLeft()
                      ? Container(
                        width: 35,
                          child: Column(
                            children:
                            [
                              widget.chat.isBlocked() || widget.chat.hasLeft() ? Icon(
                                widget.chat.hasLeft() ? Icons.person_remove : Icons.block, // Block or left can't both be true
                                color: getTextColor(widget.chat.getColor()).withOpacity(0.6)
                              ) : Container(
                                height: 20,
                              ),
                              widget.chat.isMuted() ? Icon(
                                  Icons.volume_off,
                                  color: getTextColor(widget.chat.getColor()).withOpacity(0.6)
                              ) : Container(
                                height: 20,
                              ),
                            ]
                          )
                      )
                      : SizedBox(width: 35),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // All the padding and sizedboxes (and message bal) added up it's 103.
                              // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                              width: MediaQuery.of(context).size.width - 110,
                              child: Text(
                                  widget.chat.getBroNameOrAlias(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                            widget.chat.alias != ""
                                ? Container(
                              // If there is an alias, we want to show the name of the bro as well.
                              // We will do that in smaller letters underneath
                              width: MediaQuery.of(context).size.width - 110,
                              child: Text("     -" + widget.chat.chatName,
                                  style: TextStyle(
                                      color: getTextColor(widget.chat.getColor()), fontSize: 10)),
                            )
                                : Container(),
                            widget.chat.chatDescription != ""
                                ? Container(
                                    // All the padding and sizedboxes (and message bal) added up it's 103.
                                    // We need to make the width the total width of the screen minus 103 at least to not get an overflow.
                                    width:
                                        MediaQuery.of(context).size.width - 110,
                                    child: Text(widget.chat.chatDescription,
                                        style: TextStyle(
                                            color: getTextColor(widget.chat.getColor()), fontSize: 12)),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: widget.chat.getColor(),
                          borderRadius: BorderRadius.circular(40)),
                      child: Text(
                        widget.chat.unreadMessages.toString(),
                        style: TextStyle(
                            color: getTextColor(widget.chat.getColor()),
                            fontSize: 16),
                      )),
                ],
              )),
        ),
        color: Colors.transparent,
      ),
    );
  }

  void showDialogUnMuteChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Unmute notifications?"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Unmute"),
                onPressed: () {
                  unmuteTheChat();
                },
              ),
            ],
          );
        });
  }

  void showDialogMuteChat(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Mute notifications for..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(4, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedRadio = index);
                      },
                      child: Row(
                          children: [
                            Radio<int>(
                                value: index,
                                groupValue: selectedRadio,
                                onChanged: (int? value) {
                                  if (value != null) {
                                    setState(() => selectedRadio = value);
                                  }
                                }
                            ),
                            index == 0 ? Container(
                                child: Text("1 hour")
                            ) : Container(),
                            index == 1 ? Container(
                                child: Text("8 hours")
                            ) : Container(),
                            index == 2 ? Container(
                                child: Text("1 week")
                            ) : Container(),
                            index == 3 ? Container(
                                child: Text("Indefinitely")
                            ) : Container(),
                          ]
                      ),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Mute"),
                onPressed: () {
                  muteTheChat(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  void unmuteTheChat() {
    if (widget.chat is BroBros) {
      socketServices.socket
          .emit("message_event_change_chat_mute", {
        "token": settings.getToken(),
        "bros_bro_id": widget.chat.id,
        "bro_id": settings.getBroId(),
        "mute": -1
      });
    } else {
      socketServices.socket
          .emit("message_event_change_broup_mute", {
        "token": settings.getToken(),
        "broup_id": widget.chat.id,
        "bro_id": settings.getBroId(),
        "mute": -1
      });
    }
    Navigator.of(context).pop();
  }

  void muteTheChat(int selectedRadio) {
    if (widget.chat is BroBros) {
      socketServices.socket
          .emit("message_event_change_chat_mute", {
        "token": settings.getToken(),
        "bros_bro_id": widget.chat.id,
        "bro_id": settings.getBroId(),
        "mute": selectedRadio
      });
    } else {
      socketServices.socket
          .emit("message_event_change_broup_mute", {
        "token": settings.getToken(),
        "broup_id": widget.chat.id,
        "bro_id": settings.getBroId(),
        "mute": selectedRadio
      });
    }
    Navigator.of(context).pop();
  }

  void _showChatDetailPopupMenu() {
    final RenderBox overlay = Overlay
        .of(context)!
        .context
        .findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [
          ChatDetailPopup(
            key: UniqueKey(),
            chat: widget.chat
          )
        ],
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40),
            Offset.zero & overlay.size
        )
    ).then((int? delta) {
      if (delta == 1) {
        if (widget.chat.isBroup()) {
          _navigationService.navigateTo(routes.BroupRoute, arguments: widget.chat);
        } else {
          _navigationService.navigateTo(routes.BroRoute, arguments: widget.chat);
        }
      } else if (delta == 2) {
        showDialogMuteChat(context);
      } else if (delta == 3) {
        showDialogUnMuteChat(context);
      }
      return;
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
class ChatDetailPopup extends PopupMenuEntry<int> {

  final Chat chat;

  ChatDetailPopup({
    required Key key,
    required this.chat
  }) : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  ChatDetailPopupState createState() => ChatDetailPopupState();

  @override
  double get height => 1;
}

class ChatDetailPopupState extends State<ChatDetailPopup> {

  @override
  Widget build(BuildContext context) {
    return getPopupItems(context, widget.chat);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonMute(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

void buttonUnmute(BuildContext context) {
  Navigator.pop<int>(context, 3);
}

Widget getPopupItems(BuildContext context, Chat chat) {
  return Column(
    children: [
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              buttonMessage(context);
            },
            child: Text(
              'Message ${chat.getBroNameOrAlias()}',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        child: TextButton(
            onPressed: () {
              chat.isMuted() ? buttonUnmute(context) : buttonMute(context);
            },
            child: Text(
              chat.isMuted() ? 'Unmute chat' : 'Mute chat',
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.black, fontSize: 14),
            )
        ),
      ),
    ]
  );
}
