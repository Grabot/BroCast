import 'package:brocast/emoji/keyboard/emoji_spacebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'emoji_backspace.dart';
import 'emoji_key.dart';
import 'emoji_search.dart';
import 'emojis/smileys.dart';

class EmojiKeyboard extends StatefulWidget {

  ValueSetter<String> onTextInput;


  EmojiKeyboard({
    Key key,
    this.onTextInput,
  }) : super(key: key);

  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<EmojiKeyboard> {

  List smile;
  bool isLoading;

  ValueSetter<String> onTextInput;

  void _textInputHandler(String text) => onTextInput?.call(text);
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => print("back?!");
  void _spacebarHandler() => print("spacebar, hell yea");

  static const platform = const MethodChannel("com.flutter.epic/epic");

  @override
  void initState() {
    onTextInput = widget.onTextInput;
    isLoading = true;
    smile = [];

    isAvailable(smileyList);
    super.initState();
  }

  void isAvailable(List emojis) async {

    print("Going to check availability");
    // print(emojis);
    try {
      var value = await platform.invokeMethod("isAvailable", {"emojis": emojis});
      if (value != null) {
        setState(() {
          isLoading = false;
          smile = value;
        });
      }
    } catch (e) {
      print(e);
    }

  }


  Expanded buildKeyboard(double emojiKeyboardHeight) {
    double bottomBarHeight = 40;
    return Expanded(
      child: isLoading ? Container() :
      Column(
      children: [
      SizedBox(
        height: emojiKeyboardHeight-bottomBarHeight,
        child: ListView.builder(
        itemCount: smile.length,
        itemBuilder: (BuildContext cont, int index) {
          return new Row(
            children: [
              (index*8) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index * 8]
              ) : Container(),
              (index*8+1) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+1]
              ) : Container(),
              (index*8+2) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+2]
              ) : Container(),
              (index*8+3) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+3]
              ) : Container(),
              (index*8+4) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+4]
              ) : Container(),
              (index*8+5) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+5]
              ) : Container(),
              (index*8+6) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+6]
              ) : Container(),
              (index*8+7) < smile.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: smile[index*8+7]
              ) : Container()
            ]
          );
        },
      ),
      ),
      SizedBox(
        height: bottomBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SearchKey(
                onSearch: _searchHandler,
            ),
            SpacebarKey(
                onSpacebar: _spacebarHandler,
            ),
            BackspaceKey(
                onBackspace: _backspaceHandler,
            )
          ],
        )
      ),
      ])
    );
  }

  @override
  Widget build(BuildContext context) {
    double emojiKeyboardHeight = 290;
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Column(
            children: [
              buildKeyboard(emojiKeyboardHeight),
            ])
    );
  }
}
