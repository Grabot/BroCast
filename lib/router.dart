import 'package:brocast/views/bro_home.dart';
import 'package:brocast/views/bro_messaging.dart';
import 'package:brocast/views/broup_messaging.dart';
import 'package:brocast/views/opening_screen.dart';
import 'package:flutter/material.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import 'objects/bro_bros.dart';
import 'objects/broup.dart';


// TODO: @Skools set SETTINGS data in every one of these routes. (from database)
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.BroRoute:
      BroBros bro = settings.arguments as BroBros;
      return MaterialPageRoute(builder: (context) => BroMessaging(
          key: UniqueKey(),
          chat: bro
      ));
    case routes.BroupRoute:
      Broup broup = settings.arguments as Broup;
      return MaterialPageRoute(builder: (context) => BroupMessaging(
          key: UniqueKey(),
          chat: broup
      ));
    case routes.HomeRoute:
      return MaterialPageRoute(builder: (context) => BroCastHome(
          key: UniqueKey()
      ));
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
