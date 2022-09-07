import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'caller.dart';

class Host extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HostState();
  }
}

class _HostState extends State<Host> {
  @override
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var numberOfTickets = new List<int>.generate(50, (i) => i + 1);
  var _currentValue = 1;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          backgroundColor: Colors.redAccent,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: true,
          children: [
            SpeedDialChild(
                child: Icon(Icons.share_rounded),
                label: 'Share',
                backgroundColor: Colors.blue,
                onTap: () {
                  print('Share Tapped');
                }),
            SpeedDialChild(
                child: Icon(Icons.mail),
                label: 'Mail',
                onTap: () {
                  print('Mail Tapped');
                }),
            SpeedDialChild(
                child: Icon(Icons.copy),
                label: 'Copy',
                onTap: () {
                  print('Copy Tapped');
                }),
          ],
        ),
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            // flexibleSpace: Image(
            //   image: AssetImage('assets/images/homepage.png'),
            //   fit: BoxFit.cover,
            // ),
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
              decoration:
                  new BoxDecoration(color: Colors.white.withOpacity(0.0)),

              // children: <Widget>[
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 60),
                          textStyle: TextStyle(fontSize: 24),
                          primary:
                              Color.fromARGB(255, 205, 81, 76), //background
                          onPrimary: Colors.black, //foreground
                        ),
                        child: Text('Genrate Code'),
                        onPressed: () async {
                          var response = await http.post(
                            Uri.parse('http://localhost:5005/create_game'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(
                                <String, String>{"username": "Yash"}),
                          );
                          print("Generating new game code.....");
                          print(jsonDecode(response.body));
                          _navigateToCaller(context);
                        },
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(50, 10, 20, 10)),
                      SizedBox(
                        height: 20.0,
                      ),
                      DropdownButton(
                        value: _currentValue,
                        items: numberOfTickets
                            .map<DropdownMenuItem<int>>((int number) {
                          return DropdownMenuItem<int>(
                            value: number,
                            child: Text(
                              number.toString(),
                              style: TextStyle(
                                fontSize: 25.0,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (int? _newValue) {
                          setState(() {
                            _currentValue = _newValue!;
                          });
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 60),
                          textStyle: TextStyle(fontSize: 24),
                          primary:
                              Color.fromARGB(255, 205, 81, 76), //background
                          onPrimary: Colors.black, //foreground
                        ),
                        child: Text('Genrate Tickets'),
                        onPressed: () {
                          _navigateToCaller(context);
                        },
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateToCaller(BuildContext context) {
  Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => HostPlayer()));
}
