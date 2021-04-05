import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiKey extends StatelessWidget {
  const EmojiKey({
    Key key,
    @required this.emoji,
    this.onTextInput,
    this.flex = 1,
  }) : super(key: key);  final String emoji;
  final ValueSetter<String> onTextInput;
  final int flex;  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.green.shade300,
          child: InkWell(
            onTap: () {
              onTextInput?.call(emoji);
            },
            child: Container(
              child: Center(child: Text(emoji)),
            ),
          ),
        ),
      ),
    );
  }
}