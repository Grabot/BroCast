import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/get_messages.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/notification_util.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'package:camera/camera.dart';
import '../services/auth.dart';
import 'bro_chat_details.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';
import 'camera_page.dart';

class BroMessaging extends StatefulWidget {
  final BroBros chat;

  BroMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {
  bool isLoading = false;
  GetMessages get = new GetMessages();
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  BroList broList = BroList();
  GetChat getChat = new GetChat();
  NotificationUtil notificationUtil = NotificationUtil();

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

  List<Message> messages = [];

  late BroBros chat;
  late Storage storage;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    notificationUtil.currentChat(chat.id, 0);
    storage = Storage();
    socketServices.checkConnection();
    socketServices.addListener(socketListener);

    storage.selectChat(chat.id.toString(), chat.broup.toString()).then((value) {
      chat = value as BroBros;
      if (broList.bros.isEmpty) {
        broList.fillBrosFromDB();
      } else {
        broList.updateChat(chat);
      }
      storage.updateChat(chat).then((value) {});

      // We will assume that, either via notification or just opening the chat,
      // the user data is correctly set
      getMessages(amountViewed);
      initBroMessagingSocket(settings.getBroId(), chat.id);
    });

    // We retrieved the chat locally, but we will also get it from the server
    // If anything has changed, we can update it locally
    getChat.getChat(settings.getBroId(), chat.id).then((value) {
      if (value is BroBros) {
        chat = value;
        chat.unreadMessages = 0;
        if (broList.bros.isEmpty) {
          broList.fillBrosFromDB();
        } else {
          broList.updateChat(chat);
        }
        storage.updateChat(chat).then((value) {});
        setState(() {});
      }
    });

    BackButtonInterceptor.add(myInterceptor);

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
  }

  initBroMessagingSocket(int broId, int brosBroId) {
    socketServices.socket.emit(
      "join",
      {"bro_id": broId, "bros_bro_id": brosBroId},
    );
    socketServices.socket
        .on('message_event_send', (data) => messageReceived(data));
    socketServices.socket.on('message_event_read', (data) => messageRead(data));
  }

  socketListener() {
    // There was some update to the bro list.
    // Check the list and see if the change was to this chat object.
    for (Chat ch4t in broList.getBros()) {
      if (!ch4t.isBroup()) {
        if (ch4t.id == chat.id) {
          // This is the chat object of the current chat.
          // If either the name colour has changed. We want to update the screen
          // We know if it gets here that it is a BroBros object and that
          // it is the same BroBros object as the current open chat
          setState(() {
            chat = ch4t as BroBros;
          });
        }
      }
    }
  }

  messageReceived(var data) {
    Message mes = new Message(
        data["id"],
        data["sender_id"],
        data["body"],
        data["text_message"],
        data["timestamp"],
        data["data"],
        data["info"] ? 1 : 0,
        chat.id,
        0);
    updateMessages(mes);
  }

  leaveRoom() {
    socketServices.socket.emit(
      "leave",
      {"bro_id": settings.getBroId(), "bros_bro_id": chat.id},
    );
  }

