import 'package:flutter/material.dart';
import 'package:tambola/Screens/Welcome/splash.dart';
import 'src/registration.dart';
import 'src/caller.dart';
//A PROJECT BY TANISHA AND YASH.

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building page again");
    return MaterialApp(
        title: 'TaniYash Housie Game',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/homepage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 80),
                  textStyle: TextStyle(fontSize: 28),
                  primary: Colors.red, //background
                  onPrimary: Colors.black, //foreground
                ),
                child: Text('Start Game'),
                onPressed: () {
                  _navigateToNextScreen(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _navigateToNextScreen(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => Registration()));
}
