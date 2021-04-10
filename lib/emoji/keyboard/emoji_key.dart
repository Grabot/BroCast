import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class EmojiKey extends StatelessWidget {
  const EmojiKey({
    Key key,
    this.emoji,
  }) : super(key: key);  final Tuple2<String, String> emoji;

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
      height: MediaQuery.of(context).size.width / 8, // make it square
      child: TextButton(
        onPressed: () {
          print(emoji);
        },
        child: Text(emoji.item2),
      )
    );
  }
}