import 'package:espcamapp/networking.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';

class CCTV extends StatefulWidget {
  @override
  _CCTVState createState() => _CCTVState();
}

class _CCTVState extends State<CCTV> with TickerProviderStateMixin {
  CCTVArgs args;
  int currCamera = 1;
  IOWebSocketChannel channel;
  DateTime date = DateTime.now();
  final picker = ImagePicker();
  TabController tabController;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      args = ModalRoute.of(context).settings.arguments as CCTVArgs;
      channel = IOWebSocketChannel.connect(
          "ws://${args.addr}:${args.port}/api/stream/user",
          headers: {'cookie': sessionId, 'cameraNumber': args.camnum});
      currCamera = int.parse(args.camnum);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera $currCamera"),
        bottom: PreferredSize(
          preferredSize: AppBar().preferredSize,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.3),
            tabs: [
              Tab(
                child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      TextEditingController temp =
                          new TextEditingController();
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
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10))),
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
                          var resp = await getDataHeaders(
                              "${args.url()}/api/stream/change",
                              {
                                "cookie": sessionId,
                                "cameraNumber": currCamera.toString()
                              } as Map<String, String>);

                          print(resp);
                          setState(() {});
                        } catch (e) {
                          // do nothing for now

                        }
                      }
                    }),
              ),
              Tab(
                child: IconButton(
                    icon: Icon(Icons.face),
                    onPressed: () async {
                      var resp = await getDataHeaders(
                          "${args.url()}/api/stream/facialDetect/on",
                          {
                            "cookie": sessionId,
                            "cameraNumber": currCamera.toString()
                          } as Map<String, String>);
                      setState(() {

                      });
                    }),
              ),
              Tab(
                child: IconButton(
                    icon: Icon(Icons.emoji_objects),
                    onPressed: () async {
                      var resp = await getDataHeaders(
                          "${args.url()}/api/stream/motionDetect/on",
                          {
                            "cookie": sessionId,
                            "cameraNumber": currCamera.toString()
                          } as Map<String, String>);
                      setState(() {

                      });
                    }),

              ),
              Tab(
                child: IconButton(
                    icon: Icon(Icons.hot_tub),
                    onPressed: () async {
                      var resp = await getDataHeaders(
                          "${args.url()}/api/stream/heatMap/on",
                          {
                            "cookie": sessionId,
                            "cameraNumber": currCamera.toString()
                          } as Map<String, String>);
                      setState(() {

                      });
                    }),
              ),
              Tab(
                child: IconButton(
                    icon: Icon(Icons.video_call_rounded),
                    onPressed: () async {
                      var resp = await getDataHeaders(
                          "${args.url()}/api/stream/normal/on",
                          {
                            "cookie": sessionId,
                            "cameraNumber": currCamera.toString()
                          } as Map<String, String>);
                      setState(() {

                      });
                    }),
              ),
              Tab(
                child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () async {
                      var resp = await getDataHeaders(
                          "${args.url()}/api/stream/off",
                          {
                            "cookie": sessionId,
                            "cameraNumber": currCamera.toString()
                          } as Map<String, String>);
                      setState(() {

                      });
                    }),
              )
            ],
          ),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: StreamBuilder(
            stream: this.channel.stream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Image.memory(
                      snapshot.data,
                      gaplessPlayback: true,
                    )
                  : getLoadingWidget();
            },
          )),
    );
  }

  @override
  void dispose() {
    if (channel != null) channel.sink.close();
    super.dispose();
  }

  void setCameraNumber() {
    try {
      currCamera = int.parse(args.camnum);
    } catch (e) {
      currCamera = 1;
    }
  }
}

class CCTVArgs {
  String proto;
  String addr;
  String port;
  String login;
  String password;
  String camnum;

  CCTVArgs(
      this.proto, this.addr, this.port, this.login, this.password, this.camnum);

  String url() {
    return proto + "://" + addr + ":" + port;
  }
}
