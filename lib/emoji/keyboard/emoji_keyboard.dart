import 'package:brocast/emoji/keyboard/emoji_spacebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'emoji_backspace.dart';
import 'emoji_key.dart';
import 'emoji_search.dart';
import 'emojis/smileys.dart';

class EmojiKeyboard extends StatefulWidget {

  TextEditingController bromotionController;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
  }) : super(key: key);

  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<EmojiKeyboard> {

  static const platform = const MethodChannel("nl.brocast.emoji/available");

  List smile;
  bool isLoading;

  TextEditingController bromotionController;

  void _textInputHandler(String text) => _insertText(text);
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => _backspace();
  void _spacebarHandler() => print("spacebar, hell yea");

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;

    isLoading = true;
    smile = [];

    isAvailable(smileyList);
    super.initState();
  }

  void _insertText(String myText) {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }


  void _backspace() {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final selectionLength = textSelection.end - textSelection.start;
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      bromotionController.text = newText;
      bromotionController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    if (textSelection.start == 0) {
      return;
    }

    String firstSection = text.substring(0, textSelection.start);
    String newFirstSection = firstSection.characters.skipLast(1).string;
    final offset = firstSection.length - newFirstSection.length;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void isAvailable(List emojis) async {

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
