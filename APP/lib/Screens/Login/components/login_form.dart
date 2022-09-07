import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambola/src/registration.dart';
// import 'package:tambola/src/caller.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../src/hostplayer.dart';
import '../../Signup/signup_screen.dart';
import 'package:http/http.dart' as http;

class MyLoginForm extends StatelessWidget {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  MyLoginForm();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(color: Colors.white),
            controller: userNameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: InputDecoration(
              hintText: "Your username",
              hintStyle: TextStyle(color: Colors.white),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock, color: Colors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: MaterialButton(
              color: Colors.blue,
              onPressed: () async {
                final response =
                    await http.post(Uri.parse("http://localhost:5005/login"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "username": userNameController.text,
                          "password": passwordController.text,
                        }));
                if (LoginResponse.fromJson(jsonDecode(response.body))
                    .allowLogin) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('username', userNameController.text);
                  _navigateToHostplayer(context);
                } else {
                  const snackBar = SnackBar(
                    content: Text('Invalid Username or Password'),
                  );
                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: Text(
                "Login".toUpperCase(),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _navigateToHostplayer(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => Newgame()));
}

void _navigateToRegistration(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => Registration()));
}

class LoginResponse {
  bool allowLogin = false;
  String username = "";

  LoginResponse({this.allowLogin = false, this.username = ""});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    allowLogin = json['allowLogin'];
  }
}
