import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/objects/bro.dart';
import 'package:brocast/services/add_bro.dart';
import 'package:brocast/services/notification_service.dart';
import 'package:brocast/services/search.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

class FindBros extends StatefulWidget {

  FindBros({ Key key }): super(key: key);

  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {

  Search search = new Search();

  bool isSearching = false;
  List<Bro> bros = [];

  bool showEmojiKeyboard = false;

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  final formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);
    NotificationService.instance.setScreen(this);
    BackButtonInterceptor.add(myInterceptor);
  }

  bromotionListener() {
    bromotionController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionController.text.replaceFirst(lastEmoji, "");
      bromotionController.text = newText;
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => BroCastHome()
      ));
      return true;
    }
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

  void goToDifferentChat(Bro chatBro) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => BroMessaging(bro: chatBro)
    ));
  }

  searchBros() {
    if (formFieldKey.currentState.validate()) {
      setState(() {
        isSearching = true;
      });

      search.searchBro(broNameController.text, bromotionController.text).then((
          val) {
        if (!(val is String)) {
          setState(() {
            bros = val;
          });
        } else {
          ShowToastComponent.showDialog(val.toString(), context);
        }
        setState(() {
          isSearching = false;
        });
      });
    }
  }

  Widget broList() {
    return bros.isNotEmpty ?
      ListView.builder(
      shrinkWrap: true,
      itemCount: bros.length,
        itemBuilder: (context, index) {
          return BroTileSearch(
              bros[index]
          );
        }) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, true),
      body: Container(
        child: Column(
          children: [
            Text(
              "search for your bro using their bro name \n(bromotion optional)",
              style: simpleTextStyle()
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      key: formFieldKey,
                      onTap: () {
                        onTapTextField();
                      },
                      validator: (val) {
                        return val.isEmpty ? "Please provide a bro name": null;
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
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      searchBros();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0x36FFFFFF),
                        borderRadius: BorderRadius.circular(40)
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search)
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: broList()
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  bromotionController: bromotionController,
                  emojiKeyboardHeight: 320,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: Settings.instance.getEmojiKeyboardDarkMode()
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BroTileSearch extends StatelessWidget {
  final Bro bro;

  BroTileSearch(this.bro);

  final AddBro add = new AddBro();

  addBro(BuildContext context) {
    HelperFunction.getBroToken().then((val) {
      if (val == null || val == "") {
        print("no token found, this should not happen");
      } else {
        add.addBro(val.toString(), bro.id);

        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroMessaging(bro: bro)
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(bro.getFullBroName(), style: simpleTextStyle()),
          Spacer(),
          GestureDetector(
            onTap: () {
              addBro(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30)
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Add")
            ),
          )
        ],
      ),
    );
  }
}
