import 'package:brocast/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BroMessaging extends StatefulWidget {
  @override
  _BroMessagingState createState() => _BroMessagingState();
}

class _BroMessagingState extends State<BroMessaging> {

  TextEditingController broMessageController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
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
                        )
                    ),
                    GestureDetector(
                      onTap: () {
                        print("tapped the send message button");
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
