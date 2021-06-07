import 'package:brocast/objects/bro_bros.dart';

class BroList {
  static BroList _instance = new BroList._internal();

  List<BroBros> bros = [];

  static get instance => _instance;

  BroList._internal();

  List<BroBros> getBros() {
    return this.bros;
  }

  void setBros(List<BroBros> bros) {
    this.bros = bros;
  }
}
