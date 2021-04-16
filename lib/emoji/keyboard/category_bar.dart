import 'package:flutter/material.dart';
import 'emoji_category_key.dart';

class CategoryBar extends StatelessWidget {

  const CategoryBar({
    Key key,
    this.categoryHandler,
    this.emojiCategoryHeight,
    this.categorySelected
  }) : super(key: key);

  final double emojiCategoryHeight;
  final ValueSetter<String> categoryHandler;
  final int categorySelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.white,
        height: emojiCategoryHeight,
        width: MediaQuery.of(context).size.width,
        child:SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.access_time,
                categoryName: "recent",
                active: categorySelected == 0,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.tag_faces,
                categoryName: "smileys",
                active: categorySelected == 1,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.pets,
                categoryName: "animals",
                active: categorySelected == 2,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.fastfood,
                categoryName: "foods",
                active: categorySelected == 3,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.sports_soccer,
                categoryName: "activities",
                active: categorySelected == 4,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.directions_car,
                categoryName: "travels",
                active: categorySelected == 5,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.lightbulb_outline,
                categoryName: "objects",
                active: categorySelected == 6,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.euro_symbol,
                categoryName: "symbols",
                active: categorySelected == 7,
              ),
              EmojiCategoryKey(
                onCategorySelect: categoryHandler,
                category: Icons.flag,
                categoryName: "flags",
                active: categorySelected == 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
