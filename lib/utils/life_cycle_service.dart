import 'package:brocast/utils/settings.dart';
import 'package:flutter/material.dart';


class LifeCycleService extends ChangeNotifier {

  // 0 paused
  // 1 active
  // 2 detached
  // 3 inactive
  int appStatus = 1;
  bool appOpen = true;

  static final LifeCycleService _instance = LifeCycleService._internal();

  LifeCycleService._internal();

  factory LifeCycleService() {
    return _instance;
  }

  setAppStatus(int newAppStatus) {
    this.appStatus = newAppStatus;
    if (this.appStatus == 1) {
      appOpen = true;
      notifyListeners();
    } else {
      appOpen = false;
      // Just in case we set the broups to be retrieved again.
      // If the app is opened again there will be another login in which details can change.
      Settings settings = Settings();
      settings.retrievedBroupData = false;
    }
  }

  setAppClosed() {
    // Only for "inactive"
    appOpen = false;
  }

  getAppStatus() {
    return this.appStatus;
  }
}
