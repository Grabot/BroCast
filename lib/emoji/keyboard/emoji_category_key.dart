import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiCategoryKey extends StatelessWidget {

  const EmojiCategoryKey({
    Key key,
    this.onCategorySelect,
    this.category,
    this.categoryName,
    this.active
  }) : super(key: key);

  final ValueSetter<String> onCategorySelect;
  final IconData category;
  final String categoryName;
  final bool active;

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1.0),
      decoration: active ? BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 2.0, color: Colors.lightBlue.shade900)))
          : BoxDecoration(),
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 9, // make it 8 buttons wide
          height: MediaQuery.of(context).size.width / 9, // make it square
          child: IconButton(
            icon: Icon(category),
            color: active ? Colors.black : Colors.grey,
            onPressed: () {
              onCategorySelect?.call(categoryName);
            },
          )
      ),
    );
  }
}