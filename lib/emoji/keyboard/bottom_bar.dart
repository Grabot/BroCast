
import 'package:flutter/material.dart';

import 'emoji_backspace.dart';
import 'emoji_search.dart';
import 'emoji_spacebar.dart';

class BottomBar extends StatefulWidget {

  BottomBar({
    Key key
  }):super(key:key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {

  final double bottomBarHeight = 50;
  bool showBottomBar;

  @override
  void initState() {
    this.showBottomBar = true;
    super.initState();
  }

  void emojiScrollShowBottomBar(bool showBottom) {
    if (showBottom != showBottomBar) {
      setState(() {
        showBottomBar = showBottom;
      });
    }
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
                  onBackspace: null,
                )
              ],
            ),
          ),
        ),
        ),
      );
  }
}
