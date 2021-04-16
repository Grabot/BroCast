import 'package:brocast/emoji/keyboard/emojis/activities.dart';
import 'package:brocast/emoji/keyboard/emojis/animals.dart';
import 'package:brocast/emoji/keyboard/emojis/flags.dart';
import 'package:brocast/emoji/keyboard/emojis/foods.dart';
import 'package:brocast/emoji/keyboard/emojis/objects.dart';
import 'package:brocast/emoji/keyboard/emojis/smileys.dart';
import 'package:brocast/emoji/keyboard/emojis/symbols.dart';
import 'package:brocast/emoji/keyboard/emojis/travel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emoji_page.dart';

class EmojiScreen extends StatefulWidget {

  final TextEditingController bromotionController;
  final Function(bool) emojiScrollShowBottomBar;
  final double screenHeight;

  EmojiScreen({
    Key key,
    this.bromotionController,
    this.screenHeight,
    this.emojiScrollShowBottomBar
  }): super(key: key);

  @override
  _EmojiScreenState createState() => _EmojiScreenState();
}

class _EmojiScreenState extends State<EmojiScreen> {
  static String recentEmojisKey = "recentEmojis";

  List<String> recent;
  double screenHeight;
  int categorySelected;

  PageController pageController;

  TextEditingController bromotionController;

  @override
  void initState() {
    screenHeight = widget.screenHeight;

    recent = [];
    categorySelected = 1;

    getRecentEmoji().then((value) {
      List<String> recentUsed = [];
      if (value != null && value != []) {
        for (var val in value) {
          recentUsed.add(val.toString());
        }
        setState(() {
          recent = recentUsed;
        });
      }
    });

    this.bromotionController = widget.bromotionController;

    pageController = new PageController(
      initialPage: 1
    );

    super.initState();
  }

  Future getRecentEmoji() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recent = preferences.getStringList(recentEmojisKey);
    return recent;
  }

  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: screenHeight,
        child: PageView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children: [
              EmojiPage(
                  emojis: recent,
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(smileysList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(animalsList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(foodsList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(activitiesList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(travelList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(objectsList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(symbolsList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              ),
              EmojiPage(
                  emojis: getEmojis(flagsList),
                  bromotionController: bromotionController,
                  emojiScrollShowBottomBar: widget.emojiScrollShowBottomBar
              )
            ]
        ),
      ),
    );
  }
}
