import 'dart:convert';
import 'dart:math';

import 'package:espcamapp/cctv_layout.dart';
import 'package:espcamapp/networking.dart';
import 'package:espcamapp/preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Connect extends StatefulWidget {
  @override
  _ConnectState createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {

  TextEditingController proto;
  TextEditingController addr;
  TextEditingController port;
  TextEditingController login;
  TextEditingController password;
  TextEditingController camera;
  String loginErr;
  String passwordErr;
  Widget loadingWidget;
  Widget errorWidget;
  bool started = false;


  @override
  void initState() {
    super.initState();
    proto = new TextEditingController();
    addr = new TextEditingController();
    port = new TextEditingController();
    login = new TextEditingController();
    password = new TextEditingController();
    camera = new TextEditingController();
    proto.text = "http";
    port.text = "20000";
    addr.text = "192.168.1.8";
    login.text = 'victor';
    password.text = 'batfolx';
    loadingWidget = Container();
    errorWidget = Container();
  }

  @override
  void dispose() {
    super.dispose();
    proto.dispose();
    addr.dispose();
    port.dispose();
    login.dispose();
    password.dispose();
    camera.dispose();
  }

  /// Get the saved preferences (proto, addr) so
  /// user doesn't have to type it every time they go into
  /// app
  void getPreferencesInfo() async {

    var preferences = await getPreferences();
    print(preferences);

    setState(() {
      proto.text = preferences['proto'];
      addr.text = preferences['addr'];
      port.text = preferences['port'];
      login.text = preferences['login'];
      password.text = preferences['password'];
      camera.text = preferences['camera'];
    });

  }

  /// saves all the stuff to a file
  Future<dynamic> savePreferencesInfo() async {

    await savePreferencesToFile(
        proto.text.trim(), addr.text.trim(), port.text.trim(),
        login.text, password.text, camera.text.trim());

    Fluttertoast.showToast(msg: "Saved address & login info");


  }


  @override
  Widget build(BuildContext context) {

    if (!started) {
      started = true;
      getPreferencesInfo();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("ESP-32 SpyCam"),
        actions: [
          IconButton(icon: Icon(Icons.save_alt), onPressed: savePreferencesInfo)
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15,),
              Container(
                width: MediaQuery.of(context).size.height * 0.2,
                height: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/cctv_app_icon.webp"
                          //"assets/cctv_icon.png"
                        )
                    )
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: proto,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      ),
                    hintText: "Protocol",
                    labelText: "Protocol"
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: addr,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      ),
                      hintText: "Address",
                      labelText: "Address"
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: port,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      ),
                      hintText: "Port",
                      labelText: "Port"
                  ),
                ),
              ),
              SizedBox(height: 30,),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,

                      child: TextField(
                        controller: login,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.black
                                )
                            ),
                            hintText: "Login",
                            labelText: "Login",
                            errorText: loginErr
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.black
                                )
                            ),
                            hintText: "Password",
                            labelText: "Password",
                            errorText: passwordErr
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: camera,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      ),
                      hintText: "Camera number",
                      labelText: "Camera number"
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                child: FlatButton(
                  color: Colors.blue,
                    onPressed: () async {


                      if (login.text.trim() == "")loginErr = "Must not be empty";
                      else loginErr = null;
                      if (password.text.trim() == "") passwordErr = "Must not be empty";
                      else passwordErr = null;

                      if (loginErr != null || passwordErr != null) {
                        setState(() {});
                        return;
                      }
                      setState(() {
                        loadingWidget = getLoadingWidget();
                      });


                      String url = proto.text + "://" + addr.text + ":" + port.text + "/api/auth";
                      Map<String, String> body = {
                        "user": login.text,
                        "pass": password.text
                      };
                      var response  = await getSessionId(url, body);
                      String error = response['error'];
                      print(error);
                      if (error == '') {
                        setState(() {
                          loadingWidget = Container();
                        });
                        sessionId = response["sessionId"];
                        print("Session ID: $sessionId");
                        CCTVArgs args = new CCTVArgs(proto.text, addr.text, port.text, login.text, password.text, camera.text);
                        await Navigator.pushNamed(context, "CCTVState", arguments: args);

                      } else {

                        setState(() {
                          loadingWidget = Container();
                          errorWidget = Text("Failed to connect to " + url);
                        });

                        await Future.delayed(Duration(seconds: 2));
                        setState(() {
                          loadingWidget = Container();
                          errorWidget = Container();
                        });

                      }


                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cast_connected, color: Colors.white,),
                        SizedBox(width: 5,),
                        Text("Connect", style: TextStyle(
                          color: Colors.white, fontSize: 18
                        ),)
                      ],
                    )
                ),

              ),
              SizedBox(height: 30,),
              loadingWidget,
              errorWidget,

            ],
          ),
        ),
      ),
    );
  }
}

