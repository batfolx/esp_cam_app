import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String sessionId;


Widget getLoadingWidget() {
  return Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.black),
      backgroundColor: Colors.white,
    ),
  );
}

Future<dynamic> getData(String url) async {

  try {
    var response = await http.get(url);
    print("[GET] ${response.bodyBytes.length}");
    return {
      'error': jsonDecode(response.body)['error'],
      'data': response.bodyBytes
    };
  } catch (e) {
    return {
      'error': e.toString()
    };
  }


}

Future<dynamic> getDataHeaders(String url, Map headers) async {
  try {
    var response = await http.get(url, headers: headers);
    print("[GET] ${response.bodyBytes.length}");
    return {
      'error': jsonDecode(response.body)['error'],
      'data': response.bodyBytes
    };
  } catch (e) {
    return {
      'error': e.toString()
    };
  }
}

Future<dynamic> getSessionId(String url, Map body) async {
  try {
    var response = await http.post(url, body: jsonEncode(body), headers: {'content-type': 'application/json'});
    print("[GET] ${response.body}");
    String id = response.headers['set-cookie'].split(";")[0].trim();
    return {
      "sessionId": id,
      'error': jsonDecode(response.body)["error"],
      'data': response.bodyBytes
    };
  } catch (e) {
    return {
      'error': e.toString()
    };
  }
}