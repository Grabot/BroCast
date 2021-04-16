
import 'package:flutter/material.dart';

import 'emoji_backspace.dart';
import 'emoji_search.dart';
import 'emoji_spacebar.dart';

class BottomBar extends StatefulWidget {

  final TextEditingController bromotionController;

  BottomBar({
    Key key,
    this.bromotionController,
  }):super(key:key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {

  TextEditingController bromotionController;
  final double bottomBarHeight = 50;
  bool showBottomBar;

  @override
  void initState() {
    this.showBottomBar = true;
    this.bromotionController = widget.bromotionController;
    super.initState();
  }

  void emojiScrollShowBottomBar(bool showBottom) {
    if (showBottom != showBottomBar) {
      setState(() {
        showBottomBar = showBottom;
      });
    }
  }

  void onBackSpace() {
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
    return Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        height: showBottomBar ? bottomBarHeight : 0,
        width: MediaQuery.of(context).size.width,
        duration: new Duration(seconds: 1),
        child:Container(
          color: Colors.white,
          child:SizedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SearchKey(
                  onSearch: null,
                ),
                SpacebarKey(
                  onSpacebar: null,
                ),
                BackspaceKey(
                  onBackspace: onBackSpace,
                )
              ],
            ),
          ),
        ),
        ),
      );
  }
}
