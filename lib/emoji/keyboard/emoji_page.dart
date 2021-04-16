import 'package:flutter/material.dart';

import 'emoji_key.dart';

class EmojiPage extends StatelessWidget {

  EmojiPage({
    Key key,
    this.emojis,
    this.textInputHandler
  }) : super(key: key);

  final List emojis;
  final ValueSetter<String> textInputHandler;

  final ScrollController scrollController = new ScrollController();

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
