import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiCategoryKey extends StatelessWidget {

  const EmojiCategoryKey({
    Key key,
    this.onCategorySelect,
    this.category,
    this.categoryName,
  }) : super(key: key);

  final ValueSetter<String> onCategorySelect;
  final IconData category;
  final String categoryName;

  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 9, // make it 8 buttons wide
        height: MediaQuery.of(context).size.width / 9, // make it square
        child: TextButton(
          onPressed: () {
            onCategorySelect?.call(categoryName);
          },
          child: Icon(category),
        )
    );
  }
}