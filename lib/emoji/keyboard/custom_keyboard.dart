import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'backspace.dart';
import 'emoji_key.dart';

class CustomKeyboard extends StatelessWidget {
  CustomKeyboard({
    Key key,
    this.onTextInput,
    this.onBackspace,
  }) : super(key: key);  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;  void _textInputHandler(String text) => onTextInput?.call(text);  void _backspaceHandler() => onBackspace?.call();  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.green,
      child: Column(        // <-- Column
        children: [
          buildRowOne(),    // <-- Row
          buildRowTwo(),    // <-- Row
          buildRowThree(),  // <-- Row
        ],
      ),
    );
  }  Expanded buildRowOne() {
    return Expanded(
      child: Row(
        children: [
          EmojiKey(
            emoji: '😛',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '🤑',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '😟',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '😡',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '🖖',
            onTextInput: _textInputHandler,
          ),
        ],
      ),
    );
  }  Expanded buildRowTwo() {
    return Expanded(
      child: Row(
        children: [
          EmojiKey(
            emoji: '🦴',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '🧑',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '🤱',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '🧶',
            onTextInput: _textInputHandler,
          ),
          EmojiKey(
            emoji: '👛',
            onTextInput: _textInputHandler,
          ),
        ],
      ),
    );
  }  Expanded buildRowThree() {
    return Expanded(
      child: Row(
        children: [
          EmojiKey(
            emoji: ' ',
            flex: 4,
            onTextInput: _textInputHandler,
          ),
          BackspaceKey(
            onBackspace: _backspaceHandler,
          ),
        ],
      ),
    );
  }
}