import 'package:flutter/material.dart';


class MessagingChangeNotifier extends ChangeNotifier {

  // If the bro opens a message view we keep track of which broupId it is
  // If the bro gets a message we can check if it's on the page that is open
  int broupId = -1;
  static final MessagingChangeNotifier _instance = MessagingChangeNotifier._internal();

  MessagingChangeNotifier._internal();

  factory MessagingChangeNotifier() {
    return _instance;
  }

  setBroupId(int broupId) {
    print("setting broup id on the listener $broupId");
    this.broupId = broupId;
  }

  getBroupId() {
    return broupId;
  }

  notify() {
    notifyListeners();
  }
}
