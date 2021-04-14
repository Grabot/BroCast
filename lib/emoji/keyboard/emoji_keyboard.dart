import 'dart:io';

import 'package:brocast/emoji/keyboard/emoji_category_key.dart';
import 'package:brocast/emoji/keyboard/emoji_spacebar.dart';
import 'package:brocast/emoji/keyboard/emojis/objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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

  List emojis;

  List smileys;
  List animals;
  List foods;
  List activities;
  List travel;
  List objects;
  List symbols;
  List flags;

  bool showBottomBar;

  double bottomBarHeight = 40;
  double emojiKeyboardHeight;

  TextEditingController bromotionController;

  void _textInputHandler(String text) => widget.signingScreen ? _insertTextSignUpScreen(text) : _insertText(text);
  void _searchHandler() => print("searching?");
  void _backspaceHandler() => _backspace();
  void _spacebarHandler() => _insertText("  ");
  void _categoryHandler(String category) => _categorySelect(category);

  ScrollController _scrollController;

  @override
  void initState() {
    this.bromotionController = widget.bromotionController;
    this.emojiKeyboardHeight = widget.emojiKeyboardHeight;

    showBottomBar = true;
    emojis = [];

    isAvailable();

    _scrollController = ScrollController();
    _scrollController.addListener(() => keyboardScrollListener());

    super.initState();
  }

  keyboardScrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print("reached the bottomm of the scrollview");
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
            bottomBarHeight = 40;
            showBottomBar = true;
          });
        }
      }
    }
  }

  void _insertTextSignUpScreen(String myText) {
    if (!showBottomBar) {
      setState(() {
        bottomBarHeight = 40;
        showBottomBar = true;
      });
    }
    // The user is only allowed to give 1 emoji
    bromotionController.clear();
    bromotionController.text = myText;
  }

  void _categorySelect(String category) {
    print("category $category selected");
  }

  void _insertText(String myText) {
    if (!showBottomBar) {
      setState(() {
        bottomBarHeight = 40;
        showBottomBar = true;
      });
    }
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
    smileys = smileysList;
    animals = animalsList;
    foods = foodsList;
    activities = activitiesList;
    travel = travelList;
    objects = objectsList;
    symbols = symbolsList;
    flags = flagsList;
    if (Platform.isAndroid) {

      Future.wait([getSmileys(), getAnimals(), getFoods(), getActivities(),
        getTravels(), getObjects(), getSymbols(), getFlags()])
          .then((var value) {
            print("emojis loaded");
      });

    }

    emojis = smileys;
  }

  Future getSmileys() async {
    smileys = await platform.invokeMethod(
        "isAvailable", {"emojis": smileysList});
  }

  Future getAnimals() async {
    animals = await platform.invokeMethod(
        "isAvailable", {"emojis": animalsList});
  }

  Future getFoods() async {
    foods = await platform.invokeMethod(
        "isAvailable", {"emojis": foodsList});
  }

  Future getActivities() async {
    activities = await platform.invokeMethod(
        "isAvailable", {"emojis": activitiesList});
  }

  Future getTravels() async {
    travel = await platform.invokeMethod(
        "isAvailable", {"emojis": travelList});
  }

  Future getObjects() async {
    objects = await platform.invokeMethod(
        "isAvailable", {"emojis": objectsList});
  }

  Future getSymbols() async {
    symbols = await platform.invokeMethod(
        "isAvailable", {"emojis": symbolsList});
  }

  Future getFlags() async {
    flags = await platform.invokeMethod(
        "isAvailable", {"emojis": flagsList});
  }

  Expanded buildKeyboard() {
    return Expanded(
      child: Stack(
      children: [
        SizedBox(
          height: emojiKeyboardHeight,
          child: ListView.builder(
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
          ),
        ),
        Align(
            alignment: Alignment.topCenter,
            child: Container(
            color: Colors.white,
            height: 50,
            width: MediaQuery.of(context).size.width,
            child:SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.access_time,
                    categoryName: "recent"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.tag_faces,
                    categoryName: "smileys"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.pets,
                    categoryName: "animals"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.fastfood,
                    categoryName: "foods"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.sports_soccer,
                    categoryName: "activities"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.directions_car,
                    categoryName: "travels"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.lightbulb_outline,
                    categoryName: "objects"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.euro_symbol,
                    categoryName: "symbols"
                  ),
                  EmojiCategoryKey(
                    onCategorySelect: _categoryHandler,
                    category: Icons.flag,
                    categoryName: "flags"
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
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
        )
      ])
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: emojiKeyboardHeight,
        color: Colors.grey,
        child: Column(
            children: [
              buildKeyboard(),
            ])
    );
  }
}
