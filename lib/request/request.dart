import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wassup_front/config/config.dart';

import '../main.dart';

Future<dynamic> get(String url, String token, BuildContext context) async {
  var response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  );
  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);
    if (responseData['code'] == 200) {
      return responseData['data'];
    } else if (responseData['code'] == 402) {
      // 刷新token
      return get(url, refreshToken(token, context), context);
    } else {
      throw responseData['message'];
    }
  } else {
    throw "网络错误";
  }
}

Future<dynamic> post(String url, String token, dynamic data, BuildContext context) async {
  var response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(data),
  );
  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);
    if (responseData['code'] == 200) {
      return responseData['data'];
    } else if (responseData['code'] == 402) {
      // 刷新token
      return post(url, refreshToken(token, context), data, context);
    } else {
      throw responseData['message'];
    }
  } else {
    throw "网络错误";
  }
}

String refreshToken(String token, BuildContext context) {
  String newToken = post('${Config.authUrl}auth/refresh', token, null, context) as String;

  if (context.mounted) {
    context.read<MyAppState>().updateToken(newToken);
  }

  return newToken;
}
