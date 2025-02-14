import 'dart:io';
import 'package:brocast/utils/new/settings.dart';
import 'package:brocast/utils/new/storage.dart';
import 'package:brocast/views/bro_home/bro_home.dart';
import 'package:brocast/views/web_view/web_view_screen.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/base_url.dart';
import '../../services/auth/auth_service_login.dart';
import '../../services/auth/models/login_bro_name_request.dart';
import '../../services/auth/models/login_email_request.dart';
import '../../services/auth/models/register_request.dart';
import '../../utils/new/utils.dart';
import '../../utils/new/secure_storage.dart';

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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      fillFields();
    });
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

  goToBroCastHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BroCastHome(key: UniqueKey())));
  }

  register() async {
    String broNameRegister = broNameController.text.trimRight();
    String bromotionRegister = bromotionController.text;
    String passwordRegister = passwordController.text;
    String emailRegister = emailController.text;

    // This issue should not be possible, but check if the required fields are filled anyway
    if (emailRegister == "" || broNameRegister == "" || bromotionRegister == "" || passwordRegister == "") {
      showToastMessage("Please fill in the email, bro name, bromotion and password field");
      return;
    }
    isLoading = true;
    AuthServiceLogin authService = AuthServiceLogin();
    RegisterRequest registerRequest = RegisterRequest(emailRegister, broNameRegister, bromotionRegister, passwordRegister);
    authService.getRegister(registerRequest).then((loginResponse) {
      if (loginResponse.getResult()) {
        // We securely store information locally on the phone
        secureStorage.setBroName(broNameRegister);
        secureStorage.setBromotion(bromotionRegister);
        secureStorage.setPassword(passwordRegister);
        secureStorage.setEmail(emailRegister);
        isLoading = false;
        goToBroCastHome();
      } else if (!loginResponse.getResult()) {
        showToastMessage(loginResponse.getMessage());
        isLoading = false;
      }
    }).onError((error, stackTrace) {
      showToastMessage(error.toString());
      isLoading = false;
    });
  }

  login() {
    String broNameLogin = broNameController.text.trimRight();
    String bromotionLogin = bromotionController.text;
    String passwordLogin = passwordController.text;
    String emailLogin = emailController.text;

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

    isLoading = true;
    AuthServiceLogin authService = AuthServiceLogin();
    if (loginBroName) {
      LoginBroNameRequest loginBroNameRequest = LoginBroNameRequest(
          broNameLogin, bromotionLogin, passwordLogin);
      authService.getLoginBroName(loginBroNameRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          isLoading = false;
          // We securely store information locally on the phone
          secureStorage.setBroName(broNameLogin);
          secureStorage.setBromotion(bromotionLogin);
          secureStorage.setPassword(passwordLogin);
          goToBroCastHome();
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          isLoading = false;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        isLoading = false;
      });
    } else {
      LoginEmailRequest loginEmailRequest = LoginEmailRequest(
          emailLogin, passwordLogin);
      authService.getLoginEmail(loginEmailRequest).then((loginResponse) {
        if (loginResponse.getResult()) {
          isLoading = false;
          // We securely store information locally on the phone
          secureStorage.setEmail(emailLogin);
          secureStorage.setPassword(passwordLogin);
          goToBroCastHome();
        } else if (!loginResponse.getResult()) {
          showToastMessage(loginResponse.getMessage());
          isLoading = false;
        }
      }).onError((error, stackTrace) {
        showToastMessage(error.toString());
        isLoading = false;
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
                print("TODO: forgot password");
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
                    "BroCast",
                    style: TextStyle(color: Colors.white)
                )),
            actions: [
              PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert, color: getTextColor(Colors.white)),
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
                child: Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: EmojiKeyboard(
                          emojiController: bromotionController,
                          emojiKeyboardHeight: 300,
                          showEmojiKeyboard: showEmojiKeyboard,
                          darkMode: emojiKeyboardDarkMode)),
                ]),
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
    if (Platform.isIOS) {
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
      print("going to sign in");
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      googleAccessToken = googleSignInAuthentication.accessToken;
      print("Google access token: $googleAccessToken");
      if (googleAccessToken == null) {
        isLoading = false;
        showToastMessage("Google login failed");
        return;
      }
    } catch (error) {
      print("google error: $error");
      isLoading = false;
      return;
    }

    AuthServiceLogin().getLoginGoogle(googleAccessToken).then((
        loginResponse) {
      if (loginResponse.getResult()) {
        goToBroCastHome();
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
