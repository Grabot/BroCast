
import 'package:flutter/material.dart';

import 'emoji_backspace.dart';
import 'emoji_search.dart';
import 'emoji_spacebar.dart';

Align buildBottomBar(context, bottomBarHeight, _searchHandler, _spacebarHandler, _backspaceHandler) {
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
      )
  );
}
