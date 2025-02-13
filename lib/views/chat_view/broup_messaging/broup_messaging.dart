import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/get_messages.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/socket_services.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../../../objects/bro.dart';
import '../../../services/auth/auth_service_social.dart';
import '../../../utils/new/storage.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';
import '../chat_details/chat_details.dart';
import '../chat_details/chat_details.dart';
import '../message_util.dart';
import 'models/broup_message_tile.dart';

class BroupMessaging extends StatefulWidget {
  final Broup chat;

  BroupMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _BroupMessagingState createState() => _BroupMessagingState();
}

class _BroupMessagingState extends State<BroupMessaging> {
  bool isLoadingBros = false;
  bool isLoadingMessages = false;
  GetMessages get = new GetMessages();
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<Message> messages = [];

  late Broup chat;
  late Storage storage;

  int amountViewed = 0;
  bool allMessagesDBRetrieved = false;
  bool busyRetrieving = false;

  var messageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    storage = Storage();
    socketServices.checkConnection();
    socketServices.addListener(socketListener);

    BackButtonInterceptor.add(myInterceptor);

    messageScrollController.addListener(() {
      if (!busyRetrieving && !allMessagesDBRetrieved) {
        double distanceToTop =
            messageScrollController.position.maxScrollExtent -
                messageScrollController.position.pixels;
        if (distanceToTop < 1000) {
          busyRetrieving = true;
          amountViewed += 1;
          fetchExtraMessages(amountViewed, chat, storage).then((value) {
            allMessagesDBRetrieved = value;
            busyRetrieving = false;
          });
        }
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      settings.doneRoutes.add(routes.ChatRoute);

      setState(() {
        isLoadingBros = true;
        isLoadingMessages = true;
      });
      getMessages(0, chat, storage).then((value) {
        allMessagesDBRetrieved = value;
        setState(() {
          if (chat.messages.length != 0) {
            setDateTiles(chat);
            if (chat.messages[0].messageId <= 0) {
              chat.lastMessageId = chat.messages[1].messageId;
            } else {
              chat.lastMessageId = chat.messages[0].messageId;
            }
          }
          isLoadingMessages = false;
        });
      });
      getBros(chat, storage, settings.getMe()!).then((value) {
        setState(() {
          isLoadingBros = false;
        });
      });
    });
  }

  socketListener() {
    setState(() {});
  }

  addNewBro(int addBroId) {
    // socketServices.socket
    //     .on('message_event_add_bro_success', (data) => broWasAdded(data));
    // socketServices.socket.on('message_event_add_bro_failed', (data) {
    //   broAddingFailed();
    // });
    // socketServices.socket.emit("message_event_add_bro",
    //     {"token": settings.getToken(), "bros_bro_id": addBroId});
  }

  broWasAdded(data) {
    // BroBros broBros = new BroBros(
    //     data["bros_bro_id"],
    //     data["chat_name"],
    //     data["chat_description"],
    //     data["alias"],
    //     data["chat_colour"],
    //     data["unread_messages"],
    //     data["last_time_activity"],
    //     data["room_name"],
    //     data["blocked"] ? 1 : 0,
    //     data["mute"] ? 1 : 0,
    //     0);
    // broList.addChat(broBros);
    // storage.addChat(broBros).then((value) {
    //   broList.updateBroupBrosForBroBros(broBros);
    //   Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => BroCastHome(key: UniqueKey())));
    // });
  }

  @override
  void dispose() {
    chat.unreadMessages = 0;
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(socketListener);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
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

  sendMessageBroup() {
    // TODO: copied?
    if (formKey.currentState!.validate()) {
      String message = broMessageController.text;
      String textMessage = appendTextMessageController.text;
      // We add the message already as being send.
      // If it is received we remove this message and show 'received'
      String timestampString = DateTime.now().toUtc().toString();
      // The 'Z' indicates that it's UTC but we'll already add it in the message
      if (timestampString.endsWith('Z')) {
        timestampString =
            timestampString.substring(0, timestampString.length - 1);
      }
      // We set the id to be "-1". For date tiles it is "0", these will be filtered.
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
      setState(() {
        this.messages.insert(0, mes);
      });
      String? messageData = null;
      AuthServiceSocial().sendMessage(chat.getBroupId(), message, textMessage, messageData).then((value) {
        if (value) {
          // message send
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

  messageRead(var data) {
    // TODO: copied?
    var timeLastRead = DateTime.parse(data + 'Z').toLocal();
    for (Message message in this.messages) {
      if (timeLastRead.isAfter(message.getTimeStamp())) {
        message.isRead = 1;
      }
    }
    setState(() {
      this.messages = this.messages;
    });
  }


  Widget messageList() {
    return messages.isNotEmpty
        ? ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              return BroupMessageTile(
                  key: UniqueKey(),
                  message: messages[index],
                  senderName: getSender(messages[index].senderId),
                  senderId: messages[index].senderId,
                  broAdded: getIsAdded(messages[index].senderId),
                  // myMessage: messages[index].senderId == settings.getBroId(),
                  myMessage: messages[index].senderId == 1,
                  addNewBro: addNewBro);
            })
        : Container();
  }

  bool getIsAdded(int senderId) {
    // TODO: How is this used?
    // for (Chat bro in broList.getBros()) {
    //   if (!bro.isBroup()) {
    //     if (bro.id == senderId) {
    //       return true;
    //     }
    //   }
    // }
    return false;
  }

  String getSender(int senderId) {
    // TODO: How is this used?
    // String broName = "";
    // for (Chat bro in broList.getBros()) {
    //   if (!bro.isBroup()) {
    //     if (bro.id == senderId) {
    //       return bro.getBroNameOrAlias();
    //     }
    //   }
    // }
    // for (Bro bro in chat.getBroupBros()) {
    //   if (bro.id == senderId) {
    //     return bro.getFullName();
    //   }
    // }
    return "broName";
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

  navigateToHome() {
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
        if (settings.doneRoutes.length == 0) {
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

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      navigateToHome();
    }
  }

  PreferredSize appBarChat() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Ink(
        color: chat.getColor(),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatDetails(key: UniqueKey(), chat: chat)));
          },
          child: AppBar(
              leading: IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
                  onPressed: () {
                    backButtonFunctionality();
                  }),
              backgroundColor: Colors.transparent,
              title: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  child: Text(chat.getBroupNameOrAlias(),
                      style: TextStyle(
                          color: getTextColor(chat.getColor()),
                          fontSize: 20))),
              actions: [
                PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert, color: getTextColor(chat.getColor())),
                    onSelected: (item) => onSelectChat(context, item),
                    itemBuilder: (context) => [
                          PopupMenuItem<int>(value: 0, child: Text("Profile")),
                          PopupMenuItem<int>(value: 1, child: Text("Settings")),
                          PopupMenuItem<int>(
                              value: 2, child: Text("Broup details")),
                          PopupMenuItem<int>(value: 3, child: Text("Home"))
                        ])
              ]),
        ),
      ),
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.push(
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatDetails(key: UniqueKey(), chat: chat)));
        break;
      case 3:
        Navigator.push(
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
              isLoadingBros || isLoadingMessages
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
                                  if (chat.hasLeft()) {
                                    return "You're no longer a participant in this Broup";
                                  }
                                  if (chat.isBlocked()) {
                                    return "Can't send messages to a blocked Broup";
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
                            // // pickImage();
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
                            sendMessageBroup();
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

