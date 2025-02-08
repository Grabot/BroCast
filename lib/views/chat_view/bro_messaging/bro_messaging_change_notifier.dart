import 'package:flutter/material.dart';


class BroMessagingChangeNotifier extends ChangeNotifier {

  // If the bro opens a message view we keep track of which broupId it is
  // If the bro gets a message we can check if it's on the page that is open
  int broupId = -1;
  static final BroMessagingChangeNotifier _instance = BroMessagingChangeNotifier._internal();

  BroMessagingChangeNotifier._internal();

  factory BroMessagingChangeNotifier() {
    return _instance;
  }

  setBroupId(int broupId) {
    this.broupId = broupId;
  }

  getBroupId() {
    return broupId;
  }

  notify() {
    notifyListeners();
  }
}
