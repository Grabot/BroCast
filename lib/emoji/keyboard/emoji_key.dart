import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiKey extends StatelessWidget {
  const EmojiKey({
    Key key,
    this.onTextInput,
    this.emoji,
  }) : super(key: key);

  final List emoji;
  final ValueSetter<String> onTextInput;

  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
      height: MediaQuery.of(context).size.width / 8, // make it square
      child: TextButton(
        onPressed: () {
          onTextInput?.call(emoji[1]);
        },
        child: Text(emoji[1]),
      )
    );
  }
}