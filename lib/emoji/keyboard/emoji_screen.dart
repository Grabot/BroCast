import 'package:flutter/material.dart';

import 'emoji_page.dart';

class EmojiScreen extends StatelessWidget {

  EmojiScreen({
    Key key,
    this.screenHeight,
    this.textInputHandler,
    this.recent,
    this.smileys,
    this.animals,
    this.foods,
    this.activities,
    this.travel,
    this.objects,
    this.symbols,
    this.flags
  }) : super(key: key);

  final double screenHeight;
  final ValueSetter<String> textInputHandler;

  final List recent;
  final List smileys;
  final List animals;
  final List foods;
  final List activities;
  final List travel;
  final List objects;
  final List symbols;
  final List flags;

  final PageController pageController = new PageController();

  // pageScrollListener() {
  //   if (pageController.hasClients) {
  //     if (pageController.position.userScrollDirection == ScrollDirection.reverse || pageController.position.userScrollDirection == ScrollDirection.forward) {
  //       if (pageController.page.round() != categorySelected) {
  //         setState(() {
  //           categorySelected = pageController.page.round();
  //         });
  //       }
  //     }
  //   }
  // }

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
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: smileys,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: animals,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: foods,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: activities,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: travel,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: objects,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: symbols,
                  textInputHandler: textInputHandler
              ),
              EmojiPage(
                  emojis: flags,
                  textInputHandler: textInputHandler
              )
            ]
        ),
      ),
    );
  }
}
