import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiCategoryKey extends StatelessWidget {

  const EmojiCategoryKey({
    Key key,
    this.category,
  }) : super(key: key);

  final String category;

  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
        height: MediaQuery.of(context).size.width / 8, // make it square
        child: TextButton(
          onPressed: () {
            print("pressed category $category");
          },
          child: Text(category),
        )
    );
  }
}