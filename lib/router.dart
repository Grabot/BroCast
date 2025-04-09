import 'package:brocast/views/bro_access_page.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/chat_view/chat_messaging.dart';
import 'package:brocast/views/opening_screen/opening_screen.dart';
import 'package:brocast/views/sign_in/signin.dart';
import 'package:flutter/material.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import 'objects/broup.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.OpeningRoute:
      return MaterialPageRoute(builder: (context) => OpeningScreen());
    case routes.SignInRoute:
      return MaterialPageRoute(builder: (context) => SignIn(key: UniqueKey(), showRegister: false));
    case routes.BroHomeRoute:
      return MaterialPageRoute(
          builder: (context) => BrocastHome(key: UniqueKey()));
    case routes.ChatRoute:
      Broup chat = settings.arguments as Broup;
      return MaterialPageRoute(
          builder: (context) => ChatMessaging(
            key: UniqueKey(),
            chat: chat,
          )
      );
    case routes.BroAccessRoute:
      return MaterialPageRoute(
          builder: (context) {
            return BroAccess(key: UniqueKey());
          }
      );
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No path for ${settings.name}'),
          ),
        ),
      );
  }
}
