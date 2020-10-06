import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
IO.Socket websocket;


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