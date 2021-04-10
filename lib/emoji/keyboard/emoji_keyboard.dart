import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'emoji_key.dart';
import 'emoji_list.dart' as emojiList;

class EmojiKeyboard extends StatefulWidget {
  EmojiKeyboard({
    Key key
  }) : super(key: key);

  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<EmojiKeyboard> {

  Map<String, String> smileyMap = new Map();

  @override
  void initState() {
    smileyMap = emojiList.smileys;
    print(smileyMap);

    super.initState();
  }

  Expanded buildRowOne() {
    return Expanded(
      child: Wrap(
        children:
        [
          for (var smile in smileyMap.values) EmojiKey(emoji: smile)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 260,
        color: Colors.green,
        child: Column(
            children: [
              buildRowOne(),
            ])
    );
  }
}
