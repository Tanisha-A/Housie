import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../Screens/Login/components/login_form.dart';
import '../Screens/Login/login_screen.dart';
import '../Screens/Signup/components/signup_form.dart';
import '../Screens/Signup/signup_screen.dart';
import '../src/playerticket.dart';

class Registration extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationState();
  }
}

class _RegistrationState extends State<Registration> {
  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey[900],
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/illustration.jpeg'))),
                  ),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      _navigateToLOGIN(context);
                    },
                    color: Colors.indigoAccent[400],
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(40)),
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white70),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(50, 10, 20, 10)),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      _navigateToSIGNUP(context);
                    },
                    color: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    child: Text(
                      "Sign UP",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _navigateToSIGNUP(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => SignUpScreen()));
}

void _navigateToLOGIN(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => LoginScreen()));
}
