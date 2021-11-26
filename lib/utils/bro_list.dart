import 'package:brocast/objects/chat.dart';

class BroList {
  static final BroList _instance = BroList._internal();

  late List<Chat> bros;

  BroList._internal() {
    bros = [];
  }

  factory BroList() {
    return _instance;
  }


  List<Chat> getBros() {
    return this.bros;
  }

  void setBros(List<Chat> bros) {
    this.bros = bros;
  }

  void addBro(Chat chat) {
    this.bros.add(chat);
  }

  void updateChat(Chat chat) {
    bros[bros.indexWhere((bro) =>
          bro.id == chat.id && bro.broup == chat.broup)] = chat;
  }
}
