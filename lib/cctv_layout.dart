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
      disconnectWebSocket();
      connectWebSocket();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Camera $currCamera"),
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
                    setState(() {
                      camImage = getLoadingWidget();
                    });
                  } catch (e) {
                    // do nothing for now

                  }
                }
              }),
          IconButton(icon: Icon(Icons.refresh), onPressed: () {
            if (!websocket.connected)
            connectWebSocket();
            else
              print("Websocket is already connected");
          })
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: camImage
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    disconnectWebSocket();

  }

  void connectWebSocket() {
    print("Connecting to ${args.url()}");
    // connect the websocket
    if (websocket == null || !websocket.connected) {

      // connect to the URL given in the args
      websocket = IO.io(args.url(), <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      }).connect();
      // send a connection to the server
      websocket.on("connect", (data) => {
        print("Connected to websocket! ${args.url()}"),
        websocket.emit("camera", {
          'cam': currCamera.toString()
        })
      });

      websocket.on("data", (data)  {
        //print("GOT DATA!");
        if (mounted) {
          setState(() {
            camImage = Image(
              gaplessPlayback: true,
              image: MemoryImage(data['data']),
            );
          });
        } else {

        }

      });

      timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (mounted) {
            websocket.emit("camera", {
              'cam': currCamera.toString()
            });
          } else {
          disconnectWebSocket();
        }


      });
    }

  }

  void disconnectWebSocket() {
    if (websocket != null) {
      websocket.emit("disconnect");
      websocket.off("data");
      websocket.disconnect();
    }

    websocket = null;
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
