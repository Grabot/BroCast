import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/chat.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/get_chat.dart';
import 'package:brocast/services/get_messages.dart';
import 'package:brocast/services/navigation_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/bro_list.dart';
import 'package:brocast/utils/locator.dart';
import 'package:brocast/utils/notification_util.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'package:path_provider/path_provider.dart';
import '../services/auth.dart';
import 'bro_profile.dart';
import 'bro_settings.dart';
import 'broup_details.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'package:camera/camera.dart';
import 'camera_page.dart';

class BroupMessaging extends StatefulWidget {
  final Broup chat;

  BroupMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _BroupMessagingState createState() => _BroupMessagingState();
}

class _BroupMessagingState extends State<BroupMessaging> {
  bool isLoading = false;
  GetMessages get = new GetMessages();
  GetChat getChat = new GetChat();
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  BroList broList = BroList();
  NotificationUtil notificationUtil = NotificationUtil();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  // SocketServices socket;
  List<Message> messages = [];

  late Broup chat;
  late Storage storage;

  int amountViewed = 0;
  bool allMessagesDBRetrieved = false;
  bool busyRetrieving = false;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    storage = Storage();
    notificationUtil.currentChat(chat.id, 1);
    socketServices.checkConnection();
    socketServices.addListener(socketListener);

