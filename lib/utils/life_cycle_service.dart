import 'package:flutter/material.dart';


class LifeCycleService extends ChangeNotifier {

  // 0 paused
  // 1 active
  // 2 detached
  // 3 inactive
  int appStatus = 1;

  static final LifeCycleService _instance = LifeCycleService._internal();

  LifeCycleService._internal();

  factory LifeCycleService() {
    return _instance;
  }

  setAppStatus(int newAppStatus) {
    this.appStatus = appStatus;
    if (this.appStatus == 1) {
      notifyListeners();
    }
  }

  getAppStatus() {
    return this.appStatus;
  }
}
