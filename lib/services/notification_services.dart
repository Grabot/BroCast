
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  static NotificationService _instance = new NotificationService._internal();
  static get instance => _instance;

  NotificationService._internal( ) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("message while chat open!");
      print(message);
      print(message.data);
    });
  }

}