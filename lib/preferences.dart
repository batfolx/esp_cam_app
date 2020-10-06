import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

const FILENAME = "prefs.json";

Future<dynamic> savePreferencesToFile(String proto,
    String addr, String port, String login, String password) async {

  // get the directory
  Directory dir = await getApplicationDocumentsDirectory();

  // get app path
  String path = dir.path;

  // prepare contents of the file
  Map<String, String> contents = {
    "proto": proto,
    "addr": addr,
    "port": port,
    "login": login,
    "password": password
  };

  File f = new File("$path/$FILENAME");
  if (!await f.exists()) await f.create();
  await f.writeAsString(jsonEncode(contents));
  return;
}

Future<dynamic> getPreferences() async {
  // get the directory
  Directory dir = await getApplicationDocumentsDirectory();

  // get app path
  String path = dir.path;

  File f = new File("$path/$FILENAME");

  if (!await f.exists()) await f.create();

  String preferences = await f.readAsString();

  if (preferences == "") {

    return {
      "proto": "http",
      "addr": "192.168.1.8",
      "port": "20000",
      "login": "victor",
      "password": "batfolx"
    };

  } else {
    try {
      return jsonDecode(preferences);
    } catch (e) {
      print("Failed to json decode $e");
      return {
        "proto": "http",
        "addr": "192.168.1.8",
        "port": "20000",
        "login": "victor",
        "password": "batfolx"
      };
    }
  }


}