  @override
  void dispose() {
    notificationUtil.clearChat();
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    leaveRoom();
    socketServices.socket.off('message_event_send');
    socketServices.socket.off('message_event_read');
    socketServices.removeListener(socketListener);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    if (broList.bros.isNotEmpty) {
      chat.unreadMessages = 0;
      broList.updateChat(chat);
    }
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
    List<Message> messagesServer = [];
    List<Message> messagesDB = [];
    bool gotServer = false;
    bool gotLocalDB = false;
    // get messages from the server
    get.getMessages(settings.getToken(), chat.id).then((val) {
      if (!(val is String)) {
        gotServer = true;
        List<Message> messes = val;
        if (messes.length != 0) {
          messagesServer = messes;
        }
        storeMessages(messes);
      } else {
        gotServer = false;
        // token validation probably failed, log in again
        storage.selectUser().then((user) async {
          if (user != null) {
            Auth auth = Auth();
            auth.signInUser(user).then((value) {
              if (value) {
                // If the user logged in again we will retrieve messages again.
                getMessages(page);
              }
            });
          }
        });
      }

      if (gotLocalDB && gotServer) {
        mergeMessages(messagesServer + messagesDB);
        // Set date tiles, but only if all the messages are retrieved
        setState(() {
          if (this.messages.length != 0) {
            setDateTiles();
          }
        });
        chat.unreadMessages = 0;
      }
      if (gotServer) {
        socketServices.socket.emit(
          "message_read",
          {"bro_id": settings.getBroId(), "bros_bro_id": chat.id},
        );
      }
      setState(() {
        isLoading = false;
      });
    });
    // But also load what you have from your local database
    storage.fetchAllMessages(chat.id, 0, 0).then((val) {
      // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
      if (val.length != 50) {
        allMessagesDBRetrieved = true;
      }
      List<Message> messes = val;
      if (messes.length != 0) {
        messagesDB = messes;
      }
      gotLocalDB = true;
      if (gotLocalDB && gotServer) {
        mergeMessages(messagesServer + messagesDB);
        // Set date tiles, but only if all the messages are retrieved
        setState(() {
          if (this.messages.length != 0) {
            setDateTiles();
          }
        });
        chat.unreadMessages = 0;
      }
    });
  }

  fetchExtraMessages(int offSet) {
    storage.fetchAllMessages(chat.id, 0, offSet).then((val) {
      // Limit set to 50. If it retrieves less it means that it can't and all the messages have been retrieved.
      if (val.length != 50) {
        allMessagesDBRetrieved = true;
      }
      if (val.length != 0) {
        mergeMessages(val);
        // Set date tiles, but only if all the messages are retrieved
        setState(() {
          if (this.messages.length != 0) {
            setDateTiles();
          }
        });
      }
      busyRetrieving = false;
    });
  }

  storeMessages(List<Message> messages) {
    for (Message message in messages) {
      if (message.id > 0) {
        storage.addMessage(message).then((value) {});
      }
    }
  }

  mergeMessages(List<Message> incomingMessages) {
    List<Message> newMessages = removeDuplicates(incomingMessages);
    if (this.messages.length != 0) {
      int lastId = this.messages[this.messages.length - 1].id;
      if (lastId == 0) {
        lastId = this.messages[this.messages.length - 2].id;
      }
      if (lastId <= newMessages[0].id) {
        newMessages = newMessages.where((x) => x.id < lastId).toList();
      }
      this.messages = this.messages.where((x) => x.id != 0).toList();
    }
    this.messages.addAll(newMessages);
    this.messages.sort((b, a) => a.timestamp.compareTo(b.timestamp));
  }

  int getBroBrosId() {
    return chat.id;
  }

  List<Message> removeDuplicates(List<Message> newMessages) {
    List<Message> noDuplicates = [];
    for (Message message in newMessages) {
      bool notAdded = true;
      for (Message messageNoDuplicate in noDuplicates) {
        if (message.id == messageNoDuplicate.id) {
          notAdded = false;
        }
      }
      if (notAdded) {
        noDuplicates.add(message);
      }
    }
    return noDuplicates;
  }

