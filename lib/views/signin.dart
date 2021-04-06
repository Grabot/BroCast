import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:brocast/emoji/keyboard/custom_keyboard.dart';
import 'package:brocast/services/auth.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/broHome.dart';
import 'package:brocast/views/signup.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool isLoading = false;
  bool showEmojiKeyboard = false;

  Auth auth = new Auth();

  final formKey = GlobalKey<FormState>();
  TextEditingController broNameController = new TextEditingController();
  TextEditingController bromotionController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void initState() {
    HelperFunction.getBroToken().then((val) {
      if (val == null) {
        print("no token yet, wait until a token is saved");
      } else {
        signIn(val.toString());
      }
    });
    BackButtonInterceptor.add(myInterceptor);
    super.initState();
  }

  void onTapTextField() {
    print("Tapped the text field");
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void onTapEmojiField() {
    print("Tapped the emoji field");
    if (!showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = true;
      });
    }
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  signInForm() {
    if (formKey.currentState.validate()) {
      signIn("");
    }
  }

  signIn(String token) {
    setState(() {
      isLoading = true;
    });

    auth.signIn(broNameController.text, bromotionController.text, passwordController.text, token).then((val) {
      print("$val");
      if (val.toString() == "") {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => BroCastHome()
        ));
      } else {
        ShowToastComponent.showDialog(val.toString(), context);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  void _insertText(String myText) {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    final myTextLength = myText.length;
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: textSelection.start + myTextLength,
      extentOffset: textSelection.start + myTextLength,
    );
  }

  void _backspace() {
    final text = bromotionController.text;
    final textSelection = bromotionController.selection;
    final selectionLength = textSelection.end - textSelection.start;  // There is a selection.
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      bromotionController.text = newText;
      bromotionController.selection = textSelection.copyWith(
        baseOffset: textSelection.start,
        extentOffset: textSelection.start,
      );
      return;
    }  // The cursor is at the beginning.
    if (textSelection.start == 0) {
      return;
    }  // Delete the previous character
    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    bromotionController.text = newText;
    bromotionController.selection = textSelection.copyWith(
      baseOffset: newStart,
      extentOffset: newStart,
    );
  }bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      // TODO: @Skools check if this is really needed (without it the emoji keyboard jumps on top of the other for a split second)
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          isLoading ? Container(
              child: Center(
                  child: CircularProgressIndicator())
          ) : Container(),
          Container(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Container(
                              height: 120.0,
                              width: 120.0,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/brocast_transparent.png'),
                                  fit: BoxFit.fill,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 100),
                            TextFormField(
                              onTap: () {
                                onTapTextField();
                              },
                              validator: (val) {
                                return val.isEmpty ? "Please provide a bro name": null;
                              },
                              controller: broNameController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("Bro name"),
                            ),
                            TextFormField(
                              onTap: () {
                                onTapEmojiField();
                              },
                              validator: (val) {
                                return val.isEmpty ? "Please provide bromotion": null;
                              },
                              controller: bromotionController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("Bromotion"),
                              readOnly: true,
                              showCursor: true,
                            ),
                            TextFormField(
                              onTap: () {
                                onTapTextField();
                              },
                              obscureText: true,
                              validator: (val) {
                                return val.isEmpty ? "Please provide a password": null;
                              },
                              controller: passwordController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("Password"),
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                if (!isLoading) {
                                  signIn("");
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          const Color(0xBf007EF4),
                                          const Color(0xff2A75BC)
                                        ]
                                    ),
                                    borderRadius: BorderRadius.circular(30)
                                ),
                                child: Text("Sign In", style: simpleTextStyle()),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account? ", style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16
                                ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (!isLoading) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(
                                          builder: (context) => SignUp()
                                      ));
                                    }
                                  },
                                  child: Text("Register now!", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      decoration: TextDecoration.underline
                                  ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 100),
                          ],
                        )
                    ),
                  ),
                ),
              ),
              showEmojiKeyboard ?
                Container(
                  alignment: Alignment.bottomCenter,
                  child: CustomKeyboard(
                    onTextInput: (myText) {
                      _insertText(myText);
                    },
                    onBackspace: () {
                      _backspace();
                    },
                  ),
                ) : Container()
            ]),
          ),
        ]
      )
    );
  }
}