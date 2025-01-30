import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/utils/new/utils.dart';
import 'package:brocast/views/sign_in/signin.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/auth/auth_service_login.dart';

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
          },
          onPageFinished: (String url) {
            // TODO: Do something?
            print("page finished, do something?");
          },
          onHttpError: (HttpResponseError error) {
          },
          onWebResourceError: (WebResourceError error) {
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://brocast.nl/broaccess?') || request.url.startsWith('https://www.brocast.nl/broaccess?')) {
              // When we detect the redirect to the worldaccess page
              // We use the worldaccess paramters to log in.
              // and then close the webview.
              webViewController.loadRequest(Uri.parse('about:blank'));
              Uri worldAccessUri = Uri.parse(request.url);
              String? accessToken = worldAccessUri.queryParameters["access_token"];
              String? refreshToken = worldAccessUri.queryParameters["refresh_token"];
              // Use the tokens to immediately refresh the access token
              if (accessToken != null && refreshToken != null) {
                AuthServiceLogin authService = AuthServiceLogin();
                authService.getRefresh(accessToken, refreshToken).then((loginResponse) {
                  if (loginResponse.getResult()) {
                    setState(() {
                      // TODO: Do something?
                      print("Logged in!?");
                    });
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
    BackButtonInterceptor.add(myInterceptor);
    // setState(() {});
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    backButtonFunctionality();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void backButtonFunctionality() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => SignIn(
            key: UniqueKey(),
            showRegister: widget.fromRegister,
        )));
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
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
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft, child: Text("Brocast")),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("Exit Brocast")),
                ]),
          ],
        ),
        body: WebViewWidget(controller: webViewController)
    );
  }
}