    // Retrieve again from db to ensure up to date data.
    storage.selectChat(chat.id.toString(), chat.broup.toString()).then((value) {
      chat = value as Broup;
      if (broList.bros.isEmpty) {
        broList.fillBrosFromDB();
      } else {
        broList.updateChat(chat);
      }
      storage.updateChat(chat).then((value) {});
      storage.fetchAllBrosOfBroup(chat.id.toString()).then((broupBros) {
        broList.updateAliases(broupBros);
        chat.setBroupBros(broupBros);
      });

      storage.selectUser().then((user) async {
        if (user != null) {
          settings.setEmojiKeyboardDarkMode(user.getKeyboardDarkMode());
          settings.setBroId(user.id);
          settings.setBroName(user.broName);
          settings.setBromotion(user.bromotion);
          settings.setToken(user.token);

          getMessages(amountViewed);
          initBroupMessagingSocket();
        } else {
          // There is no user for some reason, go back to the home screen where the user will log in.
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BroCastHome(key: UniqueKey())));
        }
      });
    });

    // We retrieved the chat locally, but we will also get it from the server
    // If anything has changed, we can update it locally
    getChat.getBroup(settings.getBroId(), chat.id).then((value) {
      if (value is Broup) {
        chat.unreadMessages = 0;
        List<Bro> broupBros = [];
        if (value.participants.length != chat.participants.length) {
          // someone was added(removed( and you didn't get updated, add them now
          broList.chatChangedCheckForAdded(chat.id, value.getParticipants(),
              value.getAdmins(), [], broupBros);
          broList.chatCheckForDBRemoved(chat.id, value.getParticipants());
        } else {
          broupBros = chat.getBroupBros();
          broList.updateBroupBrosAdmins(broupBros, value.getAdmins());
        }
        chat = value;
        chat.setBroupBros(broupBros);
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

  void initBroupMessagingSocket() {
    if (!chat.hasLeft() && !chat.isBlocked()) {
      socketServices.socket.emit(
        "join_broup",
        {"bro_id": settings.getBroId(), "broup_id": chat.id},
      );
      socketServices.socket
          .on('message_event_send', (data) => messageReceived(data));
      socketServices.socket
          .on('message_event_read', (data) => messageRead(data));
    }
  }

  socketListener() {
    // There was some update to the bro list.
    // Check the list and see if the change was to this chat object.
    for (Chat ch4t in broList.getBros()) {
      if (ch4t.isBroup()) {
        if (ch4t.id == chat.id) {
          // This is the chat object of the current chat.
          // If either the name colour has changed. We want to update the screen
          // We know if it gets here that it is a BroBros object and that
          // it is the same BroBros object as the current open chat
          setState(() {
            chat = ch4t as Broup;
          });
          if (chat.hasLeft()) {
            leaveBroupSocket();
          }
        }
      }
    }
  }

  addNewBro(int addBroId) {
    socketServices.socket
        .on('message_event_add_bro_success', (data) => broWasAdded(data));
    socketServices.socket.on('message_event_add_bro_failed', (data) {
      broAddingFailed();
    });
    socketServices.socket.emit("message_event_add_bro",
        {"token": settings.getToken(), "bros_bro_id": addBroId});
  }

  broWasAdded(data) {
    BroBros broBros = new BroBros(
        data["bros_bro_id"],
        data["chat_name"],
        data["chat_description"],
        data["alias"],
        data["chat_colour"],
        data["unread_messages"],
        data["last_time_activity"],
        data["room_name"],
        data["blocked"] ? 1 : 0,
        data["mute"] ? 1 : 0,
        0);
    broList.addChat(broBros);
    storage.addChat(broBros).then((value) {
      broList.updateBroupBrosForBroBros(broBros);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroCastHome(key: UniqueKey())));
    });
  }

  broAddingFailed() {
    ShowToastComponent.showDialog(
        "Bro could not be added at this time", context);
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
        1);
    // it's possible that you are receiving the socket message after retrieving
    // it from the rest call from opening the chat.
    // So we will do a simple check if it's in the list
    bool added = false;
    for (Message message in this.messages) {
      if (message.id == mes.id) {
        added = true;
      }
    }
    if (!added) {
      updateMessages(mes);
    }
  }

  leaveBroupSocket() {
    socketServices.socket.emit(
      "leave_broup",
      {"bro_id": settings.getBroId(), "broup_id": chat.id},
    );

    socketServices.socket.off('message_event_add_bro_success');
    socketServices.socket.off('message_event_add_bro_failed');
    socketServices.socket.off('message_event_send');
    socketServices.socket.off('message_event_read');
  }

  @override
  void dispose() {
    if (broList.bros.isNotEmpty) {
      chat.unreadMessages = 0;
      broList.updateChat(chat);
    }
    notificationUtil.clearChat();
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(socketListener);
    leaveBroupSocket();
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
    bool gotServer = false;
    bool gotLocalDB = false;
    List<Message> messagesServer = [];
    List<Message> messagesDB = [];
    // get messages from the server
    if (!chat.hasLeft() && !chat.isBlocked()) {
      setState(() {
        isLoading = true;
      });
      get.getMessagesBroup(settings.getToken(), chat.id).then((val) {
        if (!(val is String)) {
          gotServer = true;
          List<Message> messes = val;
          if (messes.length != 0) {
            messagesServer = messes;
          }
          storeMessages(messes);
        } else {
          // token validation probably failed, log in again
          gotServer = false;
          storage.selectUser().then((user) async {
            if (user != null) {
              Auth auth = Auth();
              auth.signInUser(user).then((value) {
                if (value) {
                  // If the user logged in again we will retrieve messages again
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
            "message_read_broup",
            {"bro_id": settings.getBroId(), "broup_id": chat.id},
          );
        }
        setState(() {
          isLoading = false;
        });
      });
    } else {
      gotServer = true;
    }
    // But also load what you have from your local database
    storage.fetchAllMessages(chat.id, 1, 0).then((val) {
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
    storage.fetchAllMessages(chat.id, 1, offSet).then((val) {
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
      // If it is not yet in the db, we store it.
      // If it is in the db we don't do anything, the message won't change.
      if (message.id > 0) {
        storage.addMessage(message).then((value) {});
      }
    }
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
        1
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
            1
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
          1
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
            1
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

  sendMessageBroup() {
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
          timestampString,
          null,
          0,
          chat.id,
          1
      );
      setState(() {
        this.messages.insert(0, mes);
      });
      socketServices.socket.emit(
        "message_broup",
        {
          "bro_id": settings.getBroId(),
          "broup_id": chat.id,
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
      "message_read_broup",
      {"bro_id": settings.getBroId(), "broup_id": chat.id},
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
                  senderName: getSender(messages[index].senderId),
                  senderId: messages[index].senderId,
                  broAdded: getIsAdded(messages[index].senderId),
                  myMessage: messages[index].senderId == settings.getBroId(),
                  addNewBro: addNewBro);
            })
        : Container();
  }

  bool getIsAdded(int senderId) {
    for (Chat bro in broList.getBros()) {
      if (!bro.isBroup()) {
        if (bro.id == senderId) {
          return true;
        }
      }
    }
    return false;
  }

  String getSender(int senderId) {
    String broName = "";
    for (Chat bro in broList.getBros()) {
      if (!bro.isBroup()) {
        if (bro.id == senderId) {
          return bro.getBroNameOrAlias();
        }
      }
    }
    for (Bro bro in chat.getBroupBros()) {
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
                            BroupDetails(key: UniqueKey(), chat: chat)));
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
                      PopupMenuItem<int>(
                          value: 2, child: Text("Broup details")),
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
                    BroupDetails(key: UniqueKey(), chat: chat)));
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
  final String senderName;
  final int senderId;
  final bool broAdded;
  final bool myMessage;
  final void Function(int) addNewBro;

  MessageTile(
      {required Key key,
      required this.message,
      required this.senderName,
      required this.senderId,
      required this.broAdded,
      required this.myMessage,
      required this.addNewBro})
      : super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  var _tapPosition;
  bool isImage = false;

  SocketServices socketServices = SocketServices();

  final NavigationService _navigationService = locator<NavigationService>();

  Settings settings = Settings();

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
            margin: EdgeInsets.only(top: 12),
            child: new Material(
              child: Column(children: [
                widget.myMessage
                    ? Container()
                    : Container(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.senderName,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  width: MediaQuery.of(context).size.width,
                  alignment: widget.myMessage
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft,
                  child: new InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(42),
                    ),
                    onLongPress: _showMessageDetailPopupMenu,
                    onTapDown: _storePosition,
                    onTap: () {
                      selectMessage(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12),
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
    // Only show the option to save the image if the message is clicked.
    bool imageShowing = isImage && widget.message.clicked;
    if (!widget.myMessage || imageShowing) {
      final RenderBox overlay =
          Overlay.of(context)!.context.findRenderObject() as RenderBox;

      showMenu(
              context: context,
              items: [
                MessageDetailPopup(
                    key: UniqueKey(),
                    myMessage: widget.myMessage,
                    sender: widget.senderName,
                    broAdded: widget.broAdded,
                    imageShowing: imageShowing
                )
              ],
              position: RelativeRect.fromRect(_tapPosition & const Size(40, 40),
                  Offset.zero & overlay.size))
          .then((int? delta) {
        if (delta == 1) {
          bool broTransition = false;
          BroList broList = BroList();
          for (Chat br0 in broList.getBros()) {
            if (!br0.isBroup()) {
              if (br0.id == widget.senderId) {
                broTransition = true;
                _navigationService.navigateTo(routes.BroRoute, arguments: br0);
              }
            }
          }
          if (!broTransition) {
            _navigationService.navigateTo(routes.HomeRoute);
          }
        } else if (delta == 2) {
          widget.addNewBro(widget.senderId);
        } else if (delta == 3) {
          // Save the image!
          saveImageToGallery();
        }
        return;
      });
    }
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

class MessageDetailPopup extends PopupMenuEntry<int> {
  final String sender;
  final bool myMessage;
  final bool broAdded;
  final bool imageShowing;

  MessageDetailPopup(
      {
        required Key key,
        required this.myMessage,
        required this.sender,
        required this.broAdded,
        required this.imageShowing
      })
      : super(key: key);

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  MessageDetailPopupState createState() => MessageDetailPopupState();

  @override
  double get height => 1;
}

class MessageDetailPopupState extends State<MessageDetailPopup> {
  @override
  Widget build(BuildContext context) {
    return getPopupItems(context, widget.sender, widget.broAdded, widget.imageShowing, widget.myMessage);
  }
}

void buttonMessage(BuildContext context) {
  Navigator.pop<int>(context, 1);
}

void buttonAdd(BuildContext context) {
  Navigator.pop<int>(context, 2);
}

void buttonSaveImage(BuildContext context) {
  Navigator.pop<int>(context, 3);
}

Widget getPopupItems(BuildContext context, String sender, bool broAdded, bool imageShowing, bool myMessage) {
  return Column(children: [
    broAdded && !myMessage
        ? Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: () {
                  buttonMessage(context);
                },
                child: Text(
                  'Message $sender',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                )),
          )
        : Container(),
    !broAdded && !myMessage
        ? Container(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: () {
                  buttonAdd(context);
                },
                child: Text(
                  'Add $sender',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                )),
          ) : Container(),
    imageShowing ? Container(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: () {
            buttonSaveImage(context);
          },
          child: Text(
            'Save image to gallery',
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.black, fontSize: 14),
          )),
    ) : Container()
  ]);
}
