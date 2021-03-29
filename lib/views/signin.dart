import 'package:brocast/services/auth.dart';
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
    super.initState();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
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
                      return val.isEmpty ? "Please provide a bro name": null;
                    },
                    controller: broNameController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Bro name"),
                  ),
                  TextFormField(
                    validator: (val) {
                      return val.isEmpty ? "Please provide bromotion": null;
                    },
                    controller: bromotionController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Bromotion"),
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (val) {
                      return val.isEmpty ? "Please provide a password": null;
                    },
                    controller: passwordController,
                    style: simpleTextStyle(),
                    decoration: textFieldInputDecoration("Password"),
                  ),
                ]),
                ),
                SizedBox(height: 8),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text("Forgot Password?", style: simpleTextStyle())
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
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
                        gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC)
                            ]
                        ),
                        borderRadius: BorderRadius.circular(30)
                    ),

                    child: Text("Sign In", style: simpleTextStyle()),
                  ),
                ),
                SizedBox(height: 8),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}