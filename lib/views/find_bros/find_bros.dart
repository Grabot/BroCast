import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/material.dart';

import '../../objects/bro.dart';
import '../../services/auth/auth_service_social.dart';
import '../add_broup.dart';
import '../bro_profile.dart';
import '../bro_settings.dart';
import 'models/bro_tile_search.dart';

class FindBros extends StatefulWidget {
  FindBros({required Key key}) : super(key: key);

  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {
  Settings settings = Settings();
  bool isLoading = false;

  bool isSearching = false;
  List<Bro> possibleNewBros = [];

  bool showEmojiKeyboard = false;
  bool clickedNewBro = false;

  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();

  final formSearchKey = GlobalKey<FormState>();

  String searchedBroNothingFound = "";

  @override
  void initState() {
    super.initState();
    bromotionController.addListener(bromotionListener);
    BackButtonInterceptor.add(myInterceptor);
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
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    bromotionController.removeListener(bromotionListener);
    broNameController.dispose();
    bromotionController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void addBroup() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => AddBroup(key: UniqueKey())));
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

  searchBros() {
    if (formSearchKey.currentState!.validate()) {
      searchedBroNothingFound = "";
      setState(() {
        isSearching = true;
      });

      String broNameSearch = broNameController.text.trim();
      String bromotionSearch = bromotionController.text;

      AuthServiceSocial().searchPossibleBro(broNameSearch, bromotionSearch).then((bros) {
        if (bros.length == 0) {
          searchedBroNothingFound = broNameSearch;
        }
        setState(() {
          possibleNewBros = bros;
          isSearching = false;
        });
      });
    }
  }

  Widget listOfBros() {
    return ListView.builder(
            shrinkWrap: true,
            itemCount: possibleNewBros.length,
            itemBuilder: (context, index) {
              return BroTileSearch(
                  possibleNewBros[index], addNewBro);
            });
  }

  addNewBro(int addBroId) {
    if (!clickedNewBro) {
      clickedNewBro = true;
      setState(() {
        isLoading = true;
      });
      AuthServiceSocial().addNewBro(addBroId).then((value) {
        clickedNewBro = false;
        if (value) {
          // The broup added, move to the home screen where it will be shown
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => BroCastHome(key: UniqueKey())));
        } else {
          showToastMessage("Bro contact already in Bro list!");
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BroCastHome(key: UniqueKey())));
    }
  }

  PreferredSize appBarFindBros(BuildContext context) {
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
                  "Add new Bros",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(value: 2, child: Text("Home"))
                    ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroProfile(key: UniqueKey())));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroSettings(key: UniqueKey())));
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BroCastHome(key: UniqueKey())));
        break;
    }
  }

  Widget addNewBroup() {
    return InkWell(
      onTap: () {
        addBroup();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 80,
        child: Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: IconButton(
                    onPressed: () {
                      addBroup();
                    },
                    icon: Icon(Icons.group_add, color: Colors.white),
                  )),
              SizedBox(width: 20),
              Text(
                "Add new Broup",
                style: TextStyle(color: Colors.grey, fontSize: 20),
              )
            ]),
      ),
    );
  }

  Widget assistantText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerLeft,
      child: Text(
          "Search for a bro using their bro name \n(bromotion optional)",
          style: simpleTextStyle()),
    );
  }

  Widget broNameTextField() {
    return Expanded(
      child: TextFormField(
        onTap: () {
          if (!isLoading) {
            onTapTextField();
          }
        },
        validator: (val) {
          return val == null || val.isEmpty
              ? "Please provide your bro name"
              : null;
        },
        controller: broNameController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(),
        decoration: textFieldInputDecoration("Bro name"),
      ),
    );
  }

  Widget bromotionTextField() {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        onTap: () {
          if (!isLoading) {
            onTapEmojiField();
          }
        },
        controller: bromotionController,
        style: simpleTextStyle(),
        textAlign: TextAlign.center,
        decoration: textFieldInputDecoration("😀"),
        readOnly: true,
        showCursor: true,
      ),
    );
  }

  Widget searchBroButton() {
    return GestureDetector(
      onTap: () {
        searchBros();
      },
      child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: const Color(0x36FFFFFF),
              borderRadius: BorderRadius.circular(40)),
          padding: EdgeInsets.all(10),
          child: Icon(Icons.search)),
    );
  }

  Widget broNameAndBromotionInputField() {
    return Row(
      children: [
        SizedBox(width: 20),
        broNameTextField(),
        SizedBox(width: 20),
        bromotionTextField(),
        SizedBox(width: 20),
        searchBroButton()
      ],
    );
  }

  Widget searchForBroWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Form(
          key: formSearchKey,
          child: broNameAndBromotionInputField()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarFindBros(context),
      body: Container(
        child: Column(
          children: [
            addNewBroup(),
            assistantText(),
            searchForBroWidget(),
            isLoading
                ? Center(child: Container(child: CircularProgressIndicator()))
                : possibleNewBros.length == 0 && searchedBroNothingFound != ""
                  ? Container(
                child: Text("nothing found for $searchedBroNothingFound",
                        style: simpleTextStyle()))
                  : Container(),
            Expanded(child: listOfBros()),
            Align(
              alignment: Alignment.bottomCenter,
              child: EmojiKeyboard(
                  emojiController: bromotionController,
                  emojiKeyboardHeight: 300,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode()),
            ),
          ],
        ),
      ),
    );
  }
}
