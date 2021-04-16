import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emoji_key.dart';

class EmojiPage extends StatefulWidget {

  EmojiPage({
    Key key,
    this.emojis,
    this.bromotionController
  }): super(key: key);

  final List emojis;
  final TextEditingController bromotionController;

  @override
  _EmojiPageState createState() => _EmojiPageState();
}

class _EmojiPageState extends State<EmojiPage> {
  static const platform = const MethodChannel("nl.brocast.emoji/available");
  static String recentEmojisKey = "recentEmojis";

  List emojis;

  ScrollController scrollController;
  TextEditingController bromotionController;

  // TODO: @Skools fix voor sign up screen?
  void textInputHandler(String text) => insertText(text);

  bool showBottomBar = true;

  @override
  void initState() {
    this.emojis = widget.emojis;

    this.bromotionController = widget.bromotionController;

    scrollController = new ScrollController();
    scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  void addRecentEmoji(String emoji) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    if (recent == null || recent == []) {
      recent = [];
    } else {
      // If the emoji is already in the list, then remove it so it is added in the front.
      recent.removeWhere((item) => item == emoji);
    }
    setState(() {
      recent.insert(0, emoji.toString());
      preferences.setStringList(recentEmojisKey, recent);
    });
  }

  isAvailable() {
    if (Platform.isAndroid) {
      Future.wait([getAvailableEmojis()])
          .then((var value) {
        setState(() {
          print("emojis loaded");
        });
      });
    }
  }

  Future getAvailableEmojis() async {
    this.emojis = await platform.invokeMethod(
        "isAvailable", {"emojis": this.emojis});
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

  void insertText(String myText) {
    addRecentEmoji(myText);
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
