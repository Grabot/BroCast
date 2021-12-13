import 'dart:async';
import 'dart:convert';
import 'package:brocast/constants/base_url.dart';
import 'package:brocast/objects/user.dart';
import 'package:brocast/services/settings.dart';
import 'package:brocast/utils/notification_util.dart';
import 'package:brocast/utils/shared.dart';
import 'package:brocast/utils/storage.dart';
import 'package:http/http.dart' as http;

class Auth {

  Settings settings = Settings();

  Future signUp(String broName, String bromotion, String password) async {

    String urlRegister = baseUrl_v1_3 + 'register';
    Uri uriRegister = Uri.parse(urlRegister);

    NotificationUtil notificationUtil = NotificationUtil();
    String registrationId = notificationUtil.getFirebaseToken();
    print("sign up $registrationId");

    http.Response responsePost = await http
        .post(
      uriRegister,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'registration_id': registrationId
      }),
    )
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return new http.Response("", 404);
      },
    );

    if (responsePost.body.isEmpty) {
      return "Could not connect to the server";
    } else {
      Map<String, dynamic> registerResponse = jsonDecode(responsePost.body);
      if (registerResponse.containsKey("result") &&
          registerResponse.containsKey("message")) {
        bool result = registerResponse["result"];
        String message = registerResponse["message"];
        if (result) {
          String token = registerResponse["token"];
          int broId = registerResponse["bro"]["id"];
          String broName = registerResponse["bro"]["bro_name"];
          String bromotion = registerResponse["bro"]["bromotion"];

          await storeUser(broId, broName, bromotion, password, token, registrationId);
          return "";
        } else {
          return message;
        }
      }
    }
    return "an unknown error has occurred";
  }

  Future signIn(
      String broName, String bromotion, String password, String token) async {

    String urlLogin = baseUrl_v1_3 + 'login';
    Uri uriLogin = Uri.parse(urlLogin);

    NotificationUtil notificationUtil = NotificationUtil();
    String registrationId = notificationUtil.getFirebaseToken();
    print("sign in $registrationId");

    http.Response responsePost = await http
        .post(
      uriLogin,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'bro_name': broName,
        'bromotion': bromotion,
        'password': password,
        'token': token,
        'registration_id': registrationId
      }),
    )
        .timeout(
      Duration(seconds: 5),
      onTimeout: () {
        return new http.Response("", 404);
      },
    );

    if (responsePost.body.isEmpty) {
      return "Could not connect to the server";
    } else {
      Map<String, dynamic> registerResponse;
      try {
        registerResponse = jsonDecode(responsePost.body);
      } on Exception catch (_) {
        return "an unknown error has occurred";
      }
      if (registerResponse.containsKey("result") &&
          registerResponse.containsKey("message")) {
        bool result = registerResponse["result"];
        String message = registerResponse["message"];
        if (result) {
          String token = registerResponse["token"];
          int broId = registerResponse["bro"]["id"];
          String broName = registerResponse["bro"]["bro_name"];
          String bromotion = registerResponse["bro"]["bromotion"];

          await storeUser(broId, broName, bromotion, password, token, registrationId);
          print("awaited the store user");
          return "";
        } else {
          return message;
        }
      }
    }
    return "an unknown error has occurred";
  }

  setInformation(String token, int broId, String broName, String bromotion,
      String password) async {
    await HelperFunction.setBroToken(token);
    await HelperFunction.setBroId(broId);
    await HelperFunction.setBroInformation(broName, bromotion, password);
  }

  storeUser(int broId, String broName, String bromotion, String password, String token, String registrationId) async {
    User user = new User(broId, broName, bromotion, password, token, registrationId, 1, 0);
    var storage = Storage();
    await storage.selectUser().then((value) async {
      if (value != null) {

        settings.setEmojiKeyboardDarkMode(user.getKeyboardDarkMode());
        settings.setBroId(user.id);
        settings.setBroName(user.broName);
        settings.setBromotion(user.bromotion);
        settings.setToken(user.token);

        print("there seems to be a user, we only want 1 user, update?");
        if (value.broName == user.broName && value.bromotion == user.bromotion) {
          // The same bro logged in.
          // We assume the password didn't change
          // (can be null at this point because of token log in)
          // We assume the bromotion didn't change
          // (would have updated when changed)
          // What could have changed is the token or the registration id
          if (value.password.isEmpty && user.password.isEmpty) {
            // No password is found at all, this is not possible for new users,
            // but it might be possible for users updating the app.
            // The info should be in shared preferences, so we will retrieve it.
            HelperFunction.getBroInformation().then((val) {
              if (val == null || val.length == 0) {
                // big problem if it comes here.
              } else {
                user.password = val[2];
              }
            });
          }
          if (value.password.isEmpty && user.password.isNotEmpty) {
            value.password = user.password;
            print("changed password");
          }
          if (user.token.isNotEmpty && value.token != user.token) {
            value.token = user.token;
            print("changed token");
          }
          if (user.registrationId != null && user.registrationId!.isNotEmpty
              && value.registrationId != user.registrationId) {
            value.registrationId = user.registrationId;
            print("changed registrationid");
          }
          if (value.recheckBros == 0) {
            // If the user logged in the user should retrieve his bros again
            value.recheckBros = 1;
            print("changed recheck");
          }
          print("we are going to update the user!");
          print(value);
          // The token will basically always change when logging in,
          // so we always update the current user.
          storage.updateUser(value).then((value) {
            print("we have updated the user!");
            print(value);
          });
        } else {
          // A different user has logged in.
          await storage.clearDatabase();
          await storage.addUser(user);
        }
      } else {
        // no user yet, probably first time logging in! save the user.
        if (user.password.isEmpty) {
          // This will not happen for new users, but it might happen for older users updating the app.
          print("was password empty?");
          HelperFunction.getBroInformation().then((val) {
            if (val == null || val.length == 0) {
              // big problem if it comes here.
            } else {
              user.broName = val[0];
              user.bromotion = val[1];
              user.password = val[2];
            }
          });
        }
        print("storing new user $user");
        await storage.addUser(user);
      }
    });

  }

  Future<bool> signInUser(User user) {
    return this.signIn("", "", "", user.token).then((val) {
      if (val.toString() == "") {
        return true;
      } else {
        if (val == "The given credentials are not correct!") {
          // token didn't work, going to check if a username is given and try to log in using password username
          if (user.broName.isNotEmpty && user.bromotion.isNotEmpty && user.password.isNotEmpty) {
            return signInName(user.broName, user.bromotion, user.password);
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    });
  }

  Future<bool> signInName(String broName, String bromotion, String password) {
    return signIn(broName, bromotion, password, "").then((val) {
      if (val.toString() == "") {
        return true;
      } else {
        return false;
      }
    });
  }

}
