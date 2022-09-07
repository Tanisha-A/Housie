import 'dart:collection';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tambola/src/registration.dart';
import 'settingPage.dart';
import 'empty_page.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'provider1.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

int initScreen = 0;

enum TtsState { playing, stopped }

SharedPreferences? pref;

void sharedPrefs() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();
  initScreen = pref!.getInt("initScreen");
  pref?.setInt("initScreen", 1);
  runApp(ChangeNotifierProvider(
      create: (_) => Modes(), child: MaterialApp(home: new HostPlayer())));
}

class HostPlayer extends StatefulWidget {
  HostPlayer();
  @override
  _HostPlayerState createState() => _HostPlayerState();
}

class _HostPlayerState extends State<HostPlayer> {
  FlutterTts flutterTts = new FlutterTts();

  int gameCode = 0;
  var winners = {
    "FirstRow": "---",
    "FourCorner": "---",
    "FullHousie": "---",
    "LastRow": "---",
    "MiddleRow": "---"
  };
  late String mode;
  bool paused = true;
  int gap = -1;
  bool Mode = false;
  var prefs = SharedPreferences.getInstance();
  TtsState ttsState = TtsState.stopped;
  _HostPlayerState();
  String cur = "";
  HashMap mp = new HashMap<int, int>();
  Future _speak(int z) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setSpeechRate(0.4);
    var result;
    if (z < 9)
      result = await flutterTts.speak("Only Number  $z");
    else
      result = await flutterTts.speak("$z");
    if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  // ignore: missing_return

