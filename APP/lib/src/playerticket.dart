import 'dart:collection';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'provider1.dart';
import 'player.dart';

int initScreen = 0;

enum TtsState { playing, stopped }

SharedPreferences? pref;

void sharedPrefs() async {
  WidgetsFlutterBinding.ensureInitialized();
  pref = await SharedPreferences.getInstance();
  initScreen = pref!.getInt("initScreen");
  pref?.setInt("initScreen", 1);
  runApp(
    ChangeNotifierProvider(
      create: (_) => Modes(),
      child: MaterialApp(home: Ticket()),
    ),
  );
}

class Ticket extends StatefulWidget {
  @override
  _TicketState createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  List ticket_nos = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];
  FlutterTts flutterTts = new FlutterTts();
  String game_status =
      "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  late String mode;
  bool paused = true;
  int gap = -1;

  TtsState ttsState = TtsState.stopped;

  _TicketState();
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  HashMap mp = new HashMap<int, int>();
  List buttonStatus = [0, 0, 0, 0, 0];
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
  void init() {
    setState(() {
      paused = true;
    });
    
  }

  @override
  void initState() {
    sharedPrefs();
    paused = true;
    super.initState();
    Timer timer = new Timer.periodic(new Duration(seconds: 5), (timer) {
      print("Fetching Latest Game Updates");
      http
          .post(Uri.parse("http://localhost:5005/getGameStatus"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"gameCode": pref!.getInt("gameCode")}))
          .then((value) => {
                setState((() => {
                      this.game_status =
                          GameStatus.fromJson(jsonDecode(value.body))
                              .game_status,
                    }))
              });
    });
    http
        .post(Uri.parse("http://localhost:5005/join_game_with_code"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "username": pref!.getString("username"),
              "game_id": pref!.getInt("gameCode")
            }))
        .then((value) => {
              this.ticket_nos =
                  TicketData.fromJson(jsonDecode(value.body)).ticket_nos,
              setState(() => {})
            });

    _refresh(true);
  }

  Color getcolor(int x) {
    if (mp[x] == 1)
      return Colors.green;
    else
      return Colors.white;
  }

  Color getButtoncolor(int x, int b) {
    if (x == 1 && buttonStatus[b] == 1) return Colors.green;
    if (x == 1 && buttonStatus[b] == 2)
      return Colors.red;
    else if (x == 1)
      return Colors.yellow;
    else
      return Colors.blueGrey;
  }

  Color getGamecolor(int x) {
    if (game_status[x] == '1')
      return Colors.green;
    else
      return Colors.white;
  }

  void registerObjective(String obj, int x, int b) async {
    if (x == 1 && buttonStatus[b] < 1) {
      http.Response response =
          await http.post(Uri.parse("http://localhost:5005/registerWinner"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "gameID": pref!.getInt("gameCode"),
                "username": pref!.getString("username"),
                "objective": obj
              }));

      String msg = jsonDecode(response.body)['msg'] ??
          "An error occured while registering this objective";

      if (jsonDecode(response.body)['registered']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You secured this Objective, Congratulations!"),
        ));
        setState(() {
          this.buttonStatus[b] = 1;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Another Player secured this objective before you :("),
        ));
        setState(() {
          this.buttonStatus[b] = 2;
        });
      }
    }
  }

  getlast(int i) {
    if (mp[i] == 1) {
      return Container(
          padding: EdgeInsets.all(5),
          child: Center(
            child: Text(i.toString(),
                style: TextStyle(color: Colors.white, fontSize: 40)),
          ));
    } else
      return Container();
  }

  Future<void> _refresh(redirect) async {
    try {
      await http
          .post(Uri.parse("http://localhost:5005/getGameStatus"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"gameCode": pref!.getInt("gameCode")}))
          .then((value) => {
                if (jsonDecode(value.body)["status"] == "Failure")
                  {throw Exception("Invalid Game Code")},
                setState((() => {
                      this.game_status =
                          GameStatus.fromJson(jsonDecode(value.body))
                              .game_status,
                      // this.game_status ??=
                      //     "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
                    }))
              });
    } catch (e) {
      if (redirect) {
        _navigateToJoinGame(context);
      }
      const snackBar = SnackBar(
        content: Text('Could not join this game, Please check the game code'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Future.delayed(Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RefreshIndicator(
        edgeOffset: 200,
        backgroundColor: Colors.blueGrey[900],
        color: Colors.white,
        onRefresh: () => _refresh(false),
        child: SingleChildScrollView(
          child: Container(
            height: height * 1.1,
            color: Colors.grey[900],
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 75.0,
                    width: double.infinity,
                  ),
                  Text(
                    "Game Board",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Horizon",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: height * 0.35,
                    width: width * 0.95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Colors.blueGrey[900],
                    ),
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    margin: EdgeInsets.fromLTRB(5, 10, 5, 20),
                    child: Center(
                      child: GridView.count(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 10,
                        childAspectRatio: width * 0.9 / (height * 0.30),
                        children: <Widget>[
                          for (int i = 0; i < 100; i++)
                            Center(
                              child: Container(
                                  child: Text((i + 1).toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: getGamecolor(i)))),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Ticket",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Horizon",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                      height: height * 0.17,
                      width: width * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Colors.blueGrey[900],
                      ),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Center(
                        child: Container(
                            child: GridView.count(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 9,
                          childAspectRatio: width * 0.9 / (height * 0.45),
                          children: <Widget>[
                            for (int i = 0; i < 27; i++) //for inline
                              Center(
                                child: GestureDetector(
                                  onTap: () => {
                                    if (game_status[this.ticket_nos[i] - 1] ==
                                        '1')
                                      {
                                        setState((() => {mp[i] = 1}))
                                      }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: this.ticket_nos[i] != 0
                                            ? getcolor(i)
                                            : Colors.yellow,
                                      ),
                                    ),
                                    child: Text(
                                      this.ticket_nos[i] != 0
                                          ? this.ticket_nos[i] < 10
                                              ? "0" +
                                                  this.ticket_nos[i].toString()
                                              : this.ticket_nos[i].toString()
                                          : ' X ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: this.ticket_nos[i] != 0
                                            ? getcolor(i)
                                            : Colors.yellow,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )),
                      )),
                  SizedBox(height: 20),
                  Text(
                    "Objectives",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Horizon",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      color: Colors.blueGrey[900],
                    ),
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fullscreen_outlined, size: 43),
                          color: getButtoncolor(
                              checkFourCorners(this.ticket_nos, this.mp), 0),
                          onPressed: (() => {
                                registerObjective(
                                    "w_4c",
                                    checkFourCorners(this.ticket_nos, this.mp),
                                    0)
                              }),
                          // size: 40.0,
                        ),
                        IconButton(
                          icon: const Icon(Icons.border_top_outlined, size: 40),
                          color: getButtoncolor(
                              checkFirstRow(this.ticket_nos, this.mp), 1),
                          onPressed: (() => {
                                registerObjective("w_r1",
                                    checkFirstRow(this.ticket_nos, this.mp), 1)
                              }),
                          // size: 40.0,
                        ),
                        IconButton(
                          icon: const Icon(Icons.border_horizontal_outlined,
                              size: 40),
                          color: getButtoncolor(
                              checkMiddleRow(this.ticket_nos, this.mp), 2),
                          onPressed: (() => {
                                registerObjective("w_r2",
                                    checkMiddleRow(this.ticket_nos, this.mp), 2)
                              }),
                          // size: 40.0,
                        ),
                        IconButton(
                          icon: const Icon(Icons.border_bottom_outlined,
                              size: 42),
                          color: getButtoncolor(
                              checkLastRow(this.ticket_nos, this.mp), 3),
                          onPressed: (() => {
                                registerObjective("w_r3",
                                    checkLastRow(this.ticket_nos, this.mp), 3)
                              }),
                          // size: 40.0,
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu_outlined, size: 42),
                          color: getButtoncolor(
                              checkFullHousie(this.ticket_nos, this.mp), 4),
                          onPressed: (() => {
                                registerObjective(
                                    "w_fh",
                                    checkFullHousie(this.ticket_nos, this.mp),
                                    4)
                              }),
                          // size: 40.0,
                        ),
                      ],
                    ),
                  ),
                  FlatButton(
                      autofocus: true,
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Colors.transparent.withOpacity(0.6),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                      size: 30,
                                    ))
                              ],
                              content: Container(
                                  height: height,
                                  width: width,
                                  child: ListView.builder(
                                      itemCount: 100,
                                      itemBuilder: (context, i) {
                                        return getlast(i + 1);
                                      })),
                            );
                          }),
                      child: Text("Last numbers",
                          style: TextStyle(color: Colors.white, fontSize: 20))),
                  FlatButton(
                      autofocus: true,
                      onPressed: () {
                        exit(0);
                      },
                      child: Text("Quit Game",
                          style: TextStyle(color: Colors.white, fontSize: 20))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TicketData {
  String status = "";
  List ticket_nos = List.empty();

  TicketData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    ticket_nos = json['ticket'];
  }
}

