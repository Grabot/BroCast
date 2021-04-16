
import 'package:flutter/material.dart';

import 'emoji_backspace.dart';
import 'emoji_search.dart';
import 'emoji_spacebar.dart';

class BottomBar extends StatelessWidget {

  const BottomBar({
    Key key,
    this.searchHandler,
    this.spacebarHandler,
    this.backspaceHandler,
    this.bottomBarHeight
  }) : super(key: key);

  final VoidCallback searchHandler;
  final VoidCallback spacebarHandler;
  final VoidCallback backspaceHandler;
  final double bottomBarHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
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
                  SearchKey(
                    onSearch: searchHandler,
                  ),
                  SpacebarKey(
                    onSpacebar: spacebarHandler,
                  ),
                  BackspaceKey(
                    onBackspace: backspaceHandler,
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
