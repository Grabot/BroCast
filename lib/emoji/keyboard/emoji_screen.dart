import 'package:brocast/emoji/keyboard/emojis/activities.dart';
import 'package:brocast/emoji/keyboard/emojis/animals.dart';
import 'package:brocast/emoji/keyboard/emojis/flags.dart';
import 'package:brocast/emoji/keyboard/emojis/foods.dart';
import 'package:brocast/emoji/keyboard/emojis/objects.dart';
import 'package:brocast/emoji/keyboard/emojis/smileys.dart';
import 'package:brocast/emoji/keyboard/emojis/symbols.dart';
import 'package:brocast/emoji/keyboard/emojis/travel.dart';
import 'package:flutter/material.dart';

import 'emoji_page.dart';

class EmojiScreen extends StatefulWidget {

  EmojiScreen({
    Key key,
    this.screenHeight
  }): super(key: key);

  final double screenHeight;

  @override
  _EmojiScreenState createState() => _EmojiScreenState();
}

class _EmojiScreenState extends State<EmojiScreen> {

  double screenHeight;

  PageController pageController;

  @override
  void initState() {
    screenHeight = widget.screenHeight;

    pageController = new PageController(
      initialPage: 1
    );

    super.initState();
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
              // TODO: @Skools fix recent
              EmojiPage(
                emojiList: [],
              ),
              EmojiPage(
                emojiList: smileysList,
              ),
              EmojiPage(
                emojiList: animalsList,
              ),
              EmojiPage(
                emojiList: foodsList,
              ),
              EmojiPage(
                emojiList: activitiesList,
              ),
              EmojiPage(
                emojiList: travelList,
              ),
              EmojiPage(
                emojiList: objectsList,
              ),
              EmojiPage(
                emojiList: symbolsList,
              ),
              EmojiPage(
                emojiList: flagsList,
              )
            ]
        ),
      ),
    );
  }
}
