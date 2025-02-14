import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/chat_view/chat_messaging.dart';
import 'package:brocast/views/opening_screen/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

import 'objects/broup.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.BroupRoute:
      Broup broup = settings.arguments as Broup;
      return MaterialPageRoute(
          builder: (context) => ChatMessaging(key: UniqueKey(), chat: broup));
    case routes.BroHomeRoute:
      return MaterialPageRoute(
          builder: (context) => BroCastHome(key: UniqueKey()));
    case routes.OpeningRoute:
      return MaterialPageRoute(builder: (context) => OpeningScreen());
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