  setDateTiles() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    Message messageFirst = this.messages.first;
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
        1,
        chat.id,
        0
    );
    for (int i = 0; i < this.messages.length; i++) {
      DateTime current = this.messages[i].getTimeStamp();
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
        this.messages.insert(i, timeMessage);
        timeMessage = new Message(
            0,
            0,
            timeMessageTile,
            "",
            DateTime.now().toUtc().toString(),
            null,
            1,
            chat.id,
            0
        );
      }
    }
    this.messages.insert(this.messages.length, timeMessage);
  }

  updateDateTiles(Message message) {
    // If the day tiles need to be updated after sending a message it will be the today tile.
    if (this.messages.length == 0) {
      Message timeMessage = new Message(
          0,
          0,
          "Today",
          "",
          DateTime.now().toUtc().toString(),
          null,
          1,
          chat.id,
          0
      );
      this.messages.insert(0, timeMessage);
    } else {
      Message messageFirst = this.messages.first;
      DateTime dayFirst = DateTime(messageFirst.getTimeStamp().year,
          messageFirst.getTimeStamp().month, messageFirst.getTimeStamp().day);
      String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

      DateTime current = message.getTimeStamp();
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

        Message timeMessage = new Message(
            0,
            0,
            "Today",
            "",
            DateTime.now().toUtc().toString(),
            null,
            1,
            chat.id,
            0
        );
        this.messages.insert(0, timeMessage);
      }
    }
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
          settings.getBroId(),
          message,
          textMessage,
          DateTime.now().toUtc().toString(),
          null,
          0,
          chat.id,
          0
      );
      setState(() {
        this.messages.insert(0, mes);
      });
      socketServices.socket.emit(
        "message",
        {
          "bro_id": settings.getBroId(),
          "bros_bro_id": chat.id,
          "message": message,
          "text_message": textMessage
        },
      );
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

  updateMessages(Message message) {
    if (!message.isInformation() && message.senderId == settings.getBroId() && message.data == null) {
      // We added it immediately as a placeholder.
      // When we get it from the server we add it for real and remove the placeholder
      this.messages.removeAt(0);
    }
    socketServices.socket.emit(
      "message_read",
      {"bro_id": settings.getBroId(), "bros_bro_id": chat.id},
    );
    updateDateTiles(message);
    setState(() {
      this.messages.insert(0, message);
    });
    storage.addMessage(message).then((value) {
      // stored the message
    });
    if (!message.isInformation()) {
      updateUserActivity(message.timestamp);
    }
  }

  updateUserActivity(String timestamp) {
    storage.updateChat(chat).then((value) {
      // chat updated
    });
    chat.lastActivity = timestamp;
    broList.updateChat(chat);
  }

  messageRead(var data) {
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

  var messageScrollController = ScrollController();

  Widget messageList() {
    return messages.isNotEmpty
        ? ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              return MessageTile(
                  key: UniqueKey(),
                  message: messages[index],
                  myMessage: messages[index].senderId == settings.getBroId());
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroCastHome(key: UniqueKey())));
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BroChatDetails(key: UniqueKey(), chat: chat)));
              },
              child: Container(
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  child: Text(chat.getBroNameOrAlias(),
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BroChatDetails(key: UniqueKey(), chat: chat)));
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
                            await availableCameras().then((value) => Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => CameraPage(
                                    chat: chat,
                                    cameras: value
                                ))));
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
                emotionController: broMessageController,
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

class MessageTile extends StatefulWidget {
  final Message message;
  final bool myMessage;

  MessageTile(
      {required Key key, required this.message, required this.myMessage})
      : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

  var _tapPosition;
  bool isImage = false;

