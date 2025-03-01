import 'dart:async';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../objects/bro.dart';
import '../../../services/auth/auth_service_social.dart';
import '../../utils/storage.dart';
import '../../objects/me.dart';
import 'chat_details/chat_details.dart';
import 'message_util.dart';
import 'models/bro_message_tile.dart';
import 'models/broup_message_tile.dart';

class ChatMessaging extends StatefulWidget {
  final Broup chat;

  ChatMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatMessagingState createState() => _ChatMessagingState();
}

class _ChatMessagingState extends State<ChatMessaging> {
  bool isLoadingBros = false;
  bool isLoadingMessages = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  late Broup chat;
  late Storage storage;
  late NotificationController notificationController;

  int amountViewed = 0;
  bool allMessagesDBRetrieved = false;
  bool busyRetrieving = false;

  var messageScrollController = ScrollController();

  bool meAdmin = false;
  Map<String, bool> broAdminStatus = {};
  Map<String, bool> broAddedStatus = {};

  @override
  void initState() {
    super.initState();
    print("init chat");
    chat = widget.chat;
    storage = Storage();
    socketServices.checkConnection();
    socketServices.addListener(socketListener);
    messagingChangeNotifier.addListener(socketListener);

    notificationController = NotificationController();
    notificationController.addListener(notificationListener);

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
      retrieveData();
    });
  }

  notificationListener() {
    print("chat notification listener ${notificationController.navigateChat}  $mounted");
    if (mounted) {
      if (notificationController.navigateChat) {
        notificationController.navigateChat = false;
        int chatId = notificationController.navigateChatId;
        storage.fetchBroup(chatId).then((broup) {
          if (broup != null) {
            notificationController.navigateChat = false;
            notificationController.navigateChatId = -1;

            print("navigating to chat???");
            if (broup.broupId != chat.broupId) {
              print("changing chat object");
              chat = broup;
              retrieveData();
              messagingChangeNotifier.setBroupId(chat.getBroupId());
              setState(() {});
            }
          }
        });
      }
    }
  }

  checkIsAdmin() {
    for (Bro bro in chat.getBroupBros()) {
      broAdminStatus[bro.id.toString()] = false;
      broAddedStatus[bro.id.toString()] = false;
    }
    meAdmin = false;
    for (int adminId in chat.getAdminIds()) {
      if (adminId == settings.getMe()!.getId()) {
        meAdmin = true;
      }
      for (Bro bro in chat.getBroupBros()) {
        if (bro.id == adminId) {
          broAdminStatus[bro.id.toString()] = true;
        }
      }
    }
    for (Broup broup in settings.getMe()!.broups) {
      if (broup.private) {
        for (int broId in broup.getBroIds()) {
          if (broId != settings.getMe()!.getId()) {
            if (broAddedStatus.containsKey(broId.toString())) {
              broAddedStatus[broId.toString()] = true;
            }
          }
        }
      }
    }
  }

  retrieveData() {
    setState(() {
      isLoadingBros = true;
      isLoadingMessages = true;
    });
    getBroupUpdate(chat, storage).then((value) {
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
      print("chat id: ${chat.broupId}");
      Me? me = settings.getMe();
      print("me: $me");
      getBros(chat, storage, settings.getMe()!).then((value) {
        checkIsAdmin();
        setState(() {
          isLoadingBros = false;
        });
      });
    });
  }

  socketListener() {
    checkIsAdmin();
    setState(() {});
  }

  broHandling(int delta, int addBroId) {
    if (delta == 1) {
      // Message the bro
      Me? me = settings.getMe();
      if (me != null ) {
        for (Broup broup in me.broups) {
          if (broup.private) {
            for (int broId in broup.getBroIds()) {
              if (broId == addBroId) {
                // We are already in the chat window.
                // We attempt to transfer the correct data here.
                chat = broup;
                retrieveData();
                messagingChangeNotifier.setBroupId(chat.getBroupId());
                setState(() {});
              }
            }
          }
        }
      }
    } else if (delta == 2) {
      // Add the bro
      AuthServiceSocial().addNewBro(addBroId).then((value) {
        if (value) {
          print("we have added a new bro :)");
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage("Bro contact already in Bro list!");
        }
      });
    } else if (delta == 4) {
      AuthServiceSocial().makeBroAdmin(chat.broupId, addBroId).then((value) {
        if (value) {
          setState(() {
            chat.addAdminId(addBroId);
            checkIsAdmin();
          });
        }
      });
    } else if (delta == 5) {
      AuthServiceSocial().dismissBroAdmin(chat.broupId, addBroId).then((value) {
        if (value) {
          setState(() {
            chat.removeAdminId(addBroId);
            checkIsAdmin();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(socketListener);
    messagingChangeNotifier.removeListener(socketListener);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    super.dispose();
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
        chat.messages.insert(0, mes);
      });
      String? messageData = null;
      AuthServiceSocial().sendMessage(chat.getBroupId(), message, textMessage, messageData).then((value) {
        if (value) {
          // message send
        } else {
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          setState(() {
            chat.messages.removeAt(0);
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

  Widget messageList() {
    return chat.messages.isNotEmpty
        ? ListView.builder(
            itemCount: chat.messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              if (chat.private) {
                return BroMessageTile(
                    key: UniqueKey(),
                    message: chat.messages[index],
                    myMessage: chat.messages[index].senderId == settings.getMe()!.getId());
              } else {
                return BroupMessageTile(
                    key: UniqueKey(),
                    message: chat.messages[index],
                    senderName: getSender(chat.messages[index].senderId),
                    senderId: chat.messages[index].senderId,
                    broAdded: getIsAdded(chat.messages[index].senderId),
                    broAdmin: getIsAdmin(chat.messages[index].senderId),
                    myMessage: chat.messages[index].senderId ==
                        settings.getMe()!.getId(),
                    userAdmin: meAdmin,
                    broHandling: broHandling);
              }
            })
        : Container();
  }

  bool getIsAdded(int senderId) {
    if (broAddedStatus[senderId.toString()] != null) {
      return broAddedStatus[senderId.toString()]!;
    }
    return false;
  }

  bool getIsAdmin(int senderId) {
    if (broAdminStatus[senderId.toString()] != null) {
      return broAdminStatus[senderId.toString()]!;
    }
    return false;
  }

  String getSender(int senderId) {
    String broName = "";
    for (Bro bro in chat.broupBros) {
      if (bro.id == senderId) {
        return bro.getFullName();
      }
    }
    return broName;
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
      navigateToHome(context, settings);
    }
  }

  goToChatDetails() {
    messagingChangeNotifier.setBroupId(-1);
    settings.doneRoutes.add(routes.ChatDetailsRoute);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatDetails(key: UniqueKey(), chat: chat))).then((value) {
                  // It returned from the chat details. It's possible that
                  // we changed the chat, in this case we update this screen.
                  if (value is Broup) {
                    chat = value;
                    retrieveData();
                  }
                  messagingChangeNotifier.setBroupId(chat.getBroupId());
                  // If we go back here we want to re-render the chat
                  print("got back from chat details");
                  setState(() {});
    });
  }

  PreferredSize appBarChat() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Ink(
        color: chat.getColor(),
        child: InkWell(
          onTap: () {
            goToChatDetails();
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
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        goToChatDetails();
        break;
      case 3:
        navigateToHome(context, settings);
        break;
    }
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
                                    if (chat.isRemoved()) {
                                      return "You're no longer a participant in this Broup";
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
              !showEmojiKeyboard ? SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ) : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                  emojiController: broMessageController,
                  emojiKeyboardHeight: 400,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

