import 'dart:async';
import 'dart:io';

import 'package:brocast/emoji/keyboard/emoji_spacebar.dart';
import 'package:brocast/emoji/keyboard/emojis/objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_bar.dart';
import 'category_bar.dart';
import 'emoji_backspace.dart';
import 'emoji_key.dart';
import 'emoji_search.dart';
import 'emojis/activities.dart';
import 'emojis/animals.dart';
import 'emojis/flags.dart';
import 'emojis/foods.dart';
import 'emojis/smileys.dart';
import 'emojis/symbols.dart';
import 'emojis/travel.dart';

class EmojiKeyboard extends StatefulWidget {

  TextEditingController bromotionController;
  double emojiKeyboardHeight;
  bool signingScreen;

  EmojiKeyboard({
    Key key,
    this.bromotionController,
    this.emojiKeyboardHeight,
    this.signingScreen = false
  }) : super(key: key);

  EmojiBoard createState() => EmojiBoard();
}

class EmojiBoard extends State<EmojiKeyboard> {

  static const platform = const MethodChannel("nl.brocast.emoji/available");

  List<String> recent;
  List smileys;
  List animals;
  List foods;
  List activities;
  List travel;
  List objects;
  List symbols;
  List flags;

  int categorySelected;

  bool showBottomBar;

  double bottomBarHeight;
  double emojiCategoryHeight;
  double emojiKeyboardHeight;

  static String recentEmojisKey = "recentEmojis";

  TextEditingController bromotionController;

  PageController pageController;

  void _textInputHandler(String text) => widget.signingScreen ? _insertTextSignUpScreen(text) : _insertText(text);
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => _backspace();
  void _spacebarHandler() => _insertText("  ");
  void _categoryHandler(String category) => _categorySelect(category);

  ScrollController _scrollController;

  @override
  void initState() {
    categorySelected = 0;

    recent = [];
    smileys = [];
    animals = [];
    foods = [];
    activities = [];
    travel = [];
    objects = [];
    symbols = [];
    flags = [];

    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;
    this.emojiCategoryHeight = emojiKeyboardHeight / 6;
    this.bottomBarHeight = emojiKeyboardHeight / 6;

    showBottomBar = true;

    smileys = getEmojis(smileysList);
    animals = getEmojis(animalsList);
    foods = getEmojis(foodsList);
    activities = getEmojis(activitiesList);
    travel = getEmojis(travelList);
    objects = getEmojis(objectsList);
    symbols = getEmojis(symbolsList);
    flags = getEmojis(flagsList);
    recent = [];

    isAvailable();

    _scrollController = ScrollController();
    pageController = PageController();
    _scrollController.addListener(() => keyboardScrollListener());
    pageController.addListener(() => pageScrollListener());


    super.initState();
  }

  List<String> getEmojis(emojiList) {
    List<String> onlyEmoji = [];
    for (List<String> emoji in emojiList) {
      onlyEmoji.add(emoji[1]);
    }
    return onlyEmoji;
  }

  pageScrollListener() {
    if (pageController.hasClients) {
      if (pageController.position.userScrollDirection == ScrollDirection.reverse || pageController.position.userScrollDirection == ScrollDirection.forward) {
        if (pageController.page.round() != categorySelected) {
          setState(() {
            categorySelected = pageController.page.round();
          });
        }
      }
    }
  }

  keyboardScrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print("reached the bottom of the scrollview");
      }
      if (showBottomBar) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          setState(() {
            bottomBarHeight = 0;
            showBottomBar = false;
          });
        }
      } else {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          setState(() {
            this.bottomBarHeight = emojiKeyboardHeight / 6;
            showBottomBar = true;
          });
        }
      }
    }
  }

  void _insertTextSignUpScreen(String myText) {
    if (!showBottomBar) {
      setState(() {
        this.bottomBarHeight = emojiKeyboardHeight / 6;
        showBottomBar = true;
      });
    }
    // The user is only allowed to give 1 emoji
    bromotionController.clear();
    bromotionController.text = myText;
  }

  void _categorySelect(String category) {
    setState(() {
      if (category == "recent") {
        categorySelected = 0;
      } else if (category == "smileys") {
        categorySelected = 1;
      } else if (category == "animals") {
        categorySelected = 2;
      } else if (category == "foods") {
        categorySelected = 3;
      } else if (category == "activities") {
        categorySelected = 4;
      } else if (category == "travels") {
        categorySelected = 5;
      } else if (category == "objects") {
        categorySelected = 6;
      } else if (category == "symbols") {
        categorySelected = 7;
      } else if (category == "flags") {
        categorySelected = 8;
      }
      pageController.animateToPage(categorySelected, duration: Duration(milliseconds: 500), curve: Curves.ease);
      _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    });
  }

  void _insertText(String myText) {
    if (!showBottomBar) {
      setState(() {
        this.bottomBarHeight = emojiKeyboardHeight / 6;
        showBottomBar = true;
      });
    }
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


  void _backspace() {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final selectionLength = textSelection.end - textSelection.start;
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      bromotionController.text = newText;
      bromotionController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }

    if (textSelection.start == 0) {
      return;
    }

    String firstSection = text.substring(0, textSelection.start);
    String newFirstSection = firstSection.characters.skipLast(1).string;
    final offset = firstSection.length - newFirstSection.length;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }

  void isAvailable() async {

    getRecentEmojis().then((value) {
      print("recent thingies");
      recent = value;
      if (recent.length > 0) {
        categorySelected = 0;
      } else {
        categorySelected = 1;
      }
      pageController.animateToPage(categorySelected, duration: Duration(milliseconds: 500), curve: Curves.ease);
    });


    if (Platform.isAndroid) {

      Future.wait([getSmileys(), getAnimals(), getFoods(), getActivities(),
        getTravels(), getObjects(), getSymbols(), getFlags()])
          .then((var value) {
            print("emojis loaded");
      });

    }
  }

  void addRecentEmoji(String emoji) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // If the emoji is already in the list, then remove it so it is added in the front.
    recent.removeWhere((item) => item == emoji);
    setState(() {
      recent.insert(0, emoji.toString());
      preferences.setStringList(recentEmojisKey, recent);
    });
  }

  Future<List> getRecentEmojis() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(recentEmojisKey) ?? [];
  }

  Future getSmileys() async {
    smileys = await platform.invokeMethod(
        "isAvailable", {"emojis": smileys});
  }

  Future getAnimals() async {
    animals = await platform.invokeMethod(
        "isAvailable", {"emojis": animals});
  }

  Future getFoods() async {
    foods = await platform.invokeMethod(
        "isAvailable", {"emojis": foods});
  }

  Future getActivities() async {
    activities = await platform.invokeMethod(
        "isAvailable", {"emojis": activities});
  }

  Future getTravels() async {
    travel = await platform.invokeMethod(
        "isAvailable", {"emojis": travel});
  }

  Future getObjects() async {
    objects = await platform.invokeMethod(
        "isAvailable", {"emojis": objects});
  }

  Future getSymbols() async {
    symbols = await platform.invokeMethod(
        "isAvailable", {"emojis": symbols});
  }

  Future getFlags() async {
    flags = await platform.invokeMethod(
        "isAvailable", {"emojis": flags});
  }

  ListView emojiScreen(emojis) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: emojis.length,
      itemBuilder: (BuildContext cont, int index) {
        return new Row(
            children: [
              (index*8) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index * 8]
              ) : Container(),
              (index*8+1) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+1]
              ) : Container(),
              (index*8+2) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+2]
              ) : Container(),
              (index*8+3) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+3]
              ) : Container(),
              (index*8+4) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+4]
              ) : Container(),
              (index*8+5) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+5]
              ) : Container(),
              (index*8+6) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+6]
              ) : Container(),
              (index*8+7) < emojis.length ? EmojiKey(
                  onTextInput: _textInputHandler,
                  emoji: emojis[index*8+7]
              ) : Container()
            ]
        );
      },
    );
  }

  Align buildEmojiScreen() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: emojiKeyboardHeight-emojiCategoryHeight,
        child: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children: [
              emojiScreen(recent),
              emojiScreen(smileys),
              emojiScreen(animals),
              emojiScreen(foods),
              emojiScreen(activities),
              emojiScreen(travel),
              emojiScreen(objects),
              emojiScreen(symbols),
              emojiScreen(flags)
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Stack(
        children: [
          buildEmojiScreen(),
          buildCategories(context, emojiCategoryHeight, _categoryHandler, categorySelected),
          buildBottomBar(context, bottomBarHeight, _searchHandler, _spacebarHandler, _backspaceHandler),
        ]
      )
    );
  }
}
