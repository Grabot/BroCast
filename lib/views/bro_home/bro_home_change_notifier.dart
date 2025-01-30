import 'package:flutter/material.dart';


class BroHomeChangeNotifier extends ChangeNotifier {

  static final BroHomeChangeNotifier _instance = BroHomeChangeNotifier._internal();

  BroHomeChangeNotifier._internal();

  factory BroHomeChangeNotifier() {
    return _instance;
  }

  notify() {
    notifyListeners();
  }
}
