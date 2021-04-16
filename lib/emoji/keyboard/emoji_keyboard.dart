
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

  // void _searchHandler() => print("searching?");
  // void _backspaceHandler() => _backspace();
  // void _spacebarHandler() => _insertText(" ");
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

  emojiScrollShowBottomBar(bool showBottom) {
    print("quick test about emoji scroll $showBottom");
    if (showBottomBar != showBottom) {
      showBottomBar = showBottom;
      bottomBarStateKey.currentState.emojiScrollShowBottomBar(showBottomBar);
    }
  }

  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Stack(
        children: [
          EmojiScreen(
              screenHeight: emojiKeyboardHeight,
              bromotionController: bromotionController,
              emojiScrollShowBottomBar: emojiScrollShowBottomBar
          ),
          CategoryBar(
              categoryHandler: _categoryHandler,
              emojiCategoryHeight: emojiCategoryHeight,
              categorySelected: categorySelected
          ),
            BottomBar(
              key: bottomBarStateKey
            ),
        ]
      )
    );
  }
}
