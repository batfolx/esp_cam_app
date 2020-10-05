import 'dart:async';
import 'package:espcamapp/networking.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CCTV extends StatefulWidget {
  @override
  _CCTVState createState() => _CCTVState();
}

class _CCTVState extends State<CCTV> {
  bool started = false;
  Widget camImage;
  Timer timer;
  CCTVArgs args;
  int currCamera = 1;
  IO.Socket websocket;

  @override
  void initState() {
    super.initState();
    camImage = getLoadingWidget();
  }

  @override
  Widget build(BuildContext context) {
    if (!started) {
      started = true;
      args = ModalRoute.of(context).settings.arguments;
      connectWebSocket();


      // start a timer with 2 seconds to refresh the picture from the
      // server, should probably implement websocket here eventually
      /*timer = Timer.periodic(Duration(seconds: 2), (timer) async {
        var response = await getData(args.url() + "/pic?name=$currCamera");
        String error = response['error'];
        if (error == '') {
          if (mounted) {
            setState(() {
              camImage = Image(
                gaplessPlayback: true,
                image: MemoryImage(response['data']),
              );
            });
          }
        } else {
          // do nothing for now
        }
      }); */
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Watching camera number $currCamera"),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                TextEditingController temp = new TextEditingController();
                var result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(

                        content: TextField(
                          controller: temp,
                          decoration: InputDecoration(
                            hintText: "Camera number",
                            labelText: "Camera number",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black
                              ),
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        ),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context, -1);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Cancel")
                                ],
                              )),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context, temp.text);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Confirm")
                                ],
                              )),
                        ],
                      );
                    });

                if (result != null && result != -1) {
                  // try to parse result into a number
                  try {
                    currCamera = int.parse(result);
                  } catch (e) {
                    // do nothing for now

                  }
                }
              })
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(children: [camImage]),
        ),
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    websocket.disconnect();
    websocket = null;
  }

  void connectWebSocket() {
    print("Connecting to ${args.url()}");
    // connect the websocket
    if (websocket == null) {

      // connect to the URL given in the args
      websocket = IO.io(args.url(), <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      // send a connection to the server
      websocket.on("connect", (data) => {
        print("Connected to websocket! ${args.url()}"),
        websocket.emit("camera", {
          'cam': currCamera.toString()
        })
      });

      websocket.on("data", (data)  {
        //print("GOT DATA!");
        setState(() {
          camImage = Image(
            gaplessPlayback: true,
            image: MemoryImage(data['data']),
          );
        });
      });

      timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (!mounted) return;
        websocket.emit("camera", {
          'cam': currCamera.toString()
        });
      });
    }

  }
}

class CCTVArgs {
  String proto;
  String addr;
  String port;

  CCTVArgs(this.proto, this.addr, this.port);

  String url() {
    return proto + "://" + addr + ":" + port;
  }
}
