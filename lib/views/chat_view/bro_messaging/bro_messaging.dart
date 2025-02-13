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
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../../../objects/bro.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';
import '../chat_details/chat_details.dart';
import '../chat_details/chat_details.dart';
import '../message_util.dart';
import 'models/bro_message_tile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

class BroMessaging extends StatefulWidget {
  final Broup chat;

  BroMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {
  bool isLoadingBros = false;
  bool isLoadingMessages = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();

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

  ScrollController messageScrollController = ScrollController();

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
    messagingChangeNotifier.addListener(messageViewListener);
    messagingChangeNotifier.setBroupId(chat.getBroupId());

    BackButtonInterceptor.add(myInterceptor);

    messageScrollController.addListener(() {
      if (!busyRetrieving && !allMessagesDBRetrieved) {
        double distanceToTop =
            messageScrollController.position.maxScrollExtent -
                messageScrollController.position.pixels;
        print("distance to top: $distanceToTop");
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

  messageViewListener() {
    setState(() {
    });
  }

  @override
  void dispose() {
    // We were just on the messaging page, so we consider all messages as read
    chat.unreadMessages = 0;
    messagingChangeNotifier.setBroupId(-1);
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(messageViewListener);
    messagingChangeNotifier.removeListener(messageViewListener);
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

  sendMessage() {
    if (formKey.currentState!.validate()) {
      String message = broMessageController.text;
      String? textMessage = appendTextMessageController.text;
      if (textMessage.isEmpty) {
        textMessage = null;
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
      mes.isRead = 2;  // indicates send to server but not received
      setState(() {
        this.chat.messages.insert(0, mes);
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

  Widget messageList() {
    return chat.messages.isNotEmpty
        ? ListView.builder(
            itemCount: chat.messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              return BroMessageTile(
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

  onSelectChat(BuildContext context, int item) {
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
                    ChatDetails(
                        key: UniqueKey(),
                        chat: chat
                    )));
        break;
      case 3:
        navigateToHome();
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
