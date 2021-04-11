import 'emoji_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'emoji_key.dart';

class EmojiKeyboard extends StatefulWidget {
  EmojiKeyboard({
    Key key
  }) : super(key: key);

  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<EmojiKeyboard> {

  List smile;

  static const platform = const MethodChannel("com.flutter.epic/epic");

  @override
  void initState() {
    var test = smileys;
    print(test);
    smile = test.values.toList();
    print(smile);
    for (String emoji in smile) {
      print(emoji);
    }
    isAvailable("🤣");
    isAvailable("😀");
    isAvailable("👩\u200d🦳");
    isAvailable("🙋‍♀");
    isAvailable("🙋‍♂");
    isAvailable("👴");
    isAvailable("🙋");
    super.initState();
  }

  void isAvailable(emoji) async {
    String value;

    try {
      value = await platform.invokeMethod("isAvailable", {"emoji": emoji});
      print(value.toString());
    } catch (e) {
      print(e);
    }

    print(value.toString());
  }

  Expanded buildKeyboard() {
    return Expanded(
      child: ListView.builder(
        itemCount: smile.length,
        itemBuilder: (BuildContext cont, int index) {
          return new Row(
            children: [
              (index*8) < smile.length ? EmojiKey(emoji: smile[index * 8]) : Container(),
              (index*8+1) < smile.length ? EmojiKey(emoji: smile[index*8+1]) : Container(),
              (index*8+2) < smile.length ? EmojiKey(emoji: smile[index*8+2]) : Container(),
              (index*8+3) < smile.length ? EmojiKey(emoji: smile[index*8+3]) : Container(),
              (index*8+4) < smile.length ? EmojiKey(emoji: smile[index*8+4]) : Container(),
              (index*8+5) < smile.length ? EmojiKey(emoji: smile[index*8+5]) : Container(),
              (index*8+6) < smile.length ? EmojiKey(emoji: smile[index*8+6]) : Container(),
              (index*8+7) < smile.length ? EmojiKey(emoji: smile[index*8+7]) : Container()
            ]
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 260,
        color: Colors.grey,
        child: Column(
            children: [
              buildKeyboard(),
            ])
    );
  }
}
