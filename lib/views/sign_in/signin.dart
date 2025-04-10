import 'dart:io';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/web_view/web_view_screen.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/base_url.dart';
import '../../services/auth/auth_service_login.dart';
import '../../services/auth/auth_service_social.dart';
import '../../services/auth/models/login_bro_name_request.dart';
import '../../services/auth/models/login_email_request.dart';
import '../../services/auth/models/register_request.dart';
import '../../utils/utils.dart';
import '../../utils/secure_storage.dart';

class SignIn extends StatefulWidget {

  final bool showRegister;

  SignIn({
    required Key key,
    required this.showRegister
  }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  bool showEmojiKeyboard = false;

  Settings settings = Settings();

  final formKey = GlobalKey<FormState>();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  ScrollController signScrollController = ScrollController();
  FocusNode focusBromotion = FocusNode();
  FocusNode focusEmail = FocusNode();
  FocusNode focusBroname = FocusNode();

  bool emojiKeyboardDarkMode = false;

  late Storage storage;

  bool loginBroName = true;
  bool signUpMode = false;

  SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    if (widget.showRegister) {
      signUpMode = true;
    }
    bromotionController.addListener(bromotionListener);

    storage = Storage();

    setState(() {
      emojiKeyboardDarkMode = settings.getEmojiKeyboardDarkMode();
    });

    NotificationController.requestFirebaseToken();
    NotificationController.requestPermission();

    // We're adding listeners to the focusnodes to keep these widgets in view
    focusEmail.addListener(() {
      Future.delayed(Duration(milliseconds: 600)).then((value) {
        if (signScrollController.hasClients) {
          if (focusEmail.hasFocus) {
            signScrollController.animateTo(
                150,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut);
          }
        }
      });
    });
    focusBroname.addListener(() {
      Future.delayed(Duration(milliseconds: 600)).then((value) {
        if (signScrollController.hasClients) {
          if (focusBroname.hasFocus) {
            signScrollController.animateTo(
                150,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut);
          }
        }
      });
    });
    focusBromotion.addListener(() {
      Future.delayed(Duration(milliseconds: 600)).then((value) {
        if (signScrollController.hasClients) {
          if (focusBromotion.hasFocus) {
            signScrollController.animateTo(
                150,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut);
          }
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
      fillFields();
    }));
    super.initState();
  }

  fillFields() async {
    String? broName = await secureStorage.getBroName();
    String? bromotion = await secureStorage.getBromotion();
    String? password = await secureStorage.getPassword();
    String? email = await secureStorage.getEmail();
    if (broName != null) {
      broNameController.text = broName;
    }
    if (bromotion != null) {
      bromotionController.text = bromotion;
    }
    if (password != null) {
      passwordController.text = password;
    }
    if (email != null) {
      emailController.text = email;
    }
  }

  bromotionListener() {
    bromotionController.selection =
        TextSelection.fromPosition(TextPosition(offset: 0));
    String fullText = bromotionController.text;
    String lastEmoji = fullText.characters.skip(1).string;
    if (lastEmoji != "") {
      String newText = bromotionController.text.replaceFirst(lastEmoji, "");
      bromotionController.text = newText;
    }
  }

  backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      exitApp();
    }
  }

  exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }

  void onTapTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onTapEmojiField() {
    if (!showEmojiKeyboard) {
      // We add a quick delay, this is to ensure that the keyboard is gone at this point.
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  @override
  void dispose() {
    bromotionController.addListener(bromotionListener);
    broNameController.dispose();
    emailController.dispose();
    bromotionController.dispose();
    passwordController.dispose();
    super.dispose();
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

  goToBrocastHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BrocastHome(key: UniqueKey())));
  }

  register() async {
    String broNameRegister = broNameController.text.trimRight();
    String bromotionRegister = bromotionController.text;
    String passwordRegister = passwordController.text;
    String emailRegister = emailController.text.trimRight();

    // This issue should not be possible, but check if the required fields are filled anyway
    if (emailRegister == "" || broNameRegister == "" || bromotionRegister == "" || passwordRegister == "") {
      showToastMessage("Please fill in the email, bro name, bromotion and password field");
      return;
    }
    setState(() {
      isLoading = true;
      showEmojiKeyboard = false;
    });
    AuthServiceLogin authService = AuthServiceLogin();
    // We get the FCM token to send it to the server with the registration
    String FCMToken = NotificationController().firebaseTokenDevice;
    // String? FCMToken = "";
    int platform = Platform.isAndroid ? 0 : 1;
    RegisterRequest registerRequest = RegisterRequest(emailRegister, broNameRegister, bromotionRegister, passwordRegister, FCMToken, platform);
    authService.getRegister(registerRequest).then((loginResponse) {
      if (loginResponse.getResult()) {
        // We securely store information locally on the phone
        // TODO: doen we dit zo bewaren? Denk ik niet nodig?
        secureStorage.setBroName(broNameRegister);
        secureStorage.setBromotion(bromotionRegister);
        secureStorage.setPassword(passwordRegister);
        secureStorage.setEmail(emailRegister);
        setState(() {
          isLoading = false;
        });
        goToBrocastHome();
      } else if (!loginResponse.getResult()) {
        showToastMessage(loginResponse.getMessage());
        setState(() {
          isLoading = false;
        });
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
      setState(() {
        isLoading = false;
      });
    });
  }

  login() {
    String broNameLogin = broNameController.text.trimRight();
    String bromotionLogin = bromotionController.text;
    String passwordLogin = passwordController.text;
    String emailLogin = emailController.text.trimRight();

    if (loginBroName) {
      // This issue should not be possible, but check if the required fields are filled anyway
      if (broNameLogin == "" || bromotionLogin == "" || passwordLogin == "") {
        showToastMessage("Please fill in the bro name, bromotion and password field");
        return;
      }
    } else {
      if (emailLogin == "" || passwordLogin == "") {
        showToastMessage("Please fill in the email and password field.");
        return;
      }
    }
    setState(() {
      isLoading = true;
      showEmojiKeyboard = false;
    });
    AuthServiceLogin authService = AuthServiceLogin();
    if (loginBroName) {
      int platform = Platform.isAndroid ? 0 : 1;
      LoginBroNameRequest loginBroNameRequest = LoginBroNameRequest(
          broNameLogin, bromotionLogin, passwordLogin, platform);
      authService.getLoginBroName(loginBroNameRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          setState(() {
            isLoading = false;
          });

          NotificationController().getFCMTokenNotificationUtil(loginResponse.getFCMToken());
          int platform = Platform.isAndroid ? 0 : 1;
          if (loginResponse.getPlatform() != null && platform != loginResponse.getPlatform()) {
            AuthServiceSocial().updatePlatform(platform);
          }

          // We securely store information locally on the phone
          secureStorage.setBroName(broNameLogin);
          secureStorage.setBromotion(bromotionLogin);
          secureStorage.setPassword(passwordLogin);
          goToBrocastHome();
          // We also update the FCM token
          // We only do that here, if the user logs in via tokens we don't
          // check the FCM token since it will probably be the same.
          // We assume that getting the local fcm token was set

        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          setState(() {
            isLoading = false;
          });
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        setState(() {
          isLoading = false;
        });
      });
    } else {
      int platform = Platform.isAndroid ? 0 : 1;
      LoginEmailRequest loginEmailRequest = LoginEmailRequest(
          emailLogin, passwordLogin, platform);
      authService.getLoginEmail(loginEmailRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          setState(() {
            isLoading = false;
          });

          NotificationController().getFCMTokenNotificationUtil(loginResponse.getFCMToken());
          int platform = Platform.isAndroid ? 0 : 1;
          if (loginResponse.getPlatform() != null && platform != loginResponse.getPlatform()) {
            AuthServiceSocial().updatePlatform(platform);
          }

          // We securely store information locally on the phone
          secureStorage.setEmail(emailLogin);
          secureStorage.setPassword(passwordLogin);
          goToBrocastHome();
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          setState(() {
            isLoading = false;
          });
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  signInForm() {
    // The form only validates the fields that are in view.
    if (formKey.currentState!.validate()) {
      if (signUpMode) {
        register();
      } else {
        login();
      }
    }
  }

  Widget broNameTextField() {
    return Expanded(
      child: TextFormField(
        focusNode: focusBroname,
        onTap: () {
          if (!isLoading) {
            onTapTextField();
          }
        },
        validator: (val) {
          return val == null || val.isEmpty
              ? "Please provide your bro name"
              : null;
        },
        controller: broNameController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(),
        decoration: textFieldInputDecoration("Bro name"),
      ),
    );
  }

  Widget bromotionTextField() {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        focusNode: focusBromotion,
        onTap: () {
          if (!isLoading) {
            onTapEmojiField();
          }
        },
        validator: (val) {
          return val == null || val.trim().isEmpty
              ? "😢?😄!"
              : null;
        },
        controller: bromotionController,
        style: simpleTextStyle(),
        textAlign: TextAlign.center,
        decoration: textFieldInputDecoration("😀"),
        readOnly: true,
        showCursor: true,
      ),
    );
  }

  Widget broNameAndBromotionInputField() {
    return Row(
      children: [
        SizedBox(width: 20),
        broNameTextField(),
        SizedBox(width: 20),
        bromotionTextField(),
        SizedBox(width: 20),
      ],
    );
  }

  Widget emailTextField() {
    return Expanded(
      child: TextFormField(
        focusNode: focusEmail,
        onTap: () {
          if (!isLoading) {
            onTapTextField();
          }
        },
        validator: (val) {
          if (val != null) {
            if (!emailValid(val)) {
              return "Email not formatted correctly";
            }
          }
          return val == null || val.isEmpty
              ? "Please provide an Email"
              : null;
        },
        controller: emailController,
        textAlign: TextAlign.center,
        style: simpleTextStyle(),
        decoration: textFieldInputDecoration("Email"),
      ),
    );
  }

  Widget emailInputField() {
    return Row(
      children: [
        SizedBox(width: 20),
        emailTextField(),
        SizedBox(width: 20),
      ],
    );
  }

  Widget switchBroNameEmail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          onTap: () {
            if (!isLoading) {
              setState(() {
                loginBroName = !loginBroName;
              });
            }
          },
          child: Row(
            children: [
              loginBroName ? Text(
                "Switch to email",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ) : Text(
                "Switch to Bro name",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
              Icon(Icons.sync, color: Colors.green),
            ]
          ),
        ),
      ],
    );
  }

  Widget passwordInputField() {
    return Row(
      children:
      [
        SizedBox(width: 20),
        Expanded(
          child: TextFormField(
            onTap: () {
              if (!isLoading) {
                onTapTextField();
              }
            },
            obscureText: true,
            validator: (val) {
              return val == null || val.isEmpty
                  ? "Please provide a password"
                  : null;
            },
            controller: passwordController,
            textAlign: TextAlign.center,
            style: simpleTextStyle(),
            decoration: textFieldInputDecoration("Password"),
          ),
        ),
        SizedBox(width: 20),
      ]
    );
  }

  Widget forgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          onTap: () {
            if (!isLoading) {
              setState(() {
                // TODO: forgot password
              });
            }
          },
          child: Row(
              children: [
                Text(
                  "Forgot password?",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ]
          ),
        ),
      ],
    );
  }

  Widget signInButton() {
    return GestureDetector(
      onTap: () {
        if (!isLoading) {
          signInForm();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xBf007EF4),
              const Color(0xff2A75BC)
            ]),
            borderRadius: BorderRadius.circular(30)),
        child: signUpMode
            ? Text("Register",
            style: simpleTextStyle())
            : Text("Login",
            style: simpleTextStyle()),
      ),
    );
  }

  Widget switchLoginRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: signUpMode
              ? Text(
            "Already have an account?  ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16),
          )
              : Text(
            "Don't have an account?  ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!isLoading) {
                setState(() {
                  signUpMode = !signUpMode;
                });
              }
            },
            child: signUpMode
                ? Text(
              "Login now!",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration:
                  TextDecoration.underline),
            ) : Text(
              "Register now!",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration:
                  TextDecoration.underline),
            ),
          ),
        )
      ],
    );
  }

  Widget loginView() {
    return Column(
      children: [
        loginBroName
            ? broNameAndBromotionInputField()
            : emailInputField(),
        switchBroNameEmail(),
        passwordInputField(),
        SizedBox(height:10),
        forgotPassword(),
      ],
    );
  }

  Widget registerView() {
    return Column(
      children: [
        broNameAndBromotionInputField(),
        emailInputField(),
        passwordInputField(),
      ],
    );
  }

  Widget dividerLogin() {
    return Row(
        children: [
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                child: const Divider(
                  color: Colors.white,
                  height: 36,
                )),
          ),
          !signUpMode ? Text(
            "or login with",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
          ) : Text(
            "or register with",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
          ),
          Expanded(
            child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                child: const Divider(
                  color: Colors.white,
                  height: 36,
                )),
          ),
        ]
    );
  }

  Widget loginAlternatives() {
    double totalWidth = MediaQuery.of(context).size.width;
    // Remove the padding from both sides.
    totalWidth -= 20*2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
            children: [
              InkWell(
                onTap: () {
                  _handleSignInGoogle();
                },
                child: SizedBox(
                  height: totalWidth/5,
                  width: totalWidth/5,
                  child: Image.asset(
                      "assets/images/google_button.png"
                  ),
                ),
              ),
              Text(
                "Google",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              )
            ]
        ),
        const SizedBox(width: 10),
        Column(
            children: [
              InkWell(
                onTap: () {
                  _handleSignInApple();
                },
                child: SizedBox(
                  height: totalWidth/5,
                  width: totalWidth/5,
                  child: Image.asset(
                      "assets/images/apple_button.png"
                  ),
                ),
              ),
              Text(
                "Apple",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              )
            ]
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            InkWell(
              onTap: () {
                final Uri url = Uri.parse(githubLogin);
                _launchUrl(url);
              },
              child: SizedBox(
                height: totalWidth/5,
                width: totalWidth/5,
                child: Image.asset(
                    "assets/images/github_button.png"
                ),
              ),
            ),
            Text(
              "Github",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            )
          ],
        ),
        const SizedBox(width: 10),
        Column(
            children: [
              InkWell(
                onTap: () {
                  final Uri url = Uri.parse(redditLogin);
                  _launchUrl(url);
                },
                child: SizedBox(
                  height: totalWidth/5,
                  width: totalWidth/5,
                  child: Image.asset(
                      "assets/images/reddit_button.png"
                  ),
                ),
              ),
              Text(
                "Reddit",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              )
            ]
        ),
      ],
    );
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
            title: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Brocast Sign In",
                    style: TextStyle(color: Colors.white)
                )),
            actions: [
              PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (item) => onSelect(context, item),
                  itemBuilder: (context) => [
                        PopupMenuItem<int>(value: 0, child: Text("Exit Brocast")),
                      ]),
            ],
          ),
          body: Stack(children: [
              isLoading
                  ? Container(child: Center(child: CircularProgressIndicator()))
                  : Container(),
              Container(
                child: Column(
                    children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: signScrollController,
                      reverse: true,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                        "assets/images/brocast_transparent.png")
                                ),
                                Form(
                                  key: formKey,
                                  child: Column(
                                    children: [
                                      signUpMode ? registerView() : loginView(),
                                      SizedBox(height: 20),
                                      switchLoginRegister(),
                                      SizedBox(height: 20),
                                      signInButton(),
                                      SizedBox(height:10),
                                      dividerLogin(),
                                      SizedBox(height:10),
                                      loginAlternatives()
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                      ),
                    ),
                  ),
                  !showEmojiKeyboard ? SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  ) : Container(),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: EmojiKeyboard(
                          emojiController: bromotionController,
                          emojiKeyboardHeight: 350,
                          showEmojiKeyboard: showEmojiKeyboard,
                          darkMode: emojiKeyboardDarkMode)
                  ),
                ]
                ),
              ),
            ]),
          ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (kIsWeb) {
      if (!await launchUrl(
          url,
          webOnlyWindowName: '_self'
      )) {
        throw 'Could not launch $url';
      }
    } else {
      // Go to the webview
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewScreen(
                      key: UniqueKey(),
                      fromRegister: signUpMode,
                      url: url
                  )));
    }
  }

  Future<void> _handleSignInApple() async {
    String appleLogin = "$appleLoginUrl?response_type=code&client_id=$appleClientId&redirect_uri=$appleRedirectUri&scope=email%20name&state=random_generated_state&response_mode=form_post";
    Uri url = Uri.parse(appleLogin);
    print("webview with url: $url");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                WebViewScreen(
                    key: UniqueKey(),
                    fromRegister: signUpMode,
                    url: url
                )));
    return;
  }

  Future<void> _handleSignInGoogle() async {

    isLoading = true;
    const List<String> scopes = <String>[
      'email',
    ];

    GoogleSignIn googleSignIn;
    if (kIsWeb) {
      // Web
      googleSignIn = GoogleSignIn(
        clientId: clientIdLoginWeb,
        scopes: scopes,
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // IOS
      googleSignIn = GoogleSignIn(
        clientId: clientIdLoginIOS,
        scopes: scopes,
      );
    } else {
      // Android
      googleSignIn = GoogleSignIn(
        scopes: scopes,
      );
    }

    String? googleAccessToken;
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      googleAccessToken = googleSignInAuthentication.accessToken;
    } catch (error) {
      isLoading = false;
      return;
    }

    if (googleAccessToken == null) {
      isLoading = false;
      showToastMessage("Google login failed");
      return;
    }

    AuthServiceLogin().getLoginGoogle(googleAccessToken).then((
        loginResponse) {
      if (loginResponse.getResult()) {
        NotificationController().getFCMTokenNotificationUtil(loginResponse.getFCMToken());
        int platform = Platform.isAndroid ? 0 : 1;
        if (loginResponse.getPlatform() != null && platform != loginResponse.getPlatform()) {
          AuthServiceSocial().updatePlatform(platform);
        }
        goToBrocastHome();
        setState(() {
          isLoading = false;
        });
      } else if (!loginResponse.getResult()) {
        showToastMessage(loginResponse.getMessage());
        setState(() {
          isLoading = false;
        });
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
      setState(() {
        isLoading = false;
      });
    });
  }
}