class GameStatus {
  String game_status =
      "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  String status = "Success";

  GameStatus.fromJson(Map<String, dynamic> json) {
    game_status = json['game_status'];
    status = json['status'];
  }
}

void _navigateToJoinGame(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Player()));
}

int checkFourCorners(List ticket_nos, HashMap<dynamic, dynamic> mp) {
  int corners_marked = 0;
  int i = 0;
  for (i = 0; i < 9; i++) {
    if (ticket_nos[i] != 0) break;
  }
  if (mp[i] == 1) corners_marked += 1;

  for (i = 8; i >= 0; i--) {
    if (ticket_nos[i] != 0) break;
  }
  if (mp[i] == 1) corners_marked += 1;

  for (i = 18; i < 27; i++) {
    if (ticket_nos[i] != 0) break;
  }
  if (mp[i] == 1) corners_marked += 1;

  for (i = 26; i >= 18; i--) {
    if (ticket_nos[i] != 0) break;
  }
  if (mp[i] == 1) corners_marked += 1;

  return corners_marked == 4 ? 1 : 0;
}

int checkFirstRow(List ticket_nos, HashMap<dynamic, dynamic> mp) {
  int i;
  for (i = 0; i < 9; i++) {
    if (ticket_nos[i] != 0 && mp[i] == null) {
      return 0;
    }
  }
  return 1;
}

int checkMiddleRow(List ticket_nos, HashMap<dynamic, dynamic> mp) {
  int i;
  for (i = 9; i <= 17; i++) {
    if (ticket_nos[i] != 0 && mp[i] == null) {
      return 0;
    }
  }
  return 1;
}

int checkLastRow(List ticket_nos, HashMap<dynamic, dynamic> mp) {
  int i;
  for (i = 18; i < 26; i++) {
    if (ticket_nos[i] != 0 && mp[i] == null) {
      return 0;
    }
  }
  return 1;
}

int checkFullHousie(List ticket_nos, HashMap<dynamic, dynamic> mp) {
  return checkFirstRow(ticket_nos, mp) *
      checkMiddleRow(ticket_nos, mp) *
      checkLastRow(ticket_nos, mp);
}
