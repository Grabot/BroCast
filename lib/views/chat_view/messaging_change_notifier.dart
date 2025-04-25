import 'package:flutter/material.dart';


class MessagingChangeNotifier extends ChangeNotifier {

  // If the bro opens a message view we keep track of which broupId it is
  // If the bro gets a message we can check if it's on the page that is open
  int broupId = -1;
  bool isOpen = false;
  static final MessagingChangeNotifier _instance = MessagingChangeNotifier._internal();

  MessagingChangeNotifier._internal();

  factory MessagingChangeNotifier() {
    return _instance;
  }

  setBroupId(int broupId) {
    if (broupId == -1) {
      isOpen = false;
    } else {
      isOpen = true;
    }
    this.broupId = broupId;
  }

  getBroupId() {
    return broupId;
  }

  notify() {
    notifyListeners();
  }
}
