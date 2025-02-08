import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/auth_service_social.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/utils/new/storage.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/chat_view/bro_messaging/bro_messaging_change_notifier.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../../bro_profile.dart';
import '../../bro_settings.dart';
import 'models/message_tile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

class BroMessaging extends StatefulWidget {
  final Broup chat;

  BroMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {
  bool isLoading = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  BroMessagingChangeNotifier broMessagingChangeNotifier = BroMessagingChangeNotifier();

  bool showEmojiKeyboard = false;
  int amountViewed = 0;
  bool allMessagesDBRetrieved = false;
  bool busyRetrieving = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  late Broup chat;
  late Storage storage;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    chat.unreadMessages = 0;
    storage = Storage();
    socketServices.checkConnection();
    socketServices.addListener(messageViewListener);
    broMessageController.addListener(messageViewListener);
    broMessagingChangeNotifier.setBroupId(chat.getBroupId());

    BackButtonInterceptor.add(myInterceptor);

    // TODO: Retrieve messages from db if redirected straight to this page.

    messageScrollController.addListener(() {
      if (!busyRetrieving && !allMessagesDBRetrieved) {
        double distanceToTop =
            messageScrollController.position.maxScrollExtent -
                messageScrollController.position.pixels;
        if (distanceToTop < 1000) {
          busyRetrieving = true;
          amountViewed += 1;
          fetchExtraMessages(amountViewed);
        }
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      settings.doneRoutes.add(routes.ChatRoute);
      // TODO: first retrieve message when needed?
      // When the page is loaded we consider all messages as read
      chat.readMessages();
    });
  }

  messageViewListener() {
    print("update message view");
    setState(() {
    });
  }

  @override
  void dispose() {
    // notificationUtil.clearChat();
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(messageViewListener);
    broMessagingChangeNotifier.removeListener(messageViewListener);
    broMessagingChangeNotifier.setBroupId(-1);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  getMessages(int page) {
    setState(() {
      isLoading = true;
    });
    // List<Message> messagesServer = [];
    // List<Message> messagesDB = [];
    // bool gotServer = false;
    // bool gotLocalDB = false;
    // get messages from the server
    // get.getMessages(settings.getToken(), chat.id).then((val) {
    //   if (!(val is String)) {
    //     gotServer = true;
    //     List<Message> messes = val;
    //     if (messes.length != 0) {
    //       messagesServer = messes;
    //     }
    //     storeMessages(messes);
    //   } else {
    //     gotServer = false;
    //     // token validation probably failed, log in again
    //     storage.selectUser().then((user) async {
    //       if (user != null) {
    //         Auth auth = Auth();
    //         auth.signInUser(user).then((value) {
    //           if (value) {
    //             // If the user logged in again we will retrieve messages again.
    //             getMessages(page);
    //           }
    //         });
    //       }
    //     });
    //   }
    //
    //   if (gotLocalDB && gotServer) {
    //     mergeMessages(messagesServer + messagesDB);
    //     // Set date tiles, but only if all the messages are retrieved
    //     setState(() {
    //       if (this.messages.length != 0) {
    //         setDateTiles();
    //       }
    //     });
    //     chat.unreadMessages = 0;
    //   }
    //   if (gotServer) {
    //     socketServices.socket.emit(
    //       "message_read",
    //       {"bro_id": settings.getBroId(), "bros_bro_id": chat.id},
    //     );
    //   }
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
    // But also load what you have from your local database
    // storage.fetchAllMessages(chat.id, 0, 0).then((val) {
    //   // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
    //   if (val.length != 50) {
    //     allMessagesDBRetrieved = true;
    //   }
    //   List<Message> messes = val;
    //   if (messes.length != 0) {
    //     messagesDB = messes;
    //   }
    //   gotLocalDB = true;
    //   if (gotLocalDB && gotServer) {
    //     mergeMessages(messagesServer + messagesDB);
    //     // Set date tiles, but only if all the messages are retrieved
    //     setState(() {
    //       if (this.messages.length != 0) {
    //         setDateTiles();
    //       }
    //     });
    //     chat.unreadMessages = 0;
    //   }
    // });
  }

  fetchExtraMessages(int offSet) {
    // storage.fetchAllMessages(chat.id, 0, offSet).then((val) {
    //   // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
    //   if (val.length != 50) {
    //     allMessagesDBRetrieved = true;
    //   }
    //   if (val.length != 0) {
    //     mergeMessages(val);
    //     // Set date tiles, but only if all the messages are retrieved
    //     setState(() {
    //       if (this.messages.length != 0) {
    //         setDateTiles();
    //       }
    //     });
    //   }
    //   busyRetrieving = false;
    // });
  }

  // storeMessages(List<Message> messages) {
  //   for (Message message in messages) {
  //     if (message.id > 0) {
  //       storage.addMessage(message).then((value) {});
  //     }
  //   }
  // }

  // mergeMessages(List<Message> incomingMessages) {
  //   List<Message> newMessages = removeDuplicates(incomingMessages);
  //   if (this.messages.length != 0) {
  //     int lastId = this.messages[this.messages.length - 1].id;
  //     if (lastId == 0) {
  //       lastId = this.messages[this.messages.length - 2].id;
  //     }
  //     if (lastId <= newMessages[0].id) {
  //       newMessages = newMessages.where((x) => x.id < lastId).toList();
  //     }
  //     this.messages = this.messages.where((x) => x.id != 0).toList();
  //   }
  //   this.messages.addAll(newMessages);
  //   this.messages.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  // }

  // List<Message> removeDuplicates(List<Message> newMessages) {
  //   List<Message> noDuplicates = [];
  //   for (Message message in newMessages) {
  //     bool notAdded = true;
  //     for (Message messageNoDuplicate in noDuplicates) {
  //       if (message.id == messageNoDuplicate.id) {
  //         notAdded = false;
  //       }
  //     }
  //     if (notAdded) {
  //       noDuplicates.add(message);
  //     }
  //   }
  //   return noDuplicates;
  // }

  setDateTiles() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    Message messageFirst = this.chat.messages.first;
    DateTime dayFirst = DateTime(messageFirst.getTimeStamp().year,
        messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
    String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

    String timeMessageFirst = DateFormat.yMMMMd('en_US').format(dayFirst);
    if (dayFirst == today) {
      timeMessageFirst = "Today";
    }
    if (dayFirst == yesterday) {
      timeMessageFirst = "Yesterday";
    }

    Message timeMessage = new Message(
        0,
        0,
        timeMessageFirst,
        "",
        DateTime.now().toUtc().toString(),
        null,
        true,
        chat.getBroupId(),
    );
    for (int i = 0; i < this.chat.messages.length; i++) {
      DateTime current = this.chat.messages[i].getTimeStamp();
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

        String timeMessageTile = chatTimeTile;
        if (dayMessage == today) {
          timeMessageTile = "Today";
        }
        if (dayMessage == yesterday) {
          timeMessageTile = "Yesterday";
        }
        this.chat.messages.insert(i, timeMessage);
        timeMessage = new Message(
            0,
            0,
            timeMessageTile,
            "",
            DateTime.now().toUtc().toString(),
            null,
            true,
            chat.getBroupId(),
        );
      }
    }
    this.chat.messages.insert(this.chat.messages.length, timeMessage);
  }

  appendTextMessage() {
    if (!appendingMessage) {
      focusAppendText.requestFocus();
      if (broMessageController.text == "") {
        broMessageController.text = "✉️";
      }
      setState(() {
        showEmojiKeyboard = false;
        appendingMessage = true;
      });
    } else {
      focusEmojiTextField.requestFocus();
      appendTextMessageController.text = "";
      if (broMessageController.text == "✉️") {
        broMessageController.text = "";
      }
      setState(() {
        showEmojiKeyboard = true;
        appendingMessage = false;
      });
    }
  }

  sendMessage() {
    if (formKey.currentState!.validate()) {
      String message = broMessageController.text;
      String? textMessage = appendTextMessageController.text;
      if (textMessage.isEmpty) {
        textMessage = null;
      }
      // We add the message already as being send.
      // If it is received we remove this message and show 'received'
      String timestampString = DateTime.now().toUtc().toString();
      // The 'Z' indicates that it's UTC but we'll already add it in the message
      if (timestampString.endsWith('Z')) {
        timestampString =
            timestampString.substring(0, timestampString.length - 1);
      }
      Message mes = new Message(
          -1,
          settings.getMe()!.getId(),
          message,
          textMessage,
          DateTime.now().toUtc().toString(),
          null,
          false,
          chat.getBroupId(),
      );
      mes.isRead = 2;
      setState(() {
        this.chat.messages.insert(0, mes);
      });
      String? messageData = null;
      AuthServiceSocial().sendMessage(chat.getBroupId(), message, textMessage, messageData).then((value) {
        if (value) {
          // message send
          // TODO: set broup to `update` until message arrives?
        } else {
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          setState(() {
            this.chat.messages.removeAt(0);
          });
        }
      });
      broMessageController.clear();
      appendTextMessageController.clear();

      if (appendingMessage) {
        focusEmojiTextField.requestFocus();
        setState(() {
          showEmojiKeyboard = true;
          appendingMessage = false;
        });
      }
    }
  }

  // updateUserActivity(String timestamp) {
  //   storage.updateChat(chat).then((value) {
  //     // chat updated
  //   });
  //   chat.lastActivity = timestamp;
  //   broList.updateChat(chat);
  // }

  messageRead(var data) {
    var timeLastRead = DateTime.parse(data + 'Z').toLocal();
    for (Message message in this.chat.messages) {
      if (timeLastRead.isAfter(message.getTimeStamp())) {
        message.isRead = 1;
      }
    }
    setState(() {
      this.chat.messages = this.chat.messages;
    });
  }

  var messageScrollController = ScrollController();

  Widget messageList() {
    return chat.messages.isNotEmpty
        ? ListView.builder(
            itemCount: chat.messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              return MessageTile(
                  key: UniqueKey(),
                  message: chat.messages[index],
                  myMessage: chat.messages[index].senderId == settings.getMe()!.getId());
            })
        : Container();
  }