  // ignore: non_constant_identifier_names
  void random_number() {
    num sum = 0;
    for (int i = 0; i < 100; i++) {
      sum += mp[i];
    }
    if (sum == 100) {
      const snackBar = SnackBar(
        content: Text('Game Over !!!!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    var rng = new Random();
    int x;
    try {
      x = 1 + rng.nextInt(100);
    } catch (e) {
      x = 1 + rng.nextInt(100);
    }
    if (mp[x - 1] == 0) {
      _speak(x);
      http.post(
        Uri.parse('http://localhost:5005/updateGameStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{"gameCode": this.gameCode, "number": x}),
      );

      // rng.nextInt(100);

      setState(() {
        mp[x - 1] = 1;
        cur = "$x ";
      });
    } else {
      random_number();
    }
  }

  void init() {
    setState(() {
      paused = true;
    });
    //print(cheatData);
    for (int i = 1; i <= 100; i++) {
      mp[i] = 0;
      setState(() {
        mp[i] = 0;
        cur = "";
      });
    }
  }

  @override
  void initState() {
    sharedPrefs();
    http
        .post(
          Uri.parse('http://localhost:5005/create_game'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{"username": pref!.getString('username')}),
        )
        .then((value) => {
              print("Generating new game code....."),
              print(jsonDecode(value.body)),
              this.gameCode = jsonDecode(value.body)["gameCode"],
              for (int i = 1; i < 100; i++)
                {
                  mp[i] = int.parse(jsonDecode(value.body)["gameStatus"][i]),
                  setState(() {
                    mp[i] = int.parse(jsonDecode(value.body)["gameStatus"][i]);
                    cur = "";
                  })
                }
            });

    Timer timer = new Timer.periodic(
        new Duration(seconds: 5),
        (timer) => {
              http
                  .post(
                    Uri.parse('http://localhost:5005/winnerList'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, int>{"gameID": this.gameCode}),
                  )
                  .then((value) => {
                        setState(
                          () {
                            winners = {
                              "FirstRow":
                                  jsonDecode(value.body)["FirstRow"] ?? "TBD",
                              "FourCorner":
                                  jsonDecode(value.body)["FourCorner"] ?? "TBD",
                              "FullHousie":
                                  jsonDecode(value.body)["FullHousie"] ?? "TBD",
                              "LastRow":
                                  jsonDecode(value.body)["LastRow"] ?? "TBD",
                              "MiddleRow":
                                  jsonDecode(value.body)["MiddleRow"] ?? "TBD"
                            };
                          },
                        )
                      })
            });

    Timer timer2 = new Timer.periodic(
        new Duration(seconds: 5), (timer) => {if (Mode) random_number()});

    try {
      mode = pref!.getString("mode");
    } catch (e) {
      print(e);
      mode = "automatic";
    }
    ;
    print("Coming to init state");
    paused = true;
    super.initState();
    for (int i = 0; i < 100; i++) {
      mp[i] = 0;
      setState(() {
        mp[i] = 0;
        cur = "";
      });
    }
  }

  Color getcolor(int x) {
    if (mp[x] == 1)
      return Color.fromARGB(255, 76, 175, 86);
    else
      return Colors.white;
  }

  getlast(int i) {
    if (mp[i] == 1) {
      return Container(
          padding: EdgeInsets.all(5),
          child: Center(
            child: Text(i.toString(),
                style: TextStyle(
                    color: Color.fromARGB(255, 76, 175, 86), fontSize: 40)),
          ));
    } else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Align(
        alignment: Alignment(0.8, 0.33),
        child: GestureDetector(
          onTap: () {
            http
                .post(
                  Uri.parse('http://localhost:5005/winnerList'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, int>{"gameID": this.gameCode}),
                )
                .then((value) => {
                      setState(
                        () {
                          winners = {
                            "FirstRow":
                                jsonDecode(value.body)["FirstRow"] ?? "TBD",
                            "FourCorner":
                                jsonDecode(value.body)["FourCorner"] ?? "TBD",
                            "FullHousie":
                                jsonDecode(value.body)["FullHousie"] ?? "TBD",
                            "LastRow":
                                jsonDecode(value.body)["LastRow"] ?? "TBD",
                            "MiddleRow":
                                jsonDecode(value.body)["MiddleRow"] ?? "TBD"
                          };
                          print(winners);
                        },
                      )
                    });
          },
          child: Icon(Icons.refresh, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
        color: Colors.grey[900],
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: 50.0,
                    width: double.infinity,
                    child: Text(
                      "Game Code: " + this.gameCode.toString(),
                      style: TextStyle(
                        fontSize: 24.0,
                        fontFamily: "Horizon",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
                SizedBox(

                    height: 50.0,
                    width: double.infinity,
                    child: Row(
                      
                      children: [
                        SizedBox(width: width * 0.38),
                        Text(
                          cur,
                          style: TextStyle(
                            fontSize: 45.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: width * 0.16),
                        Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 28,
                        ),
                        Switch(
                          onChanged: (isON) => {
                            setState(() => {Mode = isON})
                          },
                          value: Mode,
                          activeColor: Colors.green,
                          activeTrackColor: Colors.lightGreen,
                          inactiveThumbColor: Colors.yellow[700],
                          inactiveTrackColor: Colors.yellow,
                        ),
                      ],
                    )),
                // Padding(padding: EdgeInsets.only(bottom: 30.0)),
                Container(
                  height: height * 0.38,
                  width: width * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.blueGrey[900],
                  ),
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                  child: Center(
                    child: GridView.count(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 10,
                      childAspectRatio: width * 0.9 / (height * 0.35),
                      children: <Widget>[
                        for (int i = 0; i < 100; i++)
                          Center(
                            child: Container(
                                child: Text((i + 1).toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: getcolor(i)))),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: random_number,
                        child: Text(
                          "Next",
                          style: TextStyle(color: Colors.white, fontSize: 28),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Winners 🏆",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontFamily: "Horizon",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Container(
                  height: height * 0.28,
                  width: width * 0.94,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Colors.blueGrey[900],
                  ),
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 0),
                  margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
                  child: Center(
                    child: GridView.count(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: width * 0.9 / (height * 0.085),
                      children: [
                        Text(
                          "Objective",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Winner",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Four Corners",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          winners["FourCorner"] ?? "TBD",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "First Row",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          winners["FirstRow"] ?? "TBD",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Middle Row",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          winners["MiddleRow"] ?? "TBD",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Last Row",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          winners["LastRow"] ?? "TBD",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Full Housie",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          winners["FullHousie"] ?? "TBD",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: "Horizon",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
