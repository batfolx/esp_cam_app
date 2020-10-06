import 'dart:math';

import 'package:espcamapp/cctv_layout.dart';
import 'package:espcamapp/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  String loginErr;
  String passwordErr;
  Widget loadingWidget;
  Widget errorWidget;

  @override
  void initState() {
    super.initState();
    proto = new TextEditingController();
    addr = new TextEditingController();
    port = new TextEditingController();
    login = new TextEditingController();
    password = new TextEditingController();
    proto.text = "http";
    port.text = "20000";
    addr.text = "192.168.1.8";
    login.text = '0';
    password.text = '0';
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ESP-32 SpyCam"),
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


                      String url = proto.text + "://" + addr.text + ":" + port.text + "/auth";
                      Map<String, String> headers = {
                        "login": login.text,
                        "password": password.text
                      };
                      var response  = await getDataHeaders(url, headers);
                      String error = response['error'];
                      print(error);

                      if (error == '') {
                        setState(() {
                          loadingWidget = Container();
                        });
                        CCTVArgs args = new CCTVArgs(proto.text, addr.text, port.text, login.text, password.text);
                        await Navigator.pushNamed(context, "CCTVState", arguments: args);

                      } else {

                        if (error == 'invalid') {
                          setState(() {
                            loadingWidget = Container();
                            errorWidget = Text("Wrong username & password. ");
                          });

                          await Future.delayed(Duration(seconds: 2));
                          setState(() {
                            loadingWidget = Container();
                            errorWidget = Container();
                          });
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

