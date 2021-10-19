import 'package:brocast/objects/chat.dart';

class BroList {
  static BroList _instance = new BroList._internal();

  List<Chat> bros = [];

  static get instance => _instance;

  BroList._internal();

  List<Chat> getBros() {
    return this.bros;
  }

  void setBros(List<Chat> bros) {
    this.bros = bros;
  }
}
