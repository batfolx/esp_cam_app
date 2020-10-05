import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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
      'error': '',
      'data': response.bodyBytes
    };
  } catch (e) {
    return {
      'error': e.toString()
    };
  }


}