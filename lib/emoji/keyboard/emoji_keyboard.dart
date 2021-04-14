import 'package:brocast/emoji/keyboard/emoji_category_key.dart';
import 'package:brocast/emoji/keyboard/emoji_spacebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'emoji_backspace.dart';
import 'emoji_key.dart';
import 'emoji_search.dart';
import 'emojis/smileys.dart';

class EmojiKeyboard extends StatefulWidget {

  TextEditingController bromotionController;
  double emojiKeyboardHeight;
  bool signingScreen;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
    this.emojiKeyboardHeight,
    this.signingScreen = false
  }) : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {

  static const platform = const MethodChannel("nl.brocast.emoji/available");

  List smile;
  bool isLoading;
  bool showBottomBar;

  double bottomBarHeight;
  double emojiKeyboardHeight;

  TextEditingController bromotionController;

  void _textInputHandler(String text) => widget.signingScreen ? _insertTextSignUpScreen(text) : _insertText(text);
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => _backspace();
  void _spacebarHandler() => print("spacebar, hell yea");

  ScrollController _scrollController;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.bottomBarHeight = MediaQuery.of(context).size.width / 8;

    isLoading = true;
    showBottomBar = true;
    smile = [];

    isAvailable(smileyList);

    _scrollController = ScrollController();
    _scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  keyboardScrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print("reached the bottomm of the scrollview");
      }
      if (showBottomBar) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          setState(() {
            bottomBarHeight = 0;
            showBottomBar = false;
          });
          print("naar beneden gescrolled!");
        }
      } else {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          setState(() {
            bottomBarHeight = MediaQuery.of(context).size.width / 8;
            showBottomBar = true;
          });
          print("naar boven gescrolled!");
        }
      }
    }
  }

  void _insertTextSignUpScreen(String myText) {
    // The user is only allowed to give 1 emoji
    bromotionController.clear();
    bromotionController.text = myText;
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


  Expanded buildKeyboard() {
    return Expanded(
      child: isLoading ? Container() :
      Stack(
      children: [
        SizedBox(
          height: emojiKeyboardHeight,
          child: ListView.builder(
            controller: _scrollController,
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
        Align(
            alignment: Alignment.topCenter,
              child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.width / 8,
              width: MediaQuery.of(context).size.width,
              child:SizedBox(
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
                ),
              ),
            ),
        ),
        Align(
        alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            curve: Curves.fastOutSlowIn,
            height: bottomBarHeight,
            width: MediaQuery.of(context).size.width,
            duration: new Duration(seconds: 1),
            child: Container(
              color: Colors.white,
              child:SizedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    EmojiCategoryKey(
                        category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "animals",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                    EmojiCategoryKey(
                      category: "people",
                    ),
                  ]),
                ),
              ),
            ),
          )
        )
      ])
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Column(
            children: [
              buildKeyboard(),
            ])
    );
  }
}
