import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro_bros.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/settings.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/get_messages.dart';
import 'package:brocast/services/send_message.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BroMessaging extends StatefulWidget {

  final BroBros broBros;

  BroMessaging({ Key key, this.broBros }): super(key: key);

  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {

  SendMessage send = new SendMessage();
  GetMessages get = new GetMessages();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  // SocketServices socket;
  List<Message> messages = [];
  int broId;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.setScreen(this);
    SocketServices.instance.setMessaging(this);
    getMessages();
    HelperFunction.getBroId().then((val) {
      if (val == null || val == -1) {
        print("no token yet, this is not really possible");
      } else {
        broId = val;
        SocketServices.instance.joinRoom(broId, widget.broBros.id);
      }
    });
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    SocketServices.instance.leaveRoom(broId, widget.broBros.id);
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void goToDifferentChat(Bro chatBro) {
    // TODO: @Skools change this to BroBros!
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //     builder: (context) => BroMessaging(broBros: chatBro)
    // ));
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => BroCastHome()
      ));
      return true;
    }
  }

  getMessages() {
    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        print("no token yet, this is not really possible");
      } else {
        get.getMessages(val, widget.broBros.id).then((val) {
          if (!(val is String)) {
            List<Message> messes = val;
            if (messes.length != 0) {
              setDateTiles(messes);
              setState(() {
                messages = messes;
              });
            }
          } else {
            ShowToastComponent.showDialog(val.toString(), context);
          }
        });
      }
    });
  }

  setDateTiles(List<Message> messes) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    Message messageFirst = messes.first;
    DateTime dayFirst = DateTime(messageFirst.timestamp.year, messageFirst.timestamp.month, messageFirst.timestamp.day);
    String chatTimeTile = DateFormat.yMMMMd('en_US').format(dayFirst);

    String timeMessageFirst = DateFormat.yMMMMd('en_US').format(dayFirst);
    if (dayFirst == today) {
      timeMessageFirst = "Today";
    }
    if (dayFirst == yesterday) {
      timeMessageFirst = "Yesterday";
    }

    Message timeMessage = new Message(0, 0, 0, 0, timeMessageFirst, null, null);
    for (int i = 0; i < messes.length; i++ ) {
      DateTime current = messes[i].timestamp;
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
        messes.insert(i, timeMessage);
        timeMessage = new Message(0, 0, 0, 0, timeMessageTile, null, null);
      }
    }
    messes.insert(messes.length, timeMessage);
  }

  updateDateTiles(Message message) {
    // If the day tiles need to be updated after sending a message it will be the today tile.
    if (this.messages.length == 0) {
      this.messages.insert(0, new Message(0, 0, 0, 0, "Today", null, null));
    } else {
      Message messageFirst = this.messages.first;
      DateTime dayFirst = DateTime(messageFirst.timestamp.year, messageFirst.timestamp.month, messageFirst.timestamp.day);
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

  sendMessage() {
    if (formKey.currentState.validate()) {
      String message = broMessageController.text;
      String textMessage = appendTextMessageController.text;
      // We add the message already as being send.
      // If it is received we remove this message and show 'received'
      String timestampString = DateTime.now().toUtc().toString();
      // The 'Z' indicates that it's UTC but we'll already add it in the message
      if (timestampString.endsWith('Z')) {
        timestampString = timestampString.substring(0, timestampString.length - 1);
      }
      Message mes = new Message(0, 0, 0, widget.broBros.id, message, textMessage, timestampString);
      setState(() {
        this.messages.insert(0, mes);
      });
      SocketServices.instance.sendMessageSocket(broId, widget.broBros.id, message, textMessage);
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
    if (message.recipientId == widget.broBros.id) {
      // We added it immediately as a placeholder.
      // When we get it from the server we add it for real and remove the placeholder
      this.messages.removeAt(0);
    } else {
      SocketServices.instance.messageReadUpdate(broId, widget.broBros.id);
    }
    updateDateTiles(message);
    setState(() {
      this.messages.insert(0, message);
    });
  }

  updateRead() {
    for (Message message in this.messages) {
      message.isRead = true;
    }
    setState(() {
      this.messages = this.messages;
    });
  }

  Widget messageList() {
    return messages.isNotEmpty ?
    ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {
          return MessageTile(message: messages[index], myMessage: messages[index].recipientId == widget.broBros.id);
        }
    ) : Container();
  }

  void onTapEmojiTextField() {
    if (!showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, true, "${widget.broBros.chatName}"),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: messageList()
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                      color: Color(0x36FFFFFF),
                      borderRadius: BorderRadius.circular(35)
                  ),
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
                              color: Color(0x36FFFFFF),
                              borderRadius: BorderRadius.circular(35)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.text_snippet,
                            color: appendingMessage ? Colors.green : Colors.grey,
                          )
                        ),
                      ),
                      Expanded(
                        child:
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Form(
                            key: formKey,
                            child: TextFormField(
                              focusNode: focusEmojiTextField,
                              validator: (val) {
                                return val.isEmpty
                                    ? "Can't send an empty message"
                                    : null;
                              },
                              onTap: () {
                                onTapEmojiTextField();
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: broMessageController,
                              style: TextStyle(
                                  color: Colors.white
                              ),
                              decoration: InputDecoration(
                                  hintText: "Emoji message...",
                                  hintStyle: TextStyle(
                                      color: Colors.white54
                                  ),
                                  border: InputBorder.none
                              ),
                              readOnly: true,
                              showCursor: true,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Color(0x36FFFFFF),
                              borderRadius: BorderRadius.circular(35)
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                                Icons.send,
                            )
                        ),
                      )
                    ],
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
    );
  }
}

