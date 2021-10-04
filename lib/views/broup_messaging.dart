import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/get_messages.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'bro_chat_details.dart';
import 'bro_messaging.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';

class BroupMessaging extends StatefulWidget {
  final Chat chat;

  BroupMessaging({Key key, this.chat}) : super(key: key);

  @override
  _BroupMessagingState createState() => _BroupMessagingState();
}

class _BroupMessagingState extends State<BroupMessaging>
    with WidgetsBindingObserver {
  bool isLoading;
  GetMessages get = new GetMessages();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;
  bool showNotification = true;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  // SocketServices socket;
  List<Message> messages = [];

  Chat chat;

  int amountViewed;
  @override
  void initState() {
    super.initState();
    chat = widget.chat;

    isLoading = false;
    amountViewed = 1;
    getMessages(amountViewed);
    if (chat.chatColor == null) {
      // It was opened via a notification and we don't have the whole object.
      // We retrieve it now
      GetChat getChat = new GetChat();
      getChat.getChat(Settings.instance.getBroId(), chat.id).then((value) {
        if (value != "an unknown error has occurred") {
          setState(() {
            chat = value;
          });
        }
      });
    }
    NotificationService.instance.setScreen(this);
    // TODO: @SKools add the broup functionality
    // joinRoom(Settings.instance.getBroId(), chat.id);
    WidgetsBinding.instance.addObserver(this);
    BackButtonInterceptor.add(myInterceptor);

    messageScrollController.addListener(() {
      if (messageScrollController.position.atEdge) {
        if (messageScrollController.position.pixels != 0) {
          getMessages(amountViewed);
        }
      }
    });
  }


  joinRoom(int broId, int brosBroId) {
    if (SocketServices.instance.socket.connected) {
      SocketServices.instance.socket
          .on('message_event_send', (data) => messageReceived(data));
      SocketServices.instance.socket
          .on('message_event_send_solo', (data) => messageReceivedSolo(data));
      SocketServices.instance.socket
          .on('message_event_read', (data) => messageRead(data));
      SocketServices.instance.socket.emit(
        "join",
        {"bro_id": broId, "bros_bro_id": brosBroId},
      );
    }
  }

  messageReceivedSolo(var data) {
    if (mounted) {
      if (chat.id != data["sender_id"]) {
        for (BroBros br0 in BroList.instance.getBros()) {
          if (br0.id == data["sender_id"]) {
            if (showNotification) {
              NotificationService.instance
                  .showNotification(br0.id, br0.chatName, "", data["body"]);
            }
          }
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showNotification = true;
    } else {
      showNotification = false;
    }
  }

  messageReceived(var data) {
    if (mounted) {
      Message mes = new Message(
          data["id"],
          data["bro_bros_id"],
          data["sender_id"],
          data["broup_id"],
          data["body"],
          data["text_message"],
          data["timestamp"]);
      updateMessages(mes);
    }
  }

  leaveRoom() {
    if (mounted) {
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket
            .off('message_event_send', (data) => print(data));
        SocketServices.instance.socket
            .off('message_event_send_solo', (data) => print(data));
        SocketServices.instance.socket
            .off('message_event_read', (data) => print(data));
        SocketServices.instance.socket.emit(
          "leave",
          {"bro_id": Settings.instance.getBroId(), "bros_bro_id": chat.id},
        );
      }
    }
  }

  @override
  void dispose() {
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    // TODO: @SKools add the broup functionality
    // leaveRoom();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void goToDifferentChat(Chat chatBro) {
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroMessaging(chat: chatBro)));
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  getMessages(int page) {
    setState(() {
      isLoading = true;
    });
    get.getMessagesBroup(Settings.instance.getToken(), chat.id, page).then((val) {
      if (!(val is String)) {
        List<Message> messes = val;
        if (messes.length != 0) {
          setState(() {
            mergeMessages(messes);
            setDateTiles();
          });
          amountViewed += 1;
        }
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  mergeMessages(List<Message> newMessages) {
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

  setDateTiles() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    Message messageFirst = this.messages.first;
    DateTime dayFirst = DateTime(messageFirst.timestamp.year,
        messageFirst.timestamp.month, messageFirst.timestamp.day);
    String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

    String timeMessageFirst = DateFormat.yMMMMd('en_US').format(dayFirst);
    if (dayFirst == today) {
      timeMessageFirst = "Today";
    }
    if (dayFirst == yesterday) {
      timeMessageFirst = "Yesterday";
    }

    Message timeMessage = new Message(0, 0, 0, 0, timeMessageFirst, null, null);
    for (int i = 0; i < this.messages.length; i++) {
      DateTime current = this.messages[i].timestamp;
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
        timeMessage = new Message(0, 0, 0, 0, timeMessageTile, null, null);
      }
    }
    this.messages.insert(this.messages.length, timeMessage);
  }

  updateDateTiles(Message message) {
    // If the day tiles need to be updated after sending a message it will be the today tile.
    if (this.messages.length == 0) {
      this.messages.insert(0, new Message(0, 0, 0, 0, "Today", null, null));
    } else {
      Message messageFirst = this.messages.first;
      DateTime dayFirst = DateTime(messageFirst.timestamp.year,
          messageFirst.timestamp.month, messageFirst.timestamp.day);
      String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

      DateTime current = message.timestamp;
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);

        Message timeMessage = new Message(0, 0, 0, 0, "Today", null, null);
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
    if (formKey.currentState.validate()) {
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
      Message mes =
          new Message(-1, 0, Settings.instance.getBroId(), chat.id, message, textMessage, timestampString);
      setState(() {
        this.messages.insert(0, mes);
      });
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket.emit(
          "message_broup",
          {
            "bro_id": Settings.instance.getBroId(),
            "broup_id": chat.id,
            "message": message,
            "text_message": textMessage
          },
        );
      }
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
    if (message.senderId == Settings.instance.getBroId()) {
      // We added it immediately as a placeholder.
      // When we get it from the server we add it for real and remove the placeholder
      this.messages.removeAt(0);
    } else {
      // If we didn't send this message it is from the other person.
      // We send a response, indicating that we read the messages
      if (SocketServices.instance.socket.connected) {
        SocketServices.instance.socket.emit(
          "message_read",
          {"bro_id": Settings.instance.getBroId(), "bros_bro_id": chat.id},
        );
      }
    }
    updateDateTiles(message);
    setState(() {
      this.messages.insert(0, message);
    });
  }

  messageRead(var data) {
    if (mounted) {
      for (Message message in this.messages) {
        message.isRead = true;
      }
      setState(() {
        this.messages = this.messages;
      });
    }
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
                  message: messages[index],
                  myMessage: messages[index].senderId == Settings.instance.getBroId());
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
          context, MaterialPageRoute(builder: (context) => BroCastHome()));
    }
  }

  Widget appBarChat() {
    return AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: getTextColor(chat.chatColor)),
            onPressed: () {
              backButtonFunctionality();
            }),
        backgroundColor:
            chat.chatColor != null ? chat.chatColor : Color(0xff145C9E),
        title: Container(
            alignment: Alignment.centerLeft,
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BroChatDetails(chat: chat)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat.chatName,
                        style: TextStyle(
                            color: getTextColor(chat.chatColor), fontSize: 20)),
                    chat.chatDescription != ""
                        ? Text(chat.chatDescription,
                            style: TextStyle(
                                color: getTextColor(chat.chatColor),
                                fontSize: 12))
                        : Container(),
                  ],
                ))),
        actions: [
          PopupMenuButton<int>(
              onSelected: (item) => onSelectChat(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Profile")),
                    PopupMenuItem<int>(value: 1, child: Text("Settings")),
                    PopupMenuItem<int>(value: 2, child: Text("Chat details")),
                  ])
        ]);
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroProfile()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BroSettings()));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroChatDetails(chat: chat)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: appBarChat(),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    messageList(),
                    isLoading? Center(
                        child: Container(child: CircularProgressIndicator()
                        )
                    ) : Container()
                  ]
                )
              ),
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
                                    if (val.isEmpty || val.trimRight().isEmpty) {
                                      return "Can't send an empty message";
                                    }
                                    if (chat.blocked) {
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
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none),
                                  readOnly: true,
                                  showCursor: true,
                                ),
                              ),
                            ),
                          ),
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
                                            hintStyle:
                                                TextStyle(color: Colors.white54),
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
                  bromotionController: broMessageController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: Settings.instance.getEmojiKeyboardDarkMode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final Message message;
  final bool myMessage;

  MessageTile({Key key, this.message, this.myMessage}) : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  selectMessage(BuildContext context) {
    if (widget.message.textMessage.isNotEmpty) {
      setState(() {
        widget.message.clicked = !widget.message.clicked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.timestamp == null
        ? // If the timestamp is null it is a date tile.
        Row(
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: widget.myMessage ?
                            widget.message.textMessage.isEmpty ||
                                widget.message.clicked ? Color(0xFF009E00)
                                : Colors.yellow :
                            widget.message.textMessage.isEmpty ||
                                widget.message.clicked ? Color(0xFF0060BB)
                                : Colors.yellow,
                            width: 2,
                        ),
                        color: widget.myMessage
                            ?  Color(0xFF009E00)
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
                    child: Column(
                      children: [
                        widget.message.clicked
                            ? Text(widget.message.textMessage,
                                style: simpleTextStyle())
                            : Text(widget.message.body,
                                style: simpleTextStyle()),
                      ],
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
                                .format(widget.message.timestamp),
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          widget.myMessage
                              ? widget.message.id != 0
                                  ? WidgetSpan(
                                      child: Icon(Icons.done_all,
                                          color: widget.message.isRead
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
}
