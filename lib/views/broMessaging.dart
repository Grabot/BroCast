import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/getMessages.dart';
import 'package:brocast/services/sendMessage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broHome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    getMessages();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
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
            setState(() {
              messages = val;
            });
          } else {
            ShowToastComponent.showDialog(val.toString(), context);
          }
        });
      }
    });
  }

  sendMessage() {
    if (formKey.currentState.validate()) {
      String message = broMessageController.text;
      HelperFunction.getBroToken().then((val) {
        if (val == null) {
          print("no token yet, this is not really possible");
        } else {
          send.sendMessage(val, widget.bro.id, message).then((val) {
            if (val.toString() != "an unknown error has occurred") {
              // When the message is send, then we retrieve all the messages again.
              getMessages();
            }
          });
        }
      });
    }
  }

  Widget messageList() {
    return messages.isNotEmpty ?
    ListView.builder(
        itemCount: messages.length,
        shrinkWrap: true,
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
        child: Stack(
          children: [
            messageList(),
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
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //     builder: (context) => BroMessaging(bro: bro)
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new Material(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              margin: EdgeInsets.symmetric(vertical: 8),
              width: MediaQuery.of(context).size.width,
              alignment: myMessage ? Alignment.centerRight : Alignment.centerLeft,
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
                child: Text(message.body, style: simpleTextStyle()),
              ),
            ),
          ),
          color: Colors.transparent,
        )
    );
  }
}