  selectMessage(BuildContext context) {
    if (widget.message.textMessage.isNotEmpty || isImage) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
    }
  }

  Image? test;

  @override
  void initState() {
    super.initState();
    if (widget.message.data != null && widget.message.data != "") {
      Uint8List decoded = base64.decode(widget.message.data!);
      test = Image.memory(decoded);
      // test = Image.memory(decoded, fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 100);
      isImage = true;
    }
  }

  Color getBorderColour() {
    // First we set the border to be the colour of the message
    // Which is the colour for a normal plain message without content
    Color borderColour = widget.myMessage
        ? Color(0xFF009E00)
        : Color(0xFF0060BB);
    // We check if there is a message content
    if (widget.message.textMessage.isNotEmpty) {
      // If this is the case the border should be yellow, but only if it's not clicked
      if (!widget.message.clicked) {
        borderColour = Colors.yellow;
      }
    }
    // Now we check if it's maybe a data message with an image!
    if (isImage) {
      if (!widget.message.clicked) {
        borderColour = Colors.red;
      }
    }
    return borderColour;
  }

  Widget getMessageContent() {
    // We show the normal body, unless it's clicked. Than we show the extra info
    if (widget.message.clicked) {
      // If it's clicked we show the extra text message or the image!
      if (isImage) {
        if (widget.message.textMessage.isNotEmpty) {
          return Column(
              children: [
                test!,
                Linkable(
                  text: widget.message.textMessage,
                  textColor: Colors.white,
                  linkColor: Colors.blue[200],
                  style: simpleTextStyle()
                )
              ]
          );
        } else {
          return test!;
        }
      } else {
        return Linkable(
            text: widget.message.textMessage,
            textColor: Colors.white,
            linkColor: Colors.blue[200],
            style: simpleTextStyle()
        );
      }
    } else {
      return Text(
          widget.message.body,
          style: simpleTextStyle());
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.isInformation()
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0x55D3D3D3),
                          const Color(0x55C0C0C0)
                        ]),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Text(widget.message.body, style: simpleTextStyle()))
              ])
        : Container(
            child: new Material(
            child: Column(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                margin: EdgeInsets.only(top: 12),
                width: MediaQuery.of(context).size.width,
                alignment: widget.myMessage
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: new InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(42),
                  ),
                  onTap: () {
                    selectMessage(context);
                  },
                  onLongPress: () {
                    if (isImage && widget.message.clicked) {
                      _showMessageDetailPopupMenu();
                    }
                  },
                  onTapDown: _storePosition,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: getBorderColour(),
                          width: 2,
                        ),
                        color: widget.myMessage
                            ? Color(0xFF009E00)
                            : Color(0xFF0060BB),
                        borderRadius: widget.myMessage
                            ? BorderRadius.only(
                                topLeft: Radius.circular(42),
                                topRight: Radius.circular(42),
                                bottomLeft: Radius.circular(42))
                            : BorderRadius.only(
                                topLeft: Radius.circular(42),
                                topRight: Radius.circular(42),
                                bottomRight: Radius.circular(42))),
                    child: Container(
                        child: getMessageContent()
                    ),
                  ),
                ),
              ),
              Container(
                child: Align(
                  alignment: widget.myMessage
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: DateFormat('HH:mm')
                                .format(widget.message.getTimeStamp()),
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          widget.myMessage
                              ? widget.message.id != -1
                                  ? WidgetSpan(
                                      child: Icon(Icons.done_all,
                                          color: widget.message.hasBeenRead()
                                              ? Colors.blue
                                              : Colors.white54,
                                          size: 18))
                                  : WidgetSpan(
                                      child: Icon(Icons.done,
                                          color: Colors.white54, size: 18))
                              : WidgetSpan(child: Container()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            color: Colors.transparent,
          ));
  }

  void _showMessageDetailPopupMenu() {
    final RenderBox overlay =
    Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
        context: context,
        items: [
          BroMessageDetailPopup(
              key: UniqueKey()
          )
        ],
        position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
            Offset.zero & overlay.size))
        .then((int? delta) {
          print("pressed? delta: $delta");
          if (delta == 1) {
            // Save the image!
            saveImageToGallery();
          }
      return;
    });
  }

  saveImageToGallery() async {
    // code for image storing
    Uint8List decoded = base64.decode(widget.message.data!);
    // First we save it to the local application folder
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String dir = appDocDirectory.path;

    String imageName = "brocast_" + DateTime.now().toUtc().toString();
    String fullPath = '$dir/$imageName.png';
    // We create the file once we have the full path
    File file = File(fullPath);
    // We store the image on the file
    await file.writeAsBytes(decoded);
    // We now save to image gallery
    await GallerySaver.saveImage(file.path, albumName: "Brocast").then((value) {
      // We have save the image to the gallery, remove it from the application folder
      file.delete();
      ShowToastComponent.showDialog("Image was saved!", context);
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

}

class BroMessageDetailPopup extends PopupMenuEntry<int> {

  BroMessageDetailPopup(
      {required Key key})
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  BroMessageDetailPopupState createState() => BroMessageDetailPopupState();

  @override
  double get height => 1;
}

class BroMessageDetailPopupState extends State<BroMessageDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

Widget getPopupItems(BuildContext context) {
  return Column(children: [
    Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonMessage(context);
          },
          child: Text(
            'Save image to gallery',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    )
  ]);
}
