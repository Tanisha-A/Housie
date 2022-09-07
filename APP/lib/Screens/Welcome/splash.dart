// import 'dart:ffi';
// import 'dart:js';
// import 'package:flutter/material.dart';

// import '../../main.dart';

// class Splash extends StatefulWidget {

// const Splash({Key? key}):super(key: key);

// @override
// _SplashState createstate()=>_SplashState();
// }

// class _SplashState extends State<Splash> {
//   Void initstate() {
//     super.initState();
//     navigatetohome();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           color: Colors.grey[900],
//           width: double.infinity,
//           height: MediaQuery.of(context).size.height,
//           padding: EdgeInsets.symmetric(horizontal: 30, vertical: 160),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height / 3,
//                     decoration: BoxDecoration(
//                         image: DecorationImage(
//                             image:
//                                 AssetImage('assets/images/illustration.jpeg'))),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void navigatetohome() async {
//   await Future.delayed(Duration(milliseconds: 1500),() {});
//   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage());
// }
