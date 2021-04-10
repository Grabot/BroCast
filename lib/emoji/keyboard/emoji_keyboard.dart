import 'emojis/smileys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'emoji_key.dart';

class EmojiKeyboard extends StatefulWidget {
  EmojiKeyboard({
    Key key
  }) : super(key: key);

  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<EmojiKeyboard> {

  List smileys;

  @override
  void initState() {
    smileys = smileyList;
    super.initState();
  }

  Expanded buildKeyboard() {
    return Expanded(
      child: ListView.builder(
        itemCount: smileyList.length,
        itemBuilder: (BuildContext cont, int index) {
          return new Row(
            children: [
              (index*8) < smileyList.length ? EmojiKey(emoji: smileyList[index * 8]) : Container(),
              (index*8+1) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+1]) : Container(),
              (index*8+2) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+2]) : Container(),
              (index*8+3) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+3]) : Container(),
              (index*8+4) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+4]) : Container(),
              (index*8+5) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+5]) : Container(),
              (index*8+6) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+6]) : Container(),
              (index*8+7) < smileyList.length ? EmojiKey(emoji: smileyList[index*8+7]) : Container()
            ]
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 260,
        color: Colors.grey,
        child: Column(
            children: [
              buildKeyboard(),
            ])
    );
  }
}
