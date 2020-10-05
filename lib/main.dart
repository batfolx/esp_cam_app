import 'package:espcamapp/cctv_layout.dart';
import 'package:espcamapp/connect_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black


      ),
      initialRoute: "ConnectState",
      routes: {
        "ConnectState": (context) => Connect(),
        "CCTVState": (context) => CCTV(),
      },
    );
  }
}
