import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tambola/src/playerticket.dart';
import '../src/caller.dart';

class Player extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlayerState();
  }
}

class _PlayerState extends State<Player> {
  final TextEditingController gameCodeController = TextEditingController();
  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/homepage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: new BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: new Container(
            decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),

            // children: <Widget>[
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: gameCodeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Code',
                          hintText: 'Code to join',
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.fromLTRB(50, 10, 20, 10)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 60),
                        textStyle: TextStyle(fontSize: 24),
                        primary: Color.fromARGB(255, 169, 62, 58), //background
                        onPrimary: Colors.black, //foreground
                      ),
                      child: Text('Join Game'),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        //Return String
                        prefs.setInt('gameCode', int.parse(gameCodeController.text));
                        _navigateToCaller(context);
                      },
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateToCaller(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Ticket()));
}
