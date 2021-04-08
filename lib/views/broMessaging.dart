import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/getMessages.dart';
import 'package:brocast/services/sendMessage.dart';
import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BroMessaging extends StatefulWidget {

  final Bro bro; // receives the value

  BroMessaging({ Key key, this.bro }): super(key: key);

  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {

  SendMessage send = new SendMessage();
  GetMessages get = new GetMessages();

  TextEditingController broMessageController = new TextEditingController();
  final formKey = GlobalKey<FormState>();

  SocketServices socketServices = new SocketServices();
  List<Message> messages = [];
  int broId;

  @override
  void initState() {
    super.initState();
    getMessages();
    HelperFunction.getBroId().then((val) {
      if (val == null) {
        print("no token yet, this is not really possible");
      } else {
        broId = val;
        socketServices.createSockConnection(broId, widget.bro.id, this);
      }
    });
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    socketServices.closeSockConnection();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroCastHome()
    ));
    return true;
  }

  getMessages() {
    HelperFunction.getBroToken().then((val) {
      if (val == null) {
        print("no token yet, this is not really possible");
      } else {
        get.getMessages(val, widget.bro.id).then((val) {
          if (!(val is String)) {
            List<Message> messes = val;
            setDateTiles(messes);
            setState(() {
              messages = messes;
            });
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
    Message timeMessage = new Message(0, 0, 0, 0, timeMessageFirst, null);
    for (int i = 0; i < messes.length; i++ ) {
      DateTime current = messes[i].timestamp;
      DateTime dayMessage = DateTime(current.year, current.month, current.day);
      String currentDayMessage = DateFormat.yMMMMd('en_US').format(dayMessage);

      if (chatTimeTile == null || chatTimeTile != currentDayMessage) {
        chatTimeTile = DateFormat.yMMMMd('en_US').format(dayMessage);
        print("time");
        print(chatTimeTile);
        String timeMessageTile = chatTimeTile;
        if (dayMessage == today) {
          timeMessageTile = "Today";
        }
        if (dayMessage == yesterday) {
          timeMessageTile = "Yesterday";
        }
        messes.insert(i, timeMessage);
        timeMessage = new Message(0, 0, 0, 0, timeMessageTile, null);
      }
    }
    messes.insert(messes.length, timeMessage);
  }

  sendMessage() {
    if (formKey.currentState.validate()) {
      String message = broMessageController.text;
      // We add the message already as being send.
      // If it is received we remove this message and show 'received'
      String timestampString = DateTime.now().toUtc().toString();
      if (timestampString.endsWith('Z')) {
        timestampString = timestampString.substring(0, timestampString.length - 1);
      }
      Message mes = new Message(0, 0, 0, widget.bro.id, message, timestampString);
      setState(() {
        this.messages.insert(0, mes);
      });
      socketServices.sendMessageSocket(broId, widget.bro.id, message);
      broMessageController.clear();
    }
  }

  updateMessages(Message message) {
    setState(() {
      this.messages.removeAt(0);
      this.messages.insert(0, message);
    });
  }

  Widget messageList() {
    return messages.isNotEmpty ?
    ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {
          return MessageTile(messages[index], messages[index].recipientId == widget.bro.id);
        }
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
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
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child:
                      Form(
                        key: formKey,
                        child: TextFormField(
                          validator: (val) {
                            return val.isEmpty
                                ? "Can't send an empty message"
                                : null;
                          },
                          controller: broMessageController,
                          style: TextStyle(
                              color: Colors.white
                          ),
                          decoration: InputDecoration(
                              hintText: "Message...",
                              hintStyle: TextStyle(
                                  color: Colors.white54
                              ),
                              border: InputBorder.none
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ]
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(10),
                          child: Image.asset("assets/images/brocast.png")
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final Message message;

  final bool myMessage;

  MessageTile(this.message, this.myMessage);

  selectMessage(BuildContext context) {
    print("message " + message.body + " is it send by me? " + myMessage.toString());
  }

  @override
  Widget build(BuildContext context) {
    return message.timestamp == null ?
    Container(
      child: Text(
          message.body,
          style: simpleTextStyle()
      )
    ) :
    Container(
        child: new Material(
          child: Column(
            children: [
              Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              margin: EdgeInsets.only(top: 12),
              width: MediaQuery.of(context).size.width,
              alignment: myMessage ? Alignment.bottomRight : Alignment.bottomLeft,
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
                      gradient: LinearGradient(
                          colors: myMessage ? [
                            const Color(0xAA007E00),
                            const Color(0xAA2A7512)
                          ] : [
                            const Color(0xAA007EF4),
                            const Color(0xAA2A75BC)
                          ]
                      ),
                      borderRadius: myMessage ?
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
                    Text(message.body, style: simpleTextStyle()),
                  ],
                  ),
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: myMessage ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: DateFormat('HH:mm').format(message.timestamp),
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12
                          ),
                        ),
                        myMessage ? WidgetSpan(
                          child: Icon(
                              Icons.done_all,
                              color: Colors.blue,
                              size: 18
                          ),
                        ) : WidgetSpan(child: Container()),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]),
          color: Colors.transparent,
        )
    );
  }
}