  void onTapEmojiTextField() {
    if (!showEmojiKeyboard) {
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  void onTapAppendTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      if (settings.doneRoutes.contains(routes.BroHomeRoute)) {
        // We want to pop until we reach the BroHomeRoute
        // We remove one, because it's this page.
        settings.doneRoutes.removeLast();
        for (int i = 0; i < 200; i++) {
          String route = settings.doneRoutes.removeLast();
          Navigator.pop(context);
          if (route == routes.BroHomeRoute) {
            break;
          }
        }
      } else {
        // TODO: How to test this?
        settings.doneRoutes = [];
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BroCastHome(key: UniqueKey())));
      }
    }
  }

  PreferredSize appBarChat() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor: chat.getColor(),
          title: InkWell(
              onTap: () {
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             BroChatDetails(key: UniqueKey(), chat: chat)));
              },
              child: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  child: Text(chat.getBroupNameOrAlias(),
                      style: TextStyle(
                          color: getTextColor(chat.getColor()),
                          fontSize: 20)))),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelectChat(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Chat details")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             BroChatDetails(key: UniqueKey(), chat: chat)));
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarChat(),
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: Stack(children: [
              messageList(),
              isLoading
                  ? Center(
                      child: Container(child: CircularProgressIndicator()))
                  : Container()
            ])),
            Container(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Color(0x36FFFFFF),
                        borderRadius: BorderRadius.circular(35)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            appendTextMessage();
                          },
                          child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: appendingMessage
                                      ? Colors.green
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(35)),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.text_snippet,
                                  color: appendingMessage
                                      ? Colors.white
                                      : Color(0xFF616161))),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Form(
                              key: formKey,
                              child: TextFormField(
                                focusNode: focusEmojiTextField,
                                validator: (val) {
                                  if (val == null ||
                                      val.isEmpty ||
                                      val.trimRight().isEmpty) {
                                    return "Can't send an empty message";
                                  }
                                  if (chat.isBlocked()) {
                                    return "Can't send messages to a blocked bro";
                                  }
                                  return null;
                                },
                                onTap: () {
                                  onTapEmojiTextField();
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: broMessageController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                    hintText: "Emoji message...",
                                    hintStyle:
                                        TextStyle(color: Colors.white54),
                                    border: InputBorder.none),
                                readOnly: true,
                                showCursor: true,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // await availableCameras().then((value) => Navigator.pushReplacement(context,
                            //     MaterialPageRoute(builder: (_) => CameraPage(
                            //         chat: chat,
                            //         cameras: value
                            //     ))));
                            // pickImage();
                          },
                          child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(35)),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.camera_alt,
                                  color: Color(0xFF616161))),
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            sendMessage();
                          },
                          child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Color(0xFF34A843),
                                  borderRadius: BorderRadius.circular(35)),
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
                child: appendingMessage
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                              color: Color(0x36FFFFFF),
                              borderRadius: BorderRadius.circular(35)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Form(
                                    child: TextFormField(
                                      onTap: () {
                                        onTapAppendTextField();
                                      },
                                      focusNode: focusAppendText,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      controller: appendTextMessageController,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                          hintText: "Append text message...",
                                          hintStyle: TextStyle(
                                              color: Colors.white54),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container()),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                emojiController: broMessageController,
                emojiKeyboardHeight: 300,
                showEmojiKeyboard: showEmojiKeyboard,
                darkMode: settings.getEmojiKeyboardDarkMode(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
