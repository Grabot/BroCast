import 'dart:io';

import 'package:brocast/utils/start_login.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/sign_in/signin.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/auth/auth_service_login.dart';
import '../../utils/notification_controller.dart';
import '../../utils/secure_storage.dart';
import '../bro_home/bro_home.dart';

class WebViewScreen extends StatefulWidget {
  final bool fromRegister;
  final Uri url;
  WebViewScreen({
    required Key key,
    required this.fromRegister,
    required this.url
  }) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  late WebViewController webViewController;

  @override
  void initState() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {
            print("on page started: ${url}");
          },
          onPageFinished: (String url) {
            print("on page finished: ${url}");
          },
          onHttpError: (HttpResponseError error) {
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            print("WebView navigation request: ${request.url}");
            if (request.url.startsWith('https://brocast.nl/broaccess?') || request.url.startsWith('https://www.brocast.nl/broaccess?')) {
              // When we detect the redirect to the broaccess page
              // We use the broaccess paramters to log in.
              // and then close the webview.
              webViewController.loadRequest(Uri.parse('about:blank'));
              Uri broAccessUri = Uri.parse(request.url);
              String? accessToken = broAccessUri.queryParameters["access_token"];
              String? refreshToken = broAccessUri.queryParameters["refresh_token"];
              // Use the tokens to immediately refresh the access token
              if (accessToken != null && refreshToken != null) {
                AuthServiceLogin authService = AuthServiceLogin();
                authService.getRefreshOAuth(accessToken, refreshToken).then((loginResponse) {
                  if (loginResponse.getResult()) {
                    NotificationController().getFCMTokenNotificationUtil(loginResponse.getFCMToken());
                    // user logged in, so go to the home screen
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BrocastHome(key: UniqueKey())));
                  } else {
                    showToastMessage("Failed to log in.");
                  }
                });
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    webViewController.loadRequest(widget.url);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SignIn(
              key: UniqueKey(),
              showRegister: widget.fromRegister
          )
      ),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        backButtonFunctionality();
        break;
      case 1:
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else {
          exit(0);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff145C9E),
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  backButtonFunctionality();
                }),
            title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Brocast Login",
                    style: TextStyle(color: Colors.white)
                )),
            actions: [
              PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (item) => onSelect(context, item),
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(value: 0, child: Text("Back to Sign In")),
                    PopupMenuItem<int>(value: 1, child: Text("Exit Brocast")),
                  ]),
            ],
          ),
          body: WebViewWidget(controller: webViewController)
      ),
    );
  }
}
