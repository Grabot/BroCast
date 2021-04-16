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

  TextEditingController bromotionController;

  EmojiScreen({
    Key key,
    this.bromotionController,
    this.screenHeight
  }): super(key: key);

  final double screenHeight;

  @override
  _EmojiScreenState createState() => _EmojiScreenState();
}

class _EmojiScreenState extends State<EmojiScreen> {

  double screenHeight;

  PageController pageController;

  TextEditingController bromotionController;

  @override
  void initState() {
    screenHeight = widget.screenHeight;

    this.bromotionController = widget.bromotionController;

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
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: smileysList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: animalsList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: foodsList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: activitiesList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: travelList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: objectsList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: symbolsList,
                bromotionController: bromotionController
              ),
              EmojiPage(
                emojiList: flagsList,
                bromotionController: bromotionController
              )
            ]
        ),
      ),
    );
  }
}
