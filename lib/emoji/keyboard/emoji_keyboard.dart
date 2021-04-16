
import 'package:brocast/emoji/keyboard/emoji_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'bottom_bar.dart';
import 'category_bar.dart';

class EmojiKeyboard extends StatefulWidget {

  final TextEditingController bromotionController;
  final double emojiKeyboardHeight;
  final bool signingScreen;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
    this.emojiKeyboardHeight,
    this.signingScreen = false
  }) : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {

  int categorySelected;

  bool showBottomBar;

  double bottomBarHeight;
  double emojiCategoryHeight;
  double emojiKeyboardHeight;

  TextEditingController bromotionController;

  void emojiScreenTest(String text) => print("something is pressed! :D $text");
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => _backspace();
  void _spacebarHandler() => _insertText(" ");
  void _categoryHandler(String category) => _categorySelect(category);
  void showBottomBarHandler(bool show) => visibilityBottomBar(show);

  @override
  void initState() {
    categorySelected = 0;

    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.emojiCategoryHeight = emojiKeyboardHeight / 6;
    this.bottomBarHeight = emojiKeyboardHeight / 6;

    showBottomBar = true;

    super.initState();
  }

  void visibilityBottomBar(bool show) {
    print("you have to $show the bar");
  }

  void _categorySelect(String category) {
    print("category is $category");
  }

  void _insertText(String myText) {
    if (!showBottomBar) {
      setState(() {
        this.bottomBarHeight = emojiKeyboardHeight / 6;
        showBottomBar = true;
      });
    }
    // addRecentEmoji(myText);
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

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Stack(
        children: [
          EmojiScreen(
            screenHeight: emojiKeyboardHeight-emojiCategoryHeight,
            bromotionController: bromotionController,
            categorySelected: categorySelected
          ),
          CategoryBar(
              categoryHandler: _categoryHandler,
              emojiCategoryHeight: emojiCategoryHeight,
              categorySelected: categorySelected
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
            curve: Curves.fastOutSlowIn,
            height: bottomBarHeight,
            width: MediaQuery.of(context).size.width,
            duration: new Duration(seconds: 1),
            child:
              BottomBar(
                  searchHandler: _searchHandler,
                  spacebarHandler: _spacebarHandler,
                  backspaceHandler: _backspaceHandler
              ),
            ),
          ),
        ]
      )
    );
  }
}
