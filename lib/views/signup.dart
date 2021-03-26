import 'package:brocast/services/auth.dart';
import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;

  Auth auth = new Auth();

  final formKey = GlobalKey<FormState>();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  signUp() {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      auth.signUp(userNameController.text, passwordController.text).then((val) {
        print("$val");
        setState(() {
          isLoading = false;
        });
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Stack(
        children: [
          isLoading ? Container(
                child: Center(
                    child: CircularProgressIndicator())
            ) : Container(),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 150,
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (val) {
                                return val.isEmpty ? "Please provide UserName": null;
                              },
                              controller: userNameController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("username"),
                            ),
                            TextFormField(
                              obscureText: true,
                              validator: (val) {
                                return val.isEmpty ? "Please provide a password": null;
                              },
                              controller: passwordController,
                              style: simpleTextStyle(),
                              decoration: textFieldInputDecoration("password"),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (!isLoading) {
                          signUp();
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

                        child: Text("Sign Up", style: simpleTextStyle()),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Text("Sign Up with Google", style: TextStyle(
                          color: Colors.black,
                          fontSize: 16
                      )),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                        ),
                        ),
                        Text("Login now!", style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline
                        ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}