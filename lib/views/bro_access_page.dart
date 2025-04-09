import 'package:flutter/material.dart';

import '../utils/locator.dart';
import '../utils/navigation_service.dart';


class BroAccess extends StatefulWidget {

  const BroAccess({
    super.key,
  });

  @override
  State<BroAccess> createState() => _BroAccessState();
}

class _BroAccessState extends State<BroAccess> {

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();
    String? accessToken = Uri.base.queryParameters["access_token"];
    String? refreshToken = Uri.base.queryParameters["refresh_token"];

    // Use the tokens to immediately refresh the access token
    if (accessToken != null && refreshToken != null) {
      print("Access token: $accessToken");
      print("Refresh token: $refreshToken");
      print("bro access tokens found, logging in...");
      // AuthServiceLogin authService = AuthServiceLogin();
      // authService.getRefresh(accessToken, refreshToken).then((loginResponse) {
      //   if (loginResponse.getResult()) {
      //     setState(() {
      //       LoginWindowChangeNotifier().setLoginWindowVisible(false);
      //     });
      //   }
      //   Future.delayed(const Duration(milliseconds: 500), () {
      //     _navigationService.navigateTo(routes.HomeRoute);
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        ),
      ),
    );
  }
}
