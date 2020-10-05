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
  Widget loadingWidget;
  Widget errorWidget;

  @override
  void initState() {
    super.initState();
    proto = new TextEditingController();
    addr = new TextEditingController();
    port = new TextEditingController();
    proto.text = "http";
    port.text = "20000";
    addr.text = "192.168.1.8";
    loadingWidget = Container();
    errorWidget = Container();
  }

  @override
  void dispose() {

    super.dispose();
    proto.dispose();
    addr.dispose();
    port.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ESP-32 Cam App"),
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
              SizedBox(height: 50,),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                child: FlatButton(

                  color: Colors.blue,
                    onPressed: () async {
                      setState(() {
                        loadingWidget = getLoadingWidget();
                      });

                      String url = proto.text + "://" + addr.text + ":" + port.text;
                      var response  = await getData(url);
                      String error = response['error'];
                      print(error);

                      if (error == '') {
                        setState(() {
                          loadingWidget = Container();
                        });
                        CCTVArgs args = new CCTVArgs(proto.text, addr.text, port.text);
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

