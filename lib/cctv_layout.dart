import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:espcamapp/networking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
  Uint8List prevImg = Uint8List(1);
  DateTime date = DateTime.now();

  final picker = ImagePicker();

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
          }),
          IconButton(icon: Icon(Icons.save_alt), onPressed: () async {

            try {
              // get the bytes of the current memory image
              Uint8List bytes = ((camImage as Image).image as MemoryImage).bytes;

              // get the temporary directory be we save this to camera
              Directory tempDir = await getTemporaryDirectory();

              // get the temp path
              String tempPath = tempDir.path;

              // create a temporary file
              File f = new File("$tempPath/temp.jpg");

              // write the bytes sync
              f.writeAsBytesSync(bytes);

              // save the image to the
              bool success = await GallerySaver.saveImage(f.path);

              // report success or failure
              if (success) {
                Fluttertoast.showToast(msg: "Saved image!");
              } else {
                Fluttertoast.showToast(msg: "Failed to save image.");
              }

              // then delete the temp file to save memory
              await f.delete();
            } catch (e) {
              Fluttertoast.showToast(msg: "Something went wrong in saving image. Try again in a little.");
            }




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
          'cam': currCamera.toString(),
          'login': args.login,
          'password': args.password
        })
      });

      websocket.on("data", (data)  {
        //print("GOT DATA!");
        if (mounted) {
          if (data['data'] == 0) return;
          String imgBytes = new String.fromCharCodes(data['data']);
          Uint8List decoded = base64Decode(imgBytes);
          Widget info;
          if (prevImg.length != decoded.length) {
            prevImg = decoded;
            date = DateTime.now();
          }
          info = Text("Last updated: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(date)}", style: TextStyle(
              color: Colors.white,
              fontSize: 16
          ));

          setState(() {
            camImage = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Current time: ${DateFormat('dd-MM-yyyy hh:mm:ss a').format(DateTime.now())}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14
                  ),),
                SizedBox(height: 7.5,),
                info,
                SizedBox(height: 5,),
                Image(
                  gaplessPlayback: true,
                  image: MemoryImage(decoded),
                )
              ],
            );

          });
        } else {

        }

      });

      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (mounted) {
            websocket.emit("camera", {
              'cam': currCamera.toString(),
              'login': args.login,
              'password': args.password
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
  String login;
  String password;

  CCTVArgs(this.proto, this.addr, this.port, this.login, this.password);

  String url() {
    return proto + "://" + addr + ":" + port;
  }
}
