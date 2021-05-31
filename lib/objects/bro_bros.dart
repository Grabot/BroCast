import 'dart:ui';

class BroBros {

  int id;
  String chatName;
  Color broColor;

  BroBros(
      int id,
      String chatName,
      String chatColour
      ) {
    this.id = id;
    this.chatName = chatName;
    this.broColor = Color(int.parse("0xFF$chatColour"));
  }
}