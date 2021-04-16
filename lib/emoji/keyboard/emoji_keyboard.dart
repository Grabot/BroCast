
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

  final GlobalKey<BottomBarState> bottomBarStateKey = GlobalKey<BottomBarState>();
  final GlobalKey<CategoryBarState> categoryBarStateKey = GlobalKey<CategoryBarState>();
  final GlobalKey<EmojiScreenState> emojiScreenStateKey = GlobalKey<EmojiScreenState>();

  int categorySelected;

  bool showBottomBar;

  double bottomBarHeight;
  double emojiCategoryHeight;
  double emojiKeyboardHeight;

  TextEditingController bromotionController;

  @override
  void initState() {
    categorySelected = 0;

    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;

    showBottomBar = true;

    super.initState();
  }

  void visibilityBottomBar(bool show) {
    print("you have to $show the bar");
  }

  void categorySelect(int category) {
    if (category != categorySelected) {
      // TODO: @SKools pagecontroller scroll
      categorySelected = category;
      categoryBarStateKey.currentState.updateCategoriesBar(categorySelected);
      emojiScreenStateKey.currentState.updateEmojiPage(categorySelected);
    }
  }

  void updateCategory(int category) {
    categorySelected = category;
    categoryBarStateKey.currentState.updateCategoriesBar(categorySelected);
  }

  emojiScrollShowBottomBar(bool showBottom) {
    if (showBottomBar != showBottom) {
      showBottomBar = showBottom;
      bottomBarStateKey.currentState.emojiScrollShowBottomBar(showBottomBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Stack(
        children: [
          EmojiScreen(
            key: emojiScreenStateKey,
            screenHeight: emojiKeyboardHeight,
            bromotionController: bromotionController,
            emojiScrollShowBottomBar: emojiScrollShowBottomBar,
            updateCategory: updateCategory
          ),
          CategoryBar(
            key: categoryBarStateKey,
            categorySelected: categorySelected,
            categoryHandler: categorySelect
          ),
          BottomBar(
            key: bottomBarStateKey
          ),
        ]
      )
    );
  }
}
