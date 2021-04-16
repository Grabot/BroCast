import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'emoji_key.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.emojiList,
  }): super(key: key);

  final List emojiList;

  @override
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {

  List emojis;

  ScrollController scrollController;

  void textInputHandler(String text) => print("pressed emoji $text");

  bool showBottomBar = true;

  @override
  void initState() {
    this.emojis = getEmojis(widget.emojiList);

    scrollController = new ScrollController();
    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  keyboardScrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        print("reached the bottom of the scrollview");
      }
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (showBottomBar) {
            showBottomBar = false;
            print("going down");
          }
        }
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!showBottomBar) {
            showBottomBar = true;
            print("going up");
          }
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: (emojis.length/8).ceil() + 1,
      itemBuilder: (BuildContext cont, int index) {
        return new Row(
            children: [
              (index*8) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index * 8]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),// make it square),
              (index*8+1) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+1]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+2) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+2]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+3) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+3]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+4) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+4]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+5) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+5]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+6) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+6]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
              (index*8+7) < emojis.length ? EmojiKey(
                  onTextInput: textInputHandler,
                  emoji: emojis[index*8+7]
              ) : SizedBox(
                  width: MediaQuery.of(context).size.width / 8,
                  height: MediaQuery.of(context).size.width / 8
              ),
            ]
        );
      },
    );
  }
}