class MessageTile extends StatefulWidget {

  Message message;
  bool myMessage;

  MessageTile({
    Key key,
    this.message,
    this.myMessage
  }): super(key: key);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

  bool clicked = false;

  selectMessage(BuildContext context) {
    if (widget.message.textMessage.isNotEmpty) {
      setState(() {
        clicked = !clicked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.message.timestamp == null ? // If the timestamp is null it is a date tile.
    Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        const Color(0x55D3D3D3),
                        const Color(0x55C0C0C0)
                      ]
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              child: Text(
                  widget.message.body,
                  style: simpleTextStyle()
              )
          )
        ]
    ) :
    Container(
        child: new Material(
          child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  margin: EdgeInsets.only(top: 12),
                  width: MediaQuery.of(context).size.width,
                  alignment: widget.myMessage ? Alignment.bottomRight : Alignment.bottomLeft,
                  child: new InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(42),
                    ),
                    onTap: (){
                      selectMessage(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: widget.myMessage ?
                          widget.message.textMessage.isEmpty || clicked ? Color(0xAA009E00) : Color(
                              0xFF0ABB5A)
                              :
                          widget.message.textMessage.isEmpty || clicked ? Color(0xFF0060BB) : Color(
                              0xFF0A98BB),
                          borderRadius: widget.myMessage ?
                          BorderRadius.only(
                              topLeft: Radius.circular(42),
                              topRight: Radius.circular(42),
                              bottomLeft: Radius.circular(42)
                          ) :
                          BorderRadius.only(
                              topLeft: Radius.circular(42),
                              topRight: Radius.circular(42),
                              bottomRight: Radius.circular(42)
                          )
                      ),
                      child: Column(
                        children: [
                          clicked ? Text(widget.message.textMessage, style: simpleTextStyle()) : Text(widget.message.body, style: simpleTextStyle()),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Align(
                    alignment: widget.myMessage ? Alignment.bottomRight : Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat('HH:mm').format(widget.message.timestamp),
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12
                              ),
                            ),
                            widget.myMessage ?
                            widget.message.id != 0 ? WidgetSpan(
                                child: Icon(
                                    Icons.done_all,
                                    color: widget.message.isRead ? Colors.blue : Colors.white54,
                                    size: 18
                                )) : WidgetSpan(
                                child: Icon(
                                    Icons.done,
                                    color: Colors.white54,
                                    size: 18
                                )) : WidgetSpan(child: Container()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
          color: Colors.transparent,
        )
    );
  }
}
