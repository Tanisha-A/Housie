import 'package:flutter/material.dart';
import 'package:tambola/src/caller.dart';
import '../src/player.dart';
import 'host.dart';

// void main() {
//   runApp(MyApp());
// }

class Newgame extends StatefulWidget {
  @override
  _NewgameState createState() => _NewgameState();
}

class _NewgameState extends State<Newgame> {
  @override
  Widget build(BuildContext) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   // title: Text('Housie App'),
        // ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/hostplayer.png"),
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
                    primary: Colors.green, //background
                    onPrimary: Colors.black, //foreground
                  ),
                  child: Text('Player'),
                  onPressed: () {
                    _navigateToPlayer(context);
                  },
                ),
                Padding(padding: const EdgeInsets.fromLTRB(50, 10, 20, 10)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(280, 80),
                    textStyle: TextStyle(fontSize: 28),
                    primary: Colors.blue, //background
                    onPrimary: Colors.black, //foreground
                  ),
                  child: Text('Host'),
                  onPressed: () {
                    _navigateToCaller(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateToPlayer(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Player()));
}

void _navigateToHost(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Host()));
}
void _navigateToCaller(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              HostPlayer()));
}

