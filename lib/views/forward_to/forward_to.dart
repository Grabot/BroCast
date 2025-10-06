import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/share_with_service.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

import '../../../objects/me.dart';
import '../../objects/broup.dart';
import '../../objects/message.dart';
import 'models/bro_tile_forward.dart';

class ForwardTo extends StatefulWidget {

  final Message forwardMessage;

  ForwardTo({
    required Key key,
    required this.forwardMessage,
  }) : super(key: key);

  @override
  _ForwardToState createState() => _ForwardToState();
}

class _ForwardToState extends State<ForwardTo> {

  late Settings settings;
  late Storage storage;
  bool showEmojiKeyboard = false;
  bool searchMode = false;

  bool isLoading = false;

  List<Broup> shownBros = [];
  Me? me;

  TextEditingController bromotionController = new TextEditingController();
  TextEditingController broNameController = new TextEditingController();

  @override
  void initState() {
    settings = Settings();
    storage = Storage();
    bromotionController.addListener(bromotionListener);
    me = settings.getMe();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializeBroupList();
    });
    super.initState();
  }

  initializeBroupList() async {
    shownBros = me!.broups.where((broup) => !broup.deleted).toList();
    shownBros.sort((a, b) => b.getLastActivity().compareTo(a.getLastActivity()));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onChangedBroNameField(String typedText, String emojiField) {
    if (me != null) {
      if (emojiField.isEmpty && typedText.isNotEmpty) {
        shownBros = me!.broups
            .where((element) =>
            element
                .getBroupNameOrAlias().toLowerCase()
                .contains(typedText.toLowerCase()))
            .where((group) => !group.deleted).toList()
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isEmpty) {
        shownBros = me!.broups
            .where((element) =>
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .where((group) => !group.deleted).toList()
            .toList();
      } else if (emojiField.isNotEmpty && typedText.isNotEmpty) {
        shownBros = me!.broups
            .where((element) =>
        element
            .getBroupNameOrAlias().toLowerCase()
            .contains(typedText.toLowerCase()) &&
            element.getBroupNameOrAlias().toLowerCase().contains(emojiField))
            .where((group) => !group.deleted).toList()
            .toList();
      } else {
        // both empty
        // the broup objects from `me.broups` where the deleted is false.
        shownBros = me!.broups.where((group) => !group.deleted).toList();
      }
      shownBros.sort((a, b) => b.getLastActivity().compareTo(a.getLastActivity()));
    }
    setState(() {});
  }

  bromotionListener() {
    bromotionController.selection =
        TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionController.text.replaceFirst(lastEmoji, "");
      bromotionController.text = newText;
    }
    onChangedBroNameField(broNameController.text, bromotionController.text);
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else if (searchMode) {
      setState(() {
        searchMode = false;
      });
    } else {
      navigateToHome(context, settings);
    }
  }

  PreferredSize appBarShareWith(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Forward to...",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            searchMode
                ? IconButton(
                icon: Icon(Icons.search_off, color: Colors.white),
                onPressed: () {
                  broNameController.text = "";
                  bromotionController.text = "";
                  onChangedBroNameField(broNameController.text, bromotionController.text);
                  setState(() {
                    searchMode = false;
                  });
                })
                : IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    searchMode = true;
                  });
                }),
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("Back to Home")),
                ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToHome(context, settings);
        break;
    }
  }

  callback() {
    setState(() {

    });
  }

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onTapEmojiField() {
    if (!showEmojiKeyboard) {
      // We add a quick delay, this is to ensure that the keyboard is gone at this point.
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  Widget listOfBros() {
    return shownBros.isNotEmpty
        ? ListView.builder(
        shrinkWrap: true,
        itemCount: shownBros.length,
        itemBuilder: (context, index) {
          return BroTileForward(
              key: UniqueKey(),
              chat: shownBros[index],
              forwardMessage: widget.forwardMessage,
              callback: callback
          );
        })
        : Container();
  }

  Widget searchBarShare() {
    if (!searchMode) {
      return Container();
    } else {
      return Container(
        child: Row(children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              onTap: () {
                onTapTextField();
              },
              onChanged: (text) {
                onChangedBroNameField(text, bromotionController.text);
              },
              controller: broNameController,
              textAlign: TextAlign.center,
              style: simpleTextStyle(),
              decoration: textFieldInputDecoration("Bro name"),
            ),
          ),
          SizedBox(width: 50),
          Expanded(
            flex: 1,
            child: TextFormField(
              onTap: () {
                onTapEmojiField();
              },
              controller: bromotionController,
              style: simpleTextStyle(),
              textAlign: TextAlign.center,
              decoration: textFieldInputDecoration("😀"),
              readOnly: true,
              showCursor: true,
            ),
          ),
        ]),
      );
    }
  }

  Widget shareWithView(double width, height) {
    return Column(
      children: [
        searchBarShare(),
        Expanded(child: listOfBros()),
        !showEmojiKeyboard ? SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        ) : Container(),
        Align(
          alignment: Alignment.bottomCenter,
          child: EmojiKeyboard(
            emojiController: bromotionController,
            emojiKeyboardHeight: 350,
            showEmojiKeyboard: showEmojiKeyboard,
            darkMode: settings.getEmojiKeyboardDarkMode(),
            emojiKeyboardAnimationDuration: const Duration(milliseconds: 200),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: appBarShareWith(context),
        body: Stack(
          children: [
            isLoading
                ? Container(child: Center(child: CircularProgressIndicator()))
                : Container(),
            shareWithView(width, height),
          ]
        )
      )
    );
  }
}
