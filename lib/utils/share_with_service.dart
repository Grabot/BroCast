import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import '../constants/route_paths.dart' as routes;
import 'locator.dart';
import 'navigation_service.dart';

class ShareWithService {
  static final ShareWithService _instance = ShareWithService._internal();

  final NavigationService _navigationService = locator<NavigationService>();

  ShareWithService._internal() {
    shareWithFiles();
  }

  factory ShareWithService() {
    return _instance;
  }

  List<SharedFile> sharedFiles = [];

  void shareWithFiles() {
    print("sharing initialized");

    FlutterSharingIntent.instance.getMediaStream()
        .listen((List<SharedFile> value) {
      sharedFiles = value;
      if (sharedFiles.isNotEmpty) {
        _navigationService.navigateTo(routes.ShareWithRoute);
      }
      print("Shared: getMediaStream ${value.map((f) => f.value).join(",")}");
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
      sharedFiles = value;
      if (sharedFiles.isNotEmpty) {
        _navigationService.navigateTo(routes.ShareWithRoute);
      }
    });
  }

  clearShare() {
    sharedFiles = [];
  }
}