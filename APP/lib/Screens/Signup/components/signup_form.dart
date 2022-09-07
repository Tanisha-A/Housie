import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'dart:convert';

class SignUpForm extends StatelessWidget {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SignUpForm();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(color: Colors.white),
            controller: userNameController,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter username';
              }
              return null;
            },
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.white),
              hintText: "Your username",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: new Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: "Enter password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: new Icon(Icons.lock, color: Colors.blue),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please re-enter password';
                }
                if (passwordController.text != confirmPasswordController.text) {
                  return "Password does not match";
                }

                return null;
              },
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                hintText: "Confirm Password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: new Icon(Icons.lock, color: Colors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () {
              print("click");
              if (_formKey.currentState!.validate()) {
                http
                    .post(Uri.parse("http://localhost:5005/register"),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "username": userNameController.text,
                          "password": passwordController.text,
                          "confirmPassword": confirmPasswordController.text
                        }))
                    .then((value) => print(value.body.toString()));
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
            child: Text(
              "SIGN UP",
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
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
